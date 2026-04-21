# Shakr — Match & Chat Mimarisi

Bu belge uygulamanın shake → match → chat → kalıcı chat akışını,
neden bu şekilde tasarlandığını ve her parçanın nasıl çalıştığını açıklar.

---

## İçindekiler

1. [Genel Mimari Mantığı](#1-genel-mimari-mantığı)
2. [Shake Akışı](#2-shake-akışı)
3. [Cloud Function — Eşleşme Motoru](#3-cloud-function--eşleşme-motoru)
4. [Match Akışı](#4-match-akışı)
5. [Chat (Geçici) Akışı](#5-chat-geçici-akışı)
6. [Chat Expired Akışı](#6-chat-expired-akışı)
7. [Kalıcı Chat Akışı](#7-kalıcı-chat-akışı)
8. [Cooldown Sistemi](#8-cooldown-sistemi)
9. [Firestore Koleksiyon Şeması](#9-firestore-koleksiyon-şeması)

---

## 1. Genel Mimari Mantığı

Uygulama **Clean Architecture** + **BLoC/Cubit** pattern kullanır.

```
UI (Widget)
  ↕ state okur / event tetikler
Cubit (Presentation Layer)
  ↕ usecase çağırır
Usecase (Domain Layer)
  ↕ repository arayüzüne bağlı
Repository Impl (Data Layer)
  ↕ remote datasource çağırır
Remote Datasource
  ↕ Firestore / API ile konuşur
```

**Neden bu katmanlama?**
Cubit sadece "ne yapılacağını" bilir, "nasıl yapıldığını" bilmez.
Bu yüzden Firestore'u mock'layabilirsin, UI değişmez.
Repository arayüzü (interface) sayesinde datasource'u istediğin zaman değiştirebilirsin.

**State yönetimi:**
Her Cubit bir `state` emit eder. Widget `BlocBuilder` ile bu state'i dinler
ve sadece değişen kısımları yeniden render eder.

---

## 2. Shake Akışı

### Akış Şeması

```
Kullanıcı telefonu sallar
        ↓
ShakeService tetiklenir (accelerometer)
        ↓
ShakeCubit.init() içindeki callback çalışır
        ↓
Kontrol 1: state.status == initial mi?  → değilse dur
        ↓
Kontrol 2: hasActiveMatchUsecase → aktif match var mı? → varsa dur
        ↓
LocationService.getCurrentLocation() → koordinat al
        ↓
recordShakeUsecase → Firestore'a shakes/{uid} yaz
        ↓
startMatchTimer() → 15 saniye bekle
        ↓
15 saniye doldu, match gelmedi → noMatch state emit et
```

### ShakeCubit.init() — Detaylı Açıklama

```dart
void init() {
  reset();                    // state'i sıfırla
  sl<MatchCubit>().reset();   // match state'ini de sıfırla
  final uid = sl<AuthCubit>().currentUid;

  sl<ShakeService>().startListening(() async {
    // Bu callback her shake algılandığında çalışır

    // GUARD 1: Sadece initial state'teyken yeni shake kabul et
    // Zaten bir shake kaydedilmişse ikinci kez kaydetme
    if (state.status != ShakeCubitStatus.initial) return;

    // GUARD 2: Bu kullanıcının zaten aktif bir match'i var mı?
    // matches koleksiyonunda uid'i içeren active status'lü döküman sorgular
    final hasMatch = await hasActiveMatchUsecase.call(uid);
    if (hasMatch) return;

    // Konum al (izin yoksa son bilinen konumu fallback olarak kullan)
    final locationResult = await sl<LocationService>().getCurrentLocation();

    // Firestore'a yaz ve timer'ı başlat
    recordShake(ShakeEntity(uid: uid, location: locationResult.location, ...));
  });

  // MatchCubit'i bu kullanıcı için stream'e bağla
  // Firestore'dan herhangi bir match gelirse MatchCubit yakalar
  if (uid != null) sl<MatchCubit>().watchMatch(uid);
}
```

**Kritik nokta:** `init()` hem ShakeService'i başlatır hem de MatchCubit'i stream'e bağlar.
Bu ikisi birlikte çalışır: shake kaydederken aynı anda gelen match'i de dinliyorsun.

### State Akışı

```
initial → detected → recorded → (match gelirse ShakeCubit durur, MatchCubit devralır)
                               → (15 sn geçerse) noMatch
```

`detected`: shake algılandı, henüz Firestore'a yazılmadı (UI "aranıyor..." gösterir)
`recorded`: Firestore'a yazıldı, Cloud Function çalışmasını bekliyor
`noMatch`: 15 saniye doldu, kimse sallamamış

---

## 3. Cloud Function — Eşleşme Motoru

Eşleşme mantığı client'ta değil, sunucuda çalışır.
Bu sayede iki kullanıcı aynı anda shake yaparsa güvenli ve atomik bir eşleşme olur.

### Tetiklenme

```javascript
exports.findMatch = onDocumentCreated({
  document: "shakes/{uid}",  // shakes koleksiyonuna YENİ döküman eklenince tetiklenir
  region: "europe-west3",
}, async (event) => { ... });
```

`shakes/{uid}` path'inde `{uid}` wildcard parametredir —
kim shake kaydederse o UID ile tetiklenir.

### Eşleşme Algoritması

```javascript
// ADIM 1: Son 5 saniye içinde shake kaydeden, "waiting" status'lü kullanıcıları çek
const fiveSecondsAgo = new Date(Date.now() - 5000);
const candidatesSnap = await db.collection("shakes")
  .where("status", "==", "waiting")
  .where("timestamp", ">=", fiveSecondsAgo)
  .get();

// ADIM 2: Kendini ve koşulları sağlamayanları filtrele
const validCandidates = candidatesSnap.docs.filter((doc) => {
  if (doc.id === uid) return false;  // kendisi olamaz

  // Zaman farkı: ±5 saniye içinde olmalı
  const timeDiff = Math.abs(newShake.timestamp - candidateData.timestamp);
  if (timeDiff > 5000) return false;

  // Mesafe: 150 metre yarıçap içinde olmalı
  const distance = geolib.getDistance(newShake.location, candidateData.location);
  return distance <= 150;
});

// ADIM 3: İlk uyumlu adayla eşleş (batch write — atomic)
const batch = db.batch();
batch.set(matchRef, { user1, user2, users: [user1, user2], status: "active", ... });
batch.delete(db.collection("shakes").doc(uid));      // shake'i sil
batch.delete(db.collection("shakes").doc(matchUid)); // diğerinin shake'ini sil
await batch.commit();
```

**Neden batch write?**
Batch write ya tamamen başarılı olur ya da tamamen başarısız olur (atomik).
Match oluşturulup shake'ler silinmezse bir kullanıcı birden fazla match'e girebilir.
Batch bu durumu engeller.

**Neden server'da?**
İki kullanıcı neredeyse aynı anda shake yaparsa her ikisi için de Cloud Function tetiklenir.
Firestore transactions sayesinde sadece biri kazanır, duplicate match oluşmaz.

---

## 4. Match Akışı

Cloud Function match dökümanını oluşturduktan sonra
her iki kullanıcının client'ında `watchMatch` stream'i bu değişikliği yakalar.

### watchMatch — Real-time Dinleme

```dart
void watchMatch(String uid) {
  _subscription = watchMatchUsecase.call(uid).listen((match) {
    if (match == null) {
      // Match silindi (cooldown, expire, vb.)
      emit(state.copyWith(status: MatchCubitStatus.deleted));

    } else if (match.status == MatchStatus.expired) {
      // Sohbet süresi doldu — keep connection akışına geç
      _handleExpiredMatch(match, uid);

    } else if (match.status == MatchStatus.active) {
      final myAccepted = isUser1 ? match.user1Accepted : match.user2Accepted;

      if (match.user1Accepted && match.user2Accepted) {
        // İKİSİ DE kabul etti → sohbet başlasın
        emit(state.copyWith(status: MatchCubitStatus.accepted, match: match));

      } else if (myAccepted) {
        // Sadece ben kabul ettim, diğeri henüz kabul etmedi
        emit(state.copyWith(status: MatchCubitStatus.acceptancePending, match: match));

      } else {
        // Henüz kabul etmedim → kabul penceresini başlat
        _startAcceptTimer(match.matchId, match.createdAt);
        emit(state.copyWith(status: MatchCubitStatus.found, match: match));
      }
    }
  });
}
```

**Neden stream?**
İki kullanıcı farklı cihazlarda. A kabul edince B'nin ekranının güncellenmesi lazım.
Firestore real-time listener (stream) sayesinde Firestore'daki değişiklik
anında her iki client'a push edilir — polling gerekmez.

### 15 Saniyelik Kabul Penceresi

```dart
void _startAcceptTimer(String matchId, DateTime createdAt) {
  if (_acceptTimer?.isActive == true) return;  // zaten çalışıyorsa tekrar başlatma

  // createdAt'dan bu yana geçen süreyi hesapla
  // (kullanıcı match ekranını geç açtıysa doğru kalan süreyi hesapla)
  final elapsed = DateTime.now().difference(createdAt).inSeconds;
  final remaining = (AppConstants.matchAcceptanceWindowSeconds - elapsed).clamp(0, 15);

  if (remaining <= 0) {
    deleteMatch(matchId);  // süre zaten dolmuş
    return;
  }

  _acceptTimer = Timer(Duration(seconds: remaining), () {
    deleteMatch(matchId);  // süre doldu, match'i sil
  });
}
```

**Kritik tasarım kararı:** `elapsed` hesabı.
Stream ilk geldiğinde timer başlar.
Eğer kullanıcı uygulamayı arka plana aldıysa ve 10 saniye sonra döndüyse
timer 15 saniyeden değil, kalan 5 saniyeden başlar.
`createdAt` server timestamp'i kullandığı için hep doğru hesaplanır.

### Match State Makinesi

```
initial
  ↓ (Cloud Function match oluşturdu)
found           ← ikisi de henüz kabul etmedi
  ↓ (ben kabul ettim)
acceptancePending  ← ben kabul ettim, diğeri bekliyor
  ↓ (diğeri de kabul etti — Firestore stream güncelledi)
accepted        ← her ikisi kabul etti → chat'e git
  ↓ (chat süresi doldu — ChatCubit expireMatch çağırdı)
expired         ← "bağlantıyı koru?" ekranı
  ↓ (ikisi de "koru" dedi)
bothKept        → moveToPermanentChat tetiklendi
```

---

## 5. Chat (Geçici) Akışı

Her iki kullanıcı kabul edince `accepted` state'ine geçilir ve chat'e navigate edilir.

### ChatCubit.initChat()

```dart
void initChat(String id, DateTime fallbackCreatedAt, {bool isPermanent = false}) {
  watchMessages(id, isPermanent: isPermanent);  // Firestore stream'i başlat

  if (!isPermanent) {
    _startTimer(id, fallbackCreatedAt);  // geri sayım
  } else {
    emit(state.copyWith(secondsLeft: -1));  // kalıcı chat → timer yok
  }
}
```

### _startTimer — Geri Sayım Mekanizması

```dart
void _startTimer(String matchId, DateTime fallbackCreatedAt) {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {

    // Her saniye match dökümanını çek
    final matchResult = await sl<MatchCubit>().getMatchUsecase.call(matchId);

    matchResult.fold((l) => null, (match) {
      if (match == null) { timer.cancel(); return; }

      // chatStartedAt: her iki kullanıcı da kabul edince server bu alanı doldurur
      // Eğer hâlâ null ise sohbet henüz başlamamış — bekleme sayacı göster
      final startTime = match.chatStartedAt ?? fallbackCreatedAt;
      final isWaiting = match.chatStartedAt == null;

      final expireTime = startTime.add(Duration(seconds: AppConstants.chatExpirationSeconds));
      final remaining = expireTime.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        sl<MatchCubit>().expireMatch(matchId);  // Firestore'da status: expired yaz
        emit(state.copyWith(status: ChatStatus.timeExpired));  // UI'ı yönlendir
      } else {
        // chatStartedAt null iken sabit bir "bekleme" sayısı göster
        final displayRemaining = isWaiting
            ? AppConstants.chatWaitingDisplaySeconds
            : remaining;

        emit(state.copyWith(status: ChatStatus.timerTick, secondsLeft: displayRemaining));
      }
    });
  });
}
```

**Neden her saniye Firestore'a istek atıyoruz?**
`chatStartedAt` server timestamp'i ile doldurulur ve her iki kullanıcı için
farklı anlarda client'a ulaşır. Eğer stream kullansaydık zaman kayması olabilirdi.
`chatStartedAt`'ı tek bir kaynaktan (Firestore server time) okuyarak her iki client'ın
aynı anda expire olmasını sağlıyoruz.

### Geçici Chat Koleksiyonu

```
chats/
  {matchId}/
    messages/
      {messageId}: { senderId, text, createdAt }
```

Mesajlar geçici `chats` koleksiyonuna yazılır.
Match expire olunca ya da kalıcıya taşınınca bu koleksiyon silinir.

---

## 6. Chat Expired Akışı

Chat süresi dolunca iki şey olur:

1. `ChatCubit` → `emit(ChatStatus.timeExpired)` → UI `/chat-expired/{matchId}` route'una gider
2. `MatchCubit` → `expireMatch(matchId)` → Firestore'da `status: "expired"` yazar

### Expired Sayfasında Ne Olur?

```dart
// ChatExpiredPage açılınca:
sl<MatchCubit>().ensureLoaded(matchId);  // match verisini bir kez çek

// MatchCubit stream hâlâ aktif — Firestore'daki keepConnection değişikliklerini izler
```

`watchMatch` stream'i hâlâ dinliyor. Diğer kullanıcı "koru" derse:
- Diğer kullanıcının `user2KeepConnection: true` olur (Firestore güncellenir)
- Stream bunu yakalar → `connectionPending` state'ine geçer

### keepConnection Akışı

```
Kullanıcı A "Bağlantıyı Koru" butonuna basar
        ↓
keepConnectionFlow(matchId, uid)
        ↓
Firestore: matches/{matchId} → user1KeepConnection: true
        ↓
watchMatch stream her iki client'ta tetiklenir
        ↓
[Kullanıcı A'da]         [Kullanıcı B'de]
connectionPending        expired (B henüz basmadı)
  (B'yi bekliyor)
        ↓ (B de basar)
[Her iki client'ta]
bothKept state → moveToPermanentChat() çağrılır
```

### State Geçişleri (Expired Sonrası)

```dart
} else if (match.status == MatchStatus.expired) {
  final myKeep = isUser1 ? match.user1KeepConnection : match.user2KeepConnection;
  final otherKeep = isUser1 ? match.user2KeepConnection : match.user1KeepConnection;

  if (myKeep && otherKeep) {
    // Her ikisi de "koru" dedi
    emit(state.copyWith(status: MatchCubitStatus.bothKept, match: match));
    moveToPermanentChat(match.matchId);  // kalıcı chat'e taşı

  } else if (myKeep) {
    // Sadece ben "koru" dedim, diğeri henüz karar vermedi
    emit(state.copyWith(status: MatchCubitStatus.connectionPending, match: match));

  } else {
    // Ben henüz karar vermedim (veya ikisi de "sildi" dedi)
    emit(state.copyWith(status: MatchCubitStatus.expired, match: match));
  }
}
```

**Neden stream burada da çalışıyor?**
`watchMatch` ShakeCubit.init() içinde başlatılır ve uygulama boyunca aktif kalır.
Expired sayfasında yeni bir stream açmıyoruz — zaten açık olan stream'i kullanıyoruz.
Bu sayede Firestore'daki her değişiklik (keepConnection alanı) anında UI'a yansır.

---

## 7. Kalıcı Chat Akışı

Her iki kullanıcı "bağlantıyı koru" deyince `moveToPermanentChat` çalışır.

### moveToPermanentChat — Detaylı Adımlar

```dart
Future<void> moveToPermanentChat(String matchId) async {
  // ADIM 1: Match dökümanını oku
  final matchDoc = await db.collection('matches').doc(matchId).get();
  final matchData = matchDoc.data()!;

  // ADIM 2: Geçici chat'teki tüm mesajları oku
  final messages = await db
      .collection('chats')
      .doc(matchId)
      .collection('messages')
      .orderBy('createdAt')
      .get();

  // ADIM 3: Her iki kullanıcının profil bilgilerini çek (isim, fotoğraf)
  final user1Doc = await db.collection('users').doc(u1).get();
  final user2Doc = await db.collection('users').doc(u2).get();

  // ADIM 4: Kalıcı conversation dökümanı oluştur
  // matchId'yi conversationId olarak kullan — aynı ID, farklı koleksiyon
  await db.collection('conversations').doc(convId).set({
    'participants': [u1, u2],
    'user1': u1, 'user2': u2,
    'user1Name': user1Name, 'user2Name': user2Name,
    'lastMessage': lastMsg, 'lastMessageAt': lastTime,
    ...
  });

  // ADIM 5: Tüm mesajları conversations koleksiyonuna kopyala (batch write)
  final batch = db.batch();
  for (final doc in messages.docs) {
    final newMsgRef = db.collection('conversations').doc(convId)
        .collection('messages').doc(doc.id);
    batch.set(newMsgRef, doc.data());
  }
  await batch.commit();

  // ADIM 6: 100 yıllık cooldown yaz — conversation silinene kadar eşleşmesinler
  await writeCooldown(u1, u2, duration: const Duration(days: 36500));

  // ADIM 7: Geçici match + chats dökümanlarını sil
  await _hardDeleteMatch(matchId);
}
```

**Neden matchId'yi conversationId olarak kullanıyoruz?**
Basitlik. Aynı ID farklı koleksiyonda. Navigation parametrelerinde
hep aynı ID'yi geçebilirsin — "bu match mi, conversation mı?" diye ayrım yapmana gerek yok.

**Neden mesajları kopyalıyoruz, taşımıyoruz?**
Firestore'da "taşıma" diye bir şey yok. Yapılabilecek tek şey:
yeni koleksiyona yaz + eski koleksiyondan sil. Batch write atomik değil bu durumda
(batch 500 doc limiti var), ama mesaj sayısı genellikle düşük olduğu için sorun olmaz.

### Kalıcı Chat vs Geçici Chat

| Özellik | Geçici (chats/) | Kalıcı (conversations/) |
|---------|-----------------|-------------------------|
| Koleksiyon | `chats/{matchId}/messages` | `conversations/{matchId}/messages` |
| Timer | var (geri sayım) | yok |
| lastMessage alanı | yok | var (conversations doc'ta) |
| Silinince | match expire/delete | cooldown 24 saat |
| isPermanent flag | false | true |

`ChatCubit.initChat(isPermanent: true)` çağrıldığında timer başlamaz,
`secondsLeft: -1` set edilir. UI bunu "süresiz sohbet" olarak yorumlar.

---

## 8. Cooldown Sistemi

İki kullanıcının tekrar eşleşmesini belirli süre engelleyen mekanizma.

### Cooldown Anahtarı

```dart
String _cooldownKey(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();  // alfabetik sırala
  return '${sorted[0]}_${sorted[1]}';   // "aaa_bbb" formatı
}
```

**Neden sıralıyoruz?**
A+B çifti için key her zaman aynı olsun diye.
A'nın tetiklediği kontrol de B'ninkiyle aynı key'i üretir.
Sıralama olmasaydı "A_B" ve "B_A" iki farklı key olurdu.

### Ne Zaman Cooldown Yazılır?

```
kimse kabul etmedi / biri kabul etmedi
        → deleteMatch() çağrıldı
        → chatStartedAt == null → 1 saat cooldown

sohbet başladı ama kalıcıya taşınmadı
        → deleteMatch() çağrıldı
        → chatStartedAt != null → 24 saat cooldown

kalıcı sohbete taşındı
        → moveToPermanentChat() çağrıldı
        → 100 yıl cooldown (conversation silinene kadar "sonsuz")

kalıcı sohbet silindi
        → deleteConversation() çağrıldı
        → 24 saat cooldown (hemen değil, 24 saat sonra tekrar eşleşebilirler)
```

### Cooldown Kontrolü — watchMatch İçinde

```dart
// matchCooldowns koleksiyonunu kontrol et
Stream<MatchEntity?> watchMatch(String uid) {
  return db.collection('matches')
    .where('users', arrayContains: uid)
    .snapshots()
    .asyncMap((snapshot) async {
      ...
      final match = MatchModel.fromMap(doc.data(), doc.id);

      // Henüz kimse kabul etmemişse cooldown var mı kontrol et
      if (match.status == MatchStatus.active &&
          !match.user1Accepted && !match.user2Accepted) {
        final inCooldown = await isCooldownActive(match.user1Id, match.user2Id);
        if (inCooldown) {
          await _hardDeleteMatch(match.matchId);  // sessizce sil
          return null;  // UI'a hiç gösterme
        }
      }

      return match;
    });
}
```

**Cooldown neden Cloud Function'da değil?**
Client'ta kontrol ediliyor çünkü Cloud Function match'i oluştururken
cooldown koleksiyonunu sorgulamamız gerekir — bu da her match için
ek bir Firestore read anlamına gelir. Şu anki yaklaşım:
Cloud Function match oluşturur, client cooldown'u görünce match'i siler.
Bu "silme" işlemi nadiren gerçekleşir (aynı çift tekrar nadiren eşleşir)
bu yüzden kabul edilebilir bir trade-off.

---

## 9. Firestore Koleksiyon Şeması

```
shakes/
  {uid}:
    uid: string
    location: GeoPoint
    status: "waiting"
    timestamp: Timestamp

matches/
  {matchId}:
    user1: string (uid)
    user2: string (uid)
    users: [uid1, uid2]          ← arrayContains sorgusu için
    user1Vibes: string[]
    user2Vibes: string[]
    user1Accepted: bool
    user2Accepted: bool
    user1KeepConnection: bool
    user2KeepConnection: bool
    status: "active" | "expired"
    createdAt: Timestamp
    chatStartedAt: Timestamp?    ← ikisi de kabul edince dolar

chats/
  {matchId}/
    messages/
      {messageId}:
        senderId: string
        text: string
        createdAt: Timestamp

conversations/
  {conversationId}:              ← conversationId == matchId
    participants: [uid1, uid2]
    user1, user2: string
    user1Name, user2Name: string
    user1Photo, user2Photo: string?
    user1Vibes, user2Vibes: string[]
    lastMessage: string
    lastMessageAt: Timestamp
    readBy: string[]             ← okundu bilgisi için
    messages/
      {messageId}: (chats'ten kopyalandı)

matchCooldowns/
  {uid1_uid2}:                   ← sıralı, deterministic key
    user1: string
    user2: string
    expiresAt: Timestamp
```

---

## Özet: Tüm Akış Tek Bakışta

```
[Kullanıcı A sallar]          [Kullanıcı B sallar]
       ↓                              ↓
 shakes/A yaz                   shakes/B yaz
       ↓                              ↓
         Cloud Function tetiklenir (her ikisi için)
                      ↓
           Zaman ±5sn + Mesafe ≤150m kontrolü
                      ↓
           matches/{id} oluştur (batch)
           shakes/A ve shakes/B sil
                      ↓
    watchMatch stream her iki client'ta tetiklenir
                      ↓
         A ekranı: "Eşleşme bulundu!" → 15 sn pencere
         B ekranı: "Eşleşme bulundu!" → 15 sn pencere
                      ↓
    A kabul eder → user1Accepted: true → stream günceller
    B kabul eder → user2Accepted: true → chatStartedAt dolar
                      ↓
              accepted state → chat'e navigate
                      ↓
        ChatCubit timer başlar (chatStartedAt'dan itibaren)
        chats/{matchId}/messages stream başlar
                      ↓
          [30 saniye dolar]
                      ↓
         ChatStatus.timeExpired → /chat-expired/{matchId}
         MatchCubit.expireMatch → status: "expired"
                      ↓
    A "Koru" basar → user1KeepConnection: true
    B "Koru" basar → user2KeepConnection: true
                      ↓
         bothKept → moveToPermanentChat()
         conversations/{id} oluştur, mesajları kopyala
         100 yıl cooldown yaz
         matches/{id} + chats/{id} sil
                      ↓
              Kalıcı sohbet başlar
                      ↓
    [Kullanıcı sohbeti siler]
                      ↓
         conversations/{id} sil
         24 saat cooldown yaz (hemen eşleşemesinler)
```
