# ChatCubit ve MatchCubit — Detaylı Açıklama

Bu belge iki cubit'i satır satır açıklar.
Önce Cubit'in ne olduğunu anlatır, sonra her metodun tam olarak ne yaptığını, neden böyle yazıldığını ve hangi senaryolarda çalıştığını gösterir.

---

## Cubit Nedir?

Cubit, BLoC pattern'inin sadeleştirilmiş hali.
Temel fikir şu: UI'a ait veri (state) bir sınıfta tutulur, UI bu sınıfı dinler, sınıf değişince UI otomatik güncellenir.

```
UI Widget
  └─ BlocBuilder / BlocListener ile state'i dinler
        ↑
     Cubit  ← emit(yeniState) çağrıldığında UI tetiklenir
        ↑
     Usecase → Repository → Datasource → Firestore
```

`emit()` çağrıldığı anda cubit'i dinleyen tüm widget'lar yeni state ile rebuild olur.
Cubit dışarıdan metod çağrısıyla yönetilir — event göndermene gerek yok (BLoC'tan farkı bu).

---

## State Nedir?

Her cubit bir State sınıfı tutar. State değiştirilemez (immutable) — güncelleme için `copyWith` ile yeni bir kopya üretilir.

```dart
// Kötü — state'i direkt değiştirme
state.secondsLeft = 10;  // ❌ derlenmez

// Doğru — yeni kopya üret
emit(state.copyWith(secondsLeft: 10));  // ✅
```

`copyWith` sadece verdiğin alanları değiştirir, geri kalanları olduğu gibi taşır.

---

## ChatState

```dart
enum ChatStatus {
  initial,            // başlangıç, henüz hiçbir şey olmadı
  loading,            // mesajlar yükleniyor
  timerTick,          // her saniye güncellenen normal çalışma hali
  timeExpired,        // geçici chat süresi doldu
  conversationsLoaded,// sohbet listesi yüklendi
  conversationDeleted,// sohbet silindi
  error,              // hata
}

class ChatState {
  final ChatStatus status;
  final List<MessageEntity> messages;       // aktif chat'teki mesajlar
  final List<ConversationEntity> conversations; // sohbet listesi
  final int secondsLeft;    // geri sayım (-1 = kalıcı chat, sayım yok)
  final String? errorMessage;
}
```

**`secondsLeft: -1`** kalıcı chat'in özel işareti.
UI bu değeri görünce timer göstermez, sonsuz sohbet moduna girer.

---

## MatchState

```dart
enum MatchCubitStatus {
  initial,            // başlangıç
  loading,            // veri çekiliyor
  found,              // match bulundu, henüz kimse kabul etmedi
  notFound,           // match yok
  error,              // hata
  expired,            // chat süresi doldu, henüz keepConnection basılmadı
  deleted,            // match silindi
  bothKept,           // ikisi de "koru" dedi → kalıcı chat başlıyor
  connectionPending,  // ben "koru" dedim, diğeri henüz karar vermedi
  acceptancePending,  // ben kabul ettim, diğeri henüz kabul etmedi
  accepted,           // ikisi de kabul etti → chat başlayabilir
  cooldownActive,     // cooldown (şu an kullanılmıyor, rezerv)
}

class MatchState {
  final MatchCubitStatus status;
  final MatchEntity? match;   // match verisi (null olabilir)
  final String? errorMessage;
}
```

`MatchEntity?` null olabilir çünkü bazı state'lerde (deleted, notFound) match verisi yoktur.

---

---

# MatchCubit

Bir eşleşmenin tüm yaşam döngüsünü yönetir:
bulunma → kabul → chat → expire → keepConnection → kalıcı chat

---

## Bağımlılıklar

```dart
final WatchMatchUsecase watchMatchUsecase;       // real-time stream
final GetMatchUsecase getMatchUsecase;           // tek seferlik okuma
final AcceptMatchUsecase acceptMatchUsecase;     // kabul et
final ExpireMatchUsecase expireMatchUsecase;     // süre doldu işaretle
final DeleteMatchUsecase deleteMatchUsecase;     // sil
final KeepConnectionUsecase keepConnectionUsecase; // "koru" işaretle
final MoveToPermanentChatUsecase moveToPermanentChatUsecase; // kalıcıya taşı

StreamSubscription? _subscription; // watchMatch stream'ini tutar
Timer? _acceptTimer;               // 15 saniyelik kabul zamanlayıcısı
```

Her usecase bir Firestore işlemini temsil eder.
Cubit bu usecase'leri çağırır, Firestore'u direkt tanımaz.
Bu sayede Firestore'u değiştirsen cubit değişmez.

---

## `watchMatch(String uid)`

En kritik metod. Firestore'dan gelen her değişikliği dinler ve state makinesini yönetir.

```dart
void watchMatch(String uid) {
  _subscription = watchMatchUsecase.call(uid).listen((match) {
    ...
  });
}
```

`watchMatchUsecase.call(uid)` → Firestore'da `matches` koleksiyonunda
`users` array'i `uid` içeren dökümanları real-time dinleyen bir `Stream<MatchEntity?>` döndürür.

Her Firestore değişikliğinde bu callback çalışır. 4 ana dal var:

---

### Dal 1 — match == null (Silindi)

```dart
if (match == null) {
  _cancelAcceptTimer();
  emit(state.copyWith(status: MatchCubitStatus.deleted, match: null));
}
```

Match dökümanı Firestore'dan silindiyse stream `null` emit eder.
Timer iptal edilir (artık anlamsız), state `deleted` olur.
UI bunu görünce shake ekranına döner.

**Ne zaman null gelir?**
- Cooldown aktifse `watchMatch` datasource'u içinde match sessizce silinir
- `deleteMatch()` çağrılır (15 sn doldu, kullanıcı reddetdi)
- `endMatch()` çağrılır (chat içinden "eşleşmeyi bitir")

---

### Dal 2 — match.status == expired (Chat Süresi Doldu)

```dart
} else if (match.status == MatchStatus.expired) {
  _cancelAcceptTimer();
  final isUser1 = match.user1Id == uid;
  final myKeep    = isUser1 ? match.user1KeepConnection : match.user2KeepConnection;
  final otherKeep = isUser1 ? match.user2KeepConnection : match.user1KeepConnection;

  if (myKeep && otherKeep) {
    emit(state.copyWith(status: MatchCubitStatus.bothKept, match: match));
    moveToPermanentChat(match.matchId);
  } else if (myKeep) {
    emit(state.copyWith(status: MatchCubitStatus.connectionPending, match: match));
  } else {
    emit(state.copyWith(status: MatchCubitStatus.expired, match: match));
  }
}
```

**`isUser1` neden önemli?**
Firestore'da `user1KeepConnection` ve `user2KeepConnection` ayrı alanlar.
Kimin hangi alan olduğunu bulmak için UID karşılaştırması yapılır.

**3 alt durum:**

| myKeep | otherKeep | State | Ne olur |
|--------|-----------|-------|---------|
| true | true | `bothKept` | `moveToPermanentChat` hemen çağrılır |
| true | false | `connectionPending` | Diğeri basana kadar bekle |
| false | herhangi | `expired` | Kullanıcıya karar ekranı göster |

**Neden `moveToPermanentChat` burada çağrılıyor?**
İki kullanıcı farklı cihazda. Her ikisinin stream'i de bu değişikliği yakalar.
İki cihaz da `moveToPermanentChat` çağırır. Bu sorun değil çünkü Firestore
idempotent — aynı dökümanı iki kez set etmek zararsız.

---

### Dal 3 — match.status == active (Kabul Süreci)

```dart
} else if (match.status == MatchStatus.active) {
  final isUser1 = match.user1Id == uid;
  final myAccepted = isUser1 ? match.user1Accepted : match.user2Accepted;

  if (match.user1Accepted && match.user2Accepted) {
    _cancelAcceptTimer();
    emit(state.copyWith(status: MatchCubitStatus.accepted, match: match));
  } else if (myAccepted) {
    emit(state.copyWith(status: MatchCubitStatus.acceptancePending, match: match));
  } else {
    _startAcceptTimer(match.matchId, match.createdAt);
    emit(state.copyWith(status: MatchCubitStatus.found, match: match));
  }
}
```

**3 alt durum:**

| user1Accepted | user2Accepted | myAccepted | State |
|---------------|---------------|------------|-------|
| true | true | - | `accepted` → chat'e git |
| true | false | true | `acceptancePending` → "karşı taraf bekleniyor" |
| false | false | false | `found` → "kabul et / reddet" ekranı |

**Neden her ikisi de `true` olunca timer iptal ediliyor?**
Timer, 15 sn dolunca match'i silmek için kurulur.
İkisi de kabul edince match silinmemeli — timer durdurulur.

---

## `_startAcceptTimer(String matchId, DateTime createdAt)`

```dart
void _startAcceptTimer(String matchId, DateTime createdAt) {
  if (_acceptTimer?.isActive == true) return;  // zaten çalışıyor → dokunma

  final elapsed = DateTime.now().difference(createdAt).inSeconds;
  final remaining = (AppConstants.matchAcceptanceWindowSeconds - elapsed)
      .clamp(0, AppConstants.matchAcceptanceWindowSeconds);

  if (remaining <= 0) {
    deleteMatch(matchId);
    return;
  }

  _acceptTimer = Timer(Duration(seconds: remaining), () {
    deleteMatch(matchId);
  });
}
```

**Neden `elapsed` hesaplıyoruz?**
Kullanıcı uygulamayı arka plana almış olabilir. Match `createdAt: 10:00:00`,
kullanıcı ekrana 10:00:12'de döndü — zaten 12 saniye geçmiş.
`remaining = 15 - 12 = 3 saniye` ile timer kurulur. 15'ten başlatılsaydı haksız olurdu.

**`createdAt` neden server timestamp?**
İki kullanıcının cihaz saati birbirinden farklı olabilir (saat dilimi, drift).
Firestore server timestamp her iki taraf için aynı referans noktasını verir.

**`clamp(0, 15)`** → hesap negatif çıkarsa 0'a çeker, 15'ten büyük olamaz.

**`if (_acceptTimer?.isActive == true) return`** — idempotent koruma.
Stream her Firestore değişikliğinde tetiklenir. Kullanıcı kabul ekranındayken
başka bir alan güncellenirse (örn. `user2Accepted`) stream tekrar çalışır.
Timer zaten kuruluysa yeniden kurmayız — kalan süre sıfırlanmazdı.

---

## `ensureLoaded(String matchId)`

```dart
void ensureLoaded(String matchId) {
  const loaded = {
    MatchCubitStatus.loading,
    MatchCubitStatus.found,
    MatchCubitStatus.expired,
    MatchCubitStatus.connectionPending,
    MatchCubitStatus.bothKept,
    MatchCubitStatus.acceptancePending,
    MatchCubitStatus.accepted,
  };
  if (loaded.contains(state.status)) return;
  getMatch(matchId);
}
```

`ChatExpiredPage` açıldığında match verisine ihtiyaç duyar.
Ama stream zaten çalışıyor olabilir ve state `expired` durumunda olabilir.
Bu metod "veri zaten yüklüyse tekrar çekme" garantisi verir.

Eğer `initial`, `notFound`, `error`, `deleted` gibi "veri yok" durumundaysa
`getMatch()` çağrılır, tek seferlik Firestore okuması yapılır.

---

## `deleteMatch` vs `endMatch`

```dart
// Kullanıcı "reddet" butonuna bastı
Future<void> endMatch(String matchId) async {
  final result = await deleteMatchUsecase.call(matchId);
  result.fold(
    (l) => emit(state.copyWith(status: MatchCubitStatus.error, ...)),
    (_) => emit(state.copyWith(status: MatchCubitStatus.deleted)), // UI hemen güncelle
  );
}

// Sistem 15 sn doldu diye siliyor (timer)
Future<void> deleteMatch(String matchId) async {
  final result = await deleteMatchUsecase.call(matchId);
  result.fold(
    (l) => emit(state.copyWith(status: MatchCubitStatus.error, ...)),
    (_) => null, // UI'ı direkt güncelleme — watchMatch stream'i yakalar
  );
  emit(const MatchState()); // her halükarda sıfırla
}
```

**Fark:** `endMatch` kullanıcı aksiyonu — başarılıysa `deleted` emit et, UI hemen navigasyon yapsın.
`deleteMatch` sistem aksiyonu — stream zaten silindi olayını yakalayacak, fazladan emit'e gerek yok.
Ama sonunda `emit(const MatchState())` ile state temizlenir.

---

## `reset()`

```dart
void reset() {
  _cancelAcceptTimer();
  _subscription?.cancel();
  _subscription = null;
  emit(const MatchState());
}
```

`ShakeCubit.init()` içinde çağrılır — yeni bir shake döngüsü başlamadan önce
önceki match state'ini ve stream'ini tamamen temizler.
`_subscription?.cancel()` Firestore dinleyicisini durdurur (memory leak önler).

---

---

# ChatCubit

Hem geçici (30 saniyelik) hem kalıcı sohbetleri yönetir.
Mesaj gönderme, real-time mesaj dinleme, geri sayım timer'ı ve sohbet silme işlemleri burada.

---

## Bağımlılıklar

```dart
final SendMessageUsecase sendMessageUsecase;
final WatchMessagesUsecase watchMessagesUsecase;
final WatchConversationsUsecase watchConversationsUsecase;
final DeleteConversationUsecase deleteConversationUsecase;

final messageController = TextEditingController(); // input field
StreamSubscription? _subscription; // mesaj stream'i
Timer? _timer;                     // geri sayım timer'ı
```

`TextEditingController` cubit içinde tutuluyor çünkü `close()` metodunda
`dispose()` edilmesi gerekiyor — memory leak önlemek için.

---

## `initChat(String id, DateTime fallbackCreatedAt, {bool isPermanent})`

```dart
void initChat(String id, DateTime fallbackCreatedAt, {bool isPermanent = false}) {
  watchMessages(id, isPermanent: isPermanent);  // mesaj stream'ini başlat
  if (!isPermanent) {
    _startTimer(id, fallbackCreatedAt);          // geçici → geri sayım kur
  } else {
    emit(state.copyWith(status: ChatStatus.timerTick, secondsLeft: -1)); // kalıcı → timer yok
  }
}
```

**`fallbackCreatedAt` neden var?**
`chatStartedAt` Firestore'dan asenkron geliyor. İlk saniyede henüz yüklenmemiş olabilir.
Bu durumda match'in `createdAt`'ı fallback olarak kullanılır, timer sıfırdan başlamaz.

**`secondsLeft: -1`** → UI'da timer gösterme sinyali.
`-1` seçilmiş çünkü `0` "süre doldu" ile karışabilirdi.

---

## `_startTimer(String matchId, DateTime fallbackCreatedAt)`

Her saniye çalışan timer. Geçici chat'in en kritik parçası.

```dart
void _startTimer(String matchId, DateTime fallbackCreatedAt) {
  _timer?.cancel(); // varsa öncekini durdur
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (isClosed) { timer.cancel(); return; } // cubit kapandıysa dur

    // Her saniye Firestore'dan match'i çek
    final matchResult = await sl<MatchCubit>().getMatchUsecase.call(matchId);
    matchResult.fold((l) => null, (match) {
      if (match == null) { timer.cancel(); return; }

      final startTime = match.chatStartedAt ?? fallbackCreatedAt;
      final isWaiting = match.chatStartedAt == null;

      final expireTime = startTime.add(Duration(seconds: AppConstants.chatExpirationSeconds));
      final remaining = expireTime.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        sl<MatchCubit>().expireMatch(matchId); // Firestore'a status: expired yaz
        if (!isClosed) emit(state.copyWith(status: ChatStatus.timeExpired));
      } else {
        final displayRemaining = isWaiting
            ? AppConstants.chatWaitingDisplaySeconds // henüz başlamadı → sabit göster
            : remaining;                             // başladı → gerçek kalan süre

        if (!isClosed) emit(state.copyWith(
          status: ChatStatus.timerTick,
          secondsLeft: displayRemaining,
        ));
      }
    });
  });
}
```

**Neden her saniye Firestore'a istek atıyoruz?**
`chatStartedAt` Firestore server timestamp'i. İki kullanıcının client saati farklı olabilir.
Her ikisi de sunucudan okuyarak aynı referans noktasını kullanır → tam olarak aynı anda expire olurlar.

Stream kullansaydık: Firestore'da `chatStartedAt` değişince stream emit eder.
Ama timer hesabı için her saniye zaten okumamız gerekiyor — timer stream ile yapılamaz.

**`isWaiting` → sabit görüntü**
İkinci kullanıcı henüz kabul etmemiş, `chatStartedAt` null.
Bu durumda timer sabit bir değer (`chatWaitingDisplaySeconds`) gösterir.
Gerçek timer kullanıcı kabul edince başlar.

**`if (isClosed)` kontrolleri**
Cubit kapatılmışken emit çağrısı hata fırlatır.
Kullanıcı sayfadan çıkarsa cubit `close()` edilir, timer hâlâ çalışıyor olabilir.
Bu kontroller o anı yakalar.

---

## `watchMessages(String id, {bool isPermanent})`

```dart
void watchMessages(String id, {bool isPermanent = false}) {
  emit(state.copyWith(status: ChatStatus.loading));
  _subscription = watchMessagesUsecase
      .call(id, isPermanent: isPermanent)
      .listen(
        (messages) {
          final currentSeconds = state.status == ChatStatus.timerTick
              ? state.secondsLeft
              : (isPermanent ? -1 : AppConstants.chatWaitingDisplaySeconds);

          if (!isClosed) {
            emit(state.copyWith(
              status: ChatStatus.timerTick,
              secondsLeft: currentSeconds,
              messages: messages,
            ));
          }
        },
        onError: (error) {
          if (!isClosed) emit(state.copyWith(status: ChatStatus.error, ...));
        },
      );
}
```

Firestore'dan gelen her mesaj değişikliğini yakalar ve state'i günceller.

**`isPermanent` ne belirliyor?**
- `false` → `chats/{id}/messages` koleksiyonunu dinle (geçici)
- `true` → `conversations/{id}/messages` koleksiyonunu dinle (kalıcı)

Aynı `id` (matchId) farklı koleksiyonlarda kullanılır.

**`currentSeconds` neden korunuyor?**
Mesaj stream'i ve timer birbirinden bağımsız emit yapar.
Yeni mesaj gelince `secondsLeft` sıfırlanmasın diye mevcut değer taşınır.
`state.status == timerTick` kontrolü: timer henüz başlamadıysa `chatWaitingDisplaySeconds` kullan.

**`_subscription`** → Firestore dinleyicisini tutar.
`close()` içinde `_subscription?.cancel()` ile durdurulur.
Durdurulmazsa cubit kapansa bile Firestore'dan veri gelmeye devam eder (memory leak).

---

## `sendMessageFromInput` vs `sendMessage`

```dart
// UI'dan tetiklenir — input field'dan okur, temizler
Future<void> sendMessageFromInput(String id, String uid, {bool isPermanent}) async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;          // boşsa gönderme
  messageController.clear();         // input'u temizle (kullanıcı UX)
  final message = MessageEntity(
    id: const Uuid().v4(),           // client'ta unique ID üret
    senderId: uid,
    text: text,
    createdAt: DateTime.now(),
  );
  await sendMessage(id, message, isPermanent: isPermanent);
}

// Saf gönderme — test edilebilir, başka yerden de çağrılabilir
Future<void> sendMessage(String id, MessageEntity message, {bool isPermanent}) async {
  final result = await sendMessageUsecase.call(id, message, isPermanent: isPermanent);
  result.fold(
    (l) => emit(state.copyWith(status: ChatStatus.error, ...)),
    (r) => null,  // başarılıysa emit yok — watchMessages zaten yakalar
  );
}
```

**Neden başarılıysa emit yok?**
Mesaj gönderince Firestore güncellenir → `watchMessages` stream'i tetiklenir → state otomatik güncellenir.
Çift emit gereksiz, hatta tutarsızlığa yol açabilir.

**`Uuid().v4()`** → Evrensel benzersiz ID üretir.
Neden server timestamp veya auto-ID değil? Optimistic UI için.
Mesaj ID'si önceden bilinirse, mesaj gelmeden önce UI'da gösterebilirsin.

---

## `watchConversations(String uid)`

```dart
Stream<ChatState> watchConversations(String uid) {
  return watchConversationsUsecase.call(uid).map((result) {
    return result.fold(
      (failure) => ChatState(status: ChatStatus.error, errorMessage: failure.message),
      (conversations) => ChatState(status: ChatStatus.conversationsLoaded, conversations: conversations),
    );
  });
}
```

Diğer metodlardan farklı — `emit` kullanmıyor, doğrudan `Stream<ChatState>` döndürüyor.

**Neden?**
`MyChatsBody` widget'ı `StreamBuilder` kullanıyor.
`StreamBuilder` kendi stream'ini yönetir, cubit state'ine bağlanmak zorunda değil.
Bu sayede conversations listesi ile aktif chat ayrı stream'lerde çalışır, birbirini etkilemez.

**`result.fold((failure), (conversations))`**
`Either<Failure, List<ConversationEntity>>` tipi. Sol taraf hata, sağ taraf başarı.
`fold` ile iki durum tek satırda handle edilir.

---

## `deleteConversation(String conversationId)`

```dart
Future<void> deleteConversation(String conversationId) async {
  final result = await deleteConversationUsecase.call(conversationId);
  result.fold(
    (l) => emit(state.copyWith(status: ChatStatus.error, errorMessage: l.message)),
    (l) => emit(state.copyWith(status: ChatStatus.conversationDeleted)),
  );
}
```

Kalıcı sohbeti siler. Başarılıysa `conversationDeleted` emit edilir.
`ChatPage` bunu dinler ve `/main/chats` route'una navigate eder.

Datasource'da şunlar da yapılır (cubit bilmez):
- Conversation dökümanı silinir
- Alt mesajlar silinir
- 24 saatlik cooldown yazılır

---

## `close()`

```dart
@override
Future<void> close() {
  _timer?.cancel();          // timer durdur
  _subscription?.cancel();   // Firestore stream durdur
  messageController.dispose(); // TextEditingController temizle
  return super.close();
}
```

Cubit artık kullanılmayacaksa çağrılır (sayfa kapanınca, DI container temizlenince).
Her şeyin temizlenmesi memory leak'i önler.

`dispose()` çağrılmayan bir `TextEditingController` memory'de kalmaya devam eder.
`cancel()` çağrılmayan bir stream dinleyicisi arka planda çalışmaya devam eder.

---

## İki Cubit'in Birbirine Bağlantısı

```
MatchCubit ←────────────── watchMatch stream (Firestore real-time)
    │
    │ expireMatch() → Firestore'a status: expired yaz
    │
    ▼
ChatCubit._timer → her saniye getMatchUsecase çağırır
                → remaining <= 0 → expireMatch() → ChatStatus.timeExpired
                → UI /chat-expired'a gider
                → MatchCubit.watchMatch "expired" yakalar
                → keepConnection akışı başlar
```

`ChatCubit` doğrudan `MatchCubit`'e bağımlı değil.
Ama `sl<MatchCubit>()` ile singleton'a erişiyor — bu DI container üzerinden dolaylı bağlantı.

**Neden singleton?**
`MatchCubit` uygulama boyunca tek bir instance. Shake ekranı, match ekranı, chat ekranı
hepsi aynı `MatchCubit`'i kullanır. State sayfalar arası taşınır.

---

## State Makinesi — Özet Diyagram

### MatchCubit
```
initial
  ↓ watchMatch → match geldi
found ──────────────────────────────────────────── 15 sn doldu → deleteMatch
  ↓ acceptMatch()
acceptancePending ────────────────────────────── 15 sn doldu → deleteMatch
  ↓ diğeri de kabul etti (stream)
accepted → chat başlar
  ↓ timer doldu (ChatCubit tetikler)
[Firestore: status: expired]
  ↓ watchMatch stream yakalar
expired / connectionPending / bothKept
  ↓ (bothKept)
moveToPermanentChat → kalıcı chat
  ↓ deleted (endMatch / deleteMatch)
initial
```

### ChatCubit
```
initial
  ↓ initChat()
loading
  ↓ watchMessages stream ilk emit
timerTick (her saniye güncellenir, secondsLeft azalır)
  ↓ remaining <= 0
timeExpired → UI /chat-expired'a navigate eder
  ─── VEYA ───
  ↓ deleteConversation()
conversationDeleted → UI /main/chats'e navigate eder
```
