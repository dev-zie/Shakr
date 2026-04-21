# Shakr — Tüm Cubitler

Bu belge projedeki her cubit'i açıklar:
ne yönetir, neden bu şekilde tasarlanmış, hangi kararlar alınmış.

---

## Cubit Mantığı — Ortak Temel

Tüm cubitler aynı pattern'i izler:

```
UI → cubit metodu çağırır → usecase → Firestore
          ↓
       emit(yeniState)
          ↓
    UI otomatik rebuild
```

**Neden Cubit, BLoC değil?**
BLoC event sınıfları gerektiriyor — her aksiyon için ayrı bir sınıf.
Cubit'te direkt metod çağrısı var. Bu uygulama için yeterli karmaşıklıkta, daha az boilerplate.

**State neden immutable?**
Değiştirilemez state sayesinde Flutter "neyin değiştiğini" garantili anlıyor.
`copyWith` sadece verdiğin alanları değiştirir, gerisini taşır.
Flutter bu farkı görünce sadece etkilenen widget'ları rebuild eder.

**`Equatable` neden kullanılıyor?**
`Equatable`, iki state nesnesinin eşit olup olmadığını içerik bazında karşılaştırır.
Olmadan Flutter her `emit`'te rebuild yapardı — aynı değeri tekrar emit etsen bile.
`props` listesindeki alanlar karşılaştırılır; bunlar aynıysa emit görmezden gelinir.

---

## Cubit Haritası

```
NavigationCubit   → Alt navigasyon bar hangi sekme seçili
AuthCubit         → Firebase Auth oturumu, ilk profil kaydı
OnboardingCubit   → İlk kurulum akışı (adım adım form)
ProfileCubit      → Profil görüntüleme ve düzenleme
SettingsCubit     → Ayarlar sayfası
ShakeCubit        → Shake algılama, kaydetme, match bekleme
MatchCubit        → Match yaşam döngüsü (kabul → chat → expire → kalıcı)
ChatCubit         → Mesajlaşma, geri sayım, sohbet listesi
```

---

---

## 1. NavigationCubit

**Dosya:** `lib/features/main/presentation/cubit/navigation_cubit.dart`

### Ne yönetir?
Alt navigasyon bar'ındaki aktif sekmeyi. State'i `int` — bu kadar basit.

```dart
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);     // başlangıç: Salla sekmesi
  void goTo(int index) => emit(index);
  void goToShake()   => emit(0);
  void goToChats()   => emit(1);
  void goToProfile() => emit(2);
}
```

### Neden böyle?
3 sekme var: Salla (0), Mesajlar (1), Profil (2).
State olarak `int` tutmak yeterli — ayrı bir state sınıfı gereksiz karmaşıklık olurdu.
`goToShake()` gibi isimli metodlar index'i ezberleme zorunluluğunu kaldırıyor.

### Nasıl kullanılır?
`BlocBuilder<NavigationCubit, int>` ile `MainPage` hangi sekmenin gösterileceğini anlıyor.
`BottomNavigationBar`'ın `currentIndex`'i bu value'dan geliyor.

---

---

## 2. AuthCubit

**Dosya:** `lib/features/auth/presentation/cubit/auth_cubit.dart`

### Ne yönetir?
Firebase Authentication oturumu. Anonim giriş, mevcut kullanıcıyı alma, profil kaydetme.

```dart
enum AuthStatus { initial, loading, success, error, profileSaved }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;   // null = giriş yapılmamış
  final String? message;    // hata mesajı
}
```

### Metodlar

**`getCurrentUser()`**
Uygulama açılınca çağrılır. Firebase'de oturum var mı kontrol eder.
Varsa `success` + `user` emit eder → ana sayfaya yönlendir.
Yoksa `error` emit eder → anonim giriş yap.

**`signInAnonymously()`**
Kullanıcı hesabı oluşturmadan Firebase Auth token'ı alır.
Bu token UID üretir — Firestore kuralları bu UID ile çalışır.
Neden anonim? Sosyal giriş sürtüşmesini kaldırır, kullanıcı hemen başlar.

**`saveProfile(UserEntity user)`**
Onboarding sonunda ilk kez profil kaydı. `profileSaved` state'i ile router doğru sayfaya yönlendirir.

**`currentUid` getter**
```dart
String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
```
Cubit state'inden değil, doğrudan Firebase'den okur.
Bu getter her zaman güncel UID'i verir — state'te tutulmaz çünkü değişmez.

### Neden AuthCubit ve ProfileCubit ayrı?
AuthCubit: kimlik (giriş/çıkış, UID).
ProfileCubit: profil verisi (isim, yaş, vibe, fotoğraf).
İkisi farklı sorumluluk — birini değiştirince diğeri etkilenmez.

---

---

## 3. OnboardingCubit

**Dosya:** `lib/features/onboarding/presentation/cubit/onboarding_cubit.dart`

### Ne yönetir?
İlk kurulum sihirbazını. Adım adım ilerleyen form: intro → isim → fotoğraf → yaş → cinsiyet → vibe seçimi → kaydet.

```dart
enum OnboardingStatus { initial, stepChanged, completed, error }

class OnboardingState {
  final int step;          // hangi adımda
  final String name;
  final int? age;
  final String? gender;
  final String? photoUrl;
  final List<String> vibes;
  final String? errorMessage;
}
```

### Adım Mantığı

```
step 0: intro ekranı
step 1: isim girişi
step 2: fotoğraf (opsiyonel)
step 3: yaş seçimi
step 4: cinsiyet seçimi
step 5: vibe seçimi → saveProfile()
```

Her `setXxx()` metodu hem veriyi hem step'i günceller:
```dart
void setName(String name) => emit(state.copyWith(name: name, step: 2));
void setAge(int age)      => emit(state.copyWith(age: age, step: 4));
```

Tek emit'te iki şey değişiyor — bu önemli. Ayrı ayrı emit etseydin
UI iki kez rebuild olur, kullanıcı geçici tutarsız bir ekran görebilirdi.

**`goBack()`**
```dart
void goBack() {
  if (state.step > 0) emit(state.copyWith(step: state.step - 1));
}
```
Negatif step olmaması için guard. `state.step > 0` kontrolü.

**`setPhoto()`**
```dart
Future<void> setPhoto() async {
  if (state.photoUrl == null || state.photoUrl!.isEmpty) {
    emit(state.copyWith(step: 3)); // fotoğraf seçilmediyse atla
    return;
  }
  // fotoğraf varsa önce upload et, sonra adım geç
  final result = await uploadPhotoUsecase.call(uid, state.photoUrl!);
  ...
}
```
Fotoğraf opsiyonel. Seçilmediyse upload yapılmadan sonraki adıma geçer.
Seçildiyse önce Storage'a yükler, URL'i alır, sonra adım geçer.
Neden adım geçmeden önce upload? Kaydetme adımına gelince URL hazır olsun.

**`selectVibe` / `deselectVibe`**
```dart
void selectVibe(String vibe) {
  if (state.vibes.length >= 3) return; // maksimum 3 vibe
  emit(state.copyWith(vibes: [...state.vibes, vibe]));
}
```
`[...state.vibes, vibe]` — spread operatörü ile yeni liste üretir.
Orijinal liste değişmez (immutability korunur).

**`saveProfile()`**
Son adımda lokasyon izni istenir, sonra Firestore'a kaydedilir, `lsc.setOnboardingCompleted()` ile local storage'a "onboarding bitti" işareti konur.
Router bunu görünce bir daha onboarding'e yönlendirmez.

### Neden controller'lar cubit'te?
```dart
final nameController = TextEditingController();
final ageScrollController = FixedExtentScrollController(initialItem: 2);
```
`close()` içinde dispose edilmeleri gerekiyor. Cubit'e bağlıysa `close()` otomatik temizler.
Widget'ta tutulsaydı `StatefulWidget` + `dispose()` gerekirdi.

---

---

## 4. ProfileCubit

**Dosya:** `lib/features/profile/presentation/cubit/profile_cubit.dart`

### Ne yönetir?
Profil sayfasını: mevcut profili gösterme, düzenleme modu, değişiklikleri kaydetme, fotoğraf yükleme, hesap silme.

```dart
enum ProfileStatus { initial, loading, loaded, error, photoUploadError, updatedSuccess }

class ProfileState {
  final UserEntity? user;      // Firestore'dan gelen gerçek veri
  final String editName;       // form'daki anlık değer
  final int editAge;
  final String editGender;
  final List<String> editVibes;
  final bool isEditing;        // düzenleme modu açık mı
  final bool isUploadingPhoto; // yükleme animasyonu için
}
```

### İkili Veri Yapısı: `user` vs `editXxx`

Bu cubit'in en kritik tasarım kararı.

```
user          → Firestore'daki kaydedilmiş gerçek veri
editName      → kullanıcının şu an form'a yazdığı
editAge       → kullanıcının şu an seçtiği
editVibes     → kullanıcının şu an seçtiği
```

**Neden ikisi ayrı?**
Kullanıcı düzenlemeye başlar, yarıda vazgeçer → `user` değişmemiş, `editXxx` değişmiş.
"İptal" butonuna basınca `editXxx`'leri `user`'daki değerlere geri döndürmek yeterli.
Eğer tek state olsaydı "eski haline dön" için Firestore'dan tekrar çekmen gerekirdi.

**`hasChanges` getter:**
```dart
bool get hasChanges =>
    user != null && (
      editName.trim() != user!.name ||
      editAge != user!.age ||
      editGender != user!.gender ||
      !listEquals(
        List<String>.from(editVibes)..sort(),
        List<String>.from(user!.vibes)..sort(),
      )
    );
```
"Kaydet" butonu sadece gerçek bir değişiklik varsa aktif olur.
Vibe listesi sıra bağımsız karşılaştırılıyor (`..sort()`) — sıra fark etmez, içerik fark eder.

**`loadProfile()`**
```dart
emit(ProfileState(
  status: ProfileStatus.loaded,
  user: user,
  editName: user.name,    // editXxx'leri user ile senkronize başlat
  editAge: user.age,
  editGender: user.gender,
  editVibes: List<String>.from(user.vibes),
));
```
`List<String>.from(user.vibes)` — kopyalama kritik. Direkt atansaydı aynı listeye referans olurdu.
`editVibes` değişince `user.vibes` da değişirdi — bu istenmiyor.

**`saveProfile()`**
```dart
// Başarılıysa iki emit:
emit(state.copyWith(status: ProfileStatus.updatedSuccess, user: updatedUser));
emit(state.copyWith(
  status: ProfileStatus.loaded,      // hemen geri dön
  user: updatedUser,
  editXxx: updatedUser.xxx,          // editXxx'leri yeni değerle senkronize et
  isEditing: false,                   // düzenleme modunu kapat
));
```
İlk emit UI'da "başarıyla kaydedildi" gösterir.
İkinci emit normal görünüme döner. Aynı anda ikisi olmaz çünkü Flutter frame'leri sıralar.

**`uploadPhoto()`**
```dart
emit(state.copyWith(isUploadingPhoto: true));  // yükleme animasyonu başlat
// upload yap...
// başarısız:
emit(state.copyWith(status: ProfileStatus.photoUploadError, isUploadingPhoto: false));
emit(state.copyWith(status: ProfileStatus.loaded));  // hata state'ini temizle
// başarılı:
emit(state.copyWith(user: state.user!.copyWith(photoUrl: url), isUploadingPhoto: false));
```
Hata durumunda iki emit var: UI hatayı göstersin, sonra normal modda kalsın.
Tek emit olsaydı kullanıcı sürekli hata ekranında kalırdı.

---

---

## 5. SettingsCubit

**Dosya:** `lib/features/settings/presentation/cubit/settings_cubit.dart`

### Ne yönetir?
Ayarlar sayfasını. Bildirim toggle'ı, hesap silme.

```dart
enum SettingsStatus { initial, loading, loaded, error, saved, accountDeleted }

class SettingsState {
  final bool notificationsEnabled;
  final List<String> selectedVibes; // şu an kullanılmıyor, rezerv
  final String? errorMessage;
}
```

### Metodlar

**`toggleNotifications(bool value)`**
```dart
void toggleNotifications(bool value) {
  emit(state.copyWith(notificationsEnabled: value));
}
```
Senkron, direkt emit. Firestore yazması yok — sadece UI state.
(Local storage entegrasyonu eklenebilir.)

**`deleteAccount()`**
```dart
Future<void> deleteAccount() async {
  final result = await deleteAccountUsecase.call();
  localStorageService.resetOnboarding(); // onboarding tamamlandı bayrağını sıfırla
  result.fold(
    (failure) => emit(state.copyWith(status: SettingsStatus.error, ...)),
    (_) => emit(state.copyWith(status: SettingsStatus.accountDeleted)),
  );
}
```
Neden `resetOnboarding()`? Hesap silinince Firebase Auth UID de gidiyor.
Yeni giriş yapınca yeni UID ile onboarding'den geçilmeli.
`resetOnboarding()` local storage'daki "tamamlandı" bayrağını kaldırır.

### ProfileCubit ile farkı neden?
ProfileCubit profil verisi ve düzenleme UI'ını yönetiyor.
SettingsCubit uygulama ayarlarını ve hesap silmeyi yönetiyor.
Aynı cubit olabilirdi ama sorumluluklar farklı olduğu için ayrıldı.

---

---

## 6. ShakeCubit

**Dosya:** `lib/features/shake/presentation/cubit/shake_cubit.dart`

### Ne yönetir?
Shake algılama, Firestore'a kaydetme, Cloud Function'dan match bekleme, 15 saniyelik timeout.

```dart
enum ShakeCubitStatus { initial, detected, recorded, noMatch, error }

class ShakeState {
  final ShakeCubitStatus status;
  final String? errorMessage;
}
```

### State Akışı

```
initial   → telefon sallanmayı bekliyor
detected  → shake algılandı, Firestore'a yazılıyor
recorded  → shake kaydedildi, Cloud Function'ı bekliyor
noMatch   → 15 saniye doldu, kimse eşleşmedi
error     → bir şeyler ters gitti
```

### `init()`

```dart
void init() {
  reset();
  sl<MatchCubit>().reset();

  sl<ShakeService>().startListening(() async {
    if (state.status != ShakeCubitStatus.initial) return; // GUARD 1
    final hasMatch = await hasActiveMatchUsecase.call(uid); // GUARD 2
    if (hasMatch) return;

    final locationResult = await sl<LocationService>().getCurrentLocation();
    final vibes = sl<ProfileCubit>().state.user?.vibes ?? [];

    recordShake(ShakeEntity(uid, location, vibes, ...));
  });

  sl<MatchCubit>().watchMatch(uid); // aynı anda dinlemeye başla
}
```

**İki guard neden var?**
Guard 1: Zaten kayıt alınıyorsa veya bekliyorsa tekrar kayıt alma.
Accelerometer hassastır, tek sallama birden fazla callback tetikleyebilir.

Guard 2: Aktif match varsa yeni shake engellenir.
İki kişi zaten eşleşmişse tekrar eşleşemezler.

**Neden `MatchCubit.watchMatch` burada başlatılıyor?**
Shake ve match dinleme paralel. Shake kaydedilir kaydedilmez Cloud Function çalışır ve match oluşturabilir. `watchMatch` stream'i açık olmazsa bu match yakalanmaz.

### `startMatchTimer()`

```dart
void startMatchTimer() {
  _matchTimer = Timer(
    const Duration(seconds: AppConstants.matchAcceptanceWindowSeconds),
    () {
      if (!isClosed) emit(state.copyWith(status: ShakeCubitStatus.noMatch));
    },
  );
}
```

Shake kaydedildikten 15 saniye sonra kimse eşleşmediyse `noMatch` emit eder.
UI diyalog gösterir. Kullanıcı tekrar deneyebilir.

### `cancelSearch()`

```dart
Future<void> cancelSearch() async {
  _matchTimer?.cancel();
  await deleteShakeUsecase.call(uid); // Firestore'daki shake'i sil
  init();                              // başa dön
}
```

Kullanıcı "iptal" derse timer durdurulur, Firestore'daki shake silinir (başka biriyle eşleşmesin), cubit sıfırlanır.

### `disposeScreen()`

```dart
void disposeScreen() {
  sl<ShakeService>().stopListening();
  _matchTimer?.cancel();
  deleteShake(uid);
}
```

Match bulununca ShakeCubit artık gerekmez. Match ekranına geçmeden önce çağrılır.
Shake servisi durdurulur, timer iptal edilir, Firestore'daki shake silinir.

---

---

## 7. MatchCubit

**Dosya:** `lib/features/match/presentation/cubit/match_cubit.dart`

### Ne yönetir?
Bir match'in tüm yaşam döngüsünü: bulunma → kabul bekleme → chat → expire → keep connection → kalıcı chat.

```dart
enum MatchCubitStatus {
  initial, loading, found, notFound, error,
  expired,          // chat süresi doldu
  deleted,          // match silindi
  bothKept,         // ikisi de "koru" dedi
  connectionPending,// ben "koru" dedim, diğeri henüz karar vermedi
  acceptancePending,// ben kabul ettim, diğeri henüz kabul etmedi
  accepted,         // ikisi de kabul etti
  cooldownActive,   // rezerv
}
```

### `watchMatch(String uid)` — Merkez Sinir Sistemi

Firestore real-time stream'i dinler. Döküman her değişince bu çalışır:

```
match == null         → deleted  (silindi, stream null emit etti)
match.status expired  → expired / connectionPending / bothKept
match.status active   → found / acceptancePending / accepted
```

**Neden stream, polling değil?**
Polling: "her 2 saniyede Firestore'u sorgula" — gecikme ve maliyet var.
Stream: Firestore değişince anında push edilir — düşük gecikme, düşük maliyet.
İki kullanıcı farklı cihazda. A kabul edince B'nin ekranı milisaniyeler içinde güncelleniyor.

### `_startAcceptTimer(String matchId, DateTime createdAt)`

```dart
void _startAcceptTimer(String matchId, DateTime createdAt) {
  if (_acceptTimer?.isActive == true) return; // idempotent

  final elapsed = DateTime.now().difference(createdAt).inSeconds;
  final remaining = (15 - elapsed).clamp(0, 15);

  if (remaining <= 0) { deleteMatch(matchId); return; }

  _acceptTimer = Timer(Duration(seconds: remaining), () => deleteMatch(matchId));
}
```

`elapsed` hesabı neden kritik?
Match oluştuğunda iki kullanıcının app'i hemen açık olmayabilir.
Arka plandan dönünce 15 saniye değil, gerçekte kalan süre kullanılır.
`createdAt` server timestamp'i olduğu için her iki cihaz için aynı referans.

### `ensureLoaded(String matchId)`

```dart
void ensureLoaded(String matchId) {
  const loaded = { loading, found, expired, connectionPending, bothKept, acceptancePending, accepted };
  if (loaded.contains(state.status)) return;
  getMatch(matchId);
}
```

`ChatExpiredPage` açıldığında match verisi lazım.
Ama watchMatch stream zaten çalışıyor ve state `expired` da olabilir.
Bu metod "zaten yüklüyse tekrar çekme" garantisi — gereksiz Firestore okumayı önler.

### `deleteMatch` vs `endMatch`

```dart
// Kullanıcı aksiyonu — UI hemen güncellenmeli
Future<void> endMatch(String matchId) async {
  await deleteMatchUsecase.call(matchId);
  emit(state.copyWith(status: MatchCubitStatus.deleted)); // direkt emit
}

// Sistem aksiyonu (timer doldu) — stream zaten yakalar
Future<void> deleteMatch(String matchId) async {
  await deleteMatchUsecase.call(matchId);
  // emit yok — watchMatch stream null emit edecek, oradan deleted'a geçer
  emit(const MatchState()); // state'i temizle
}
```

`endMatch`'te neden direkt emit? Kullanıcı "eşleşmeyi bitir" dedi — UI hemen navigasyon yapmalı.
Stream'i bekleseydi Firestore round-trip gecikmesi olurdu (100-300ms).

### Singleton Önemi

MatchCubit uygulama boyunca tek instance (GetIt singleton).
Shake sayfası → match sayfası → chat sayfası → expired sayfası arası geçişlerde
**aynı match state korunuyor**. Her sayfa aynı cubit'i kullandığı için durum kaybolmuyor.

---

---

## 8. ChatCubit

**Dosya:** `lib/features/chat/presentation/cubit/chat_cubit.dart`

### Ne yönetir?
Hem geçici (30 saniyelik) hem kalıcı sohbetleri. Mesaj gönderme, real-time dinleme, geri sayım timer'ı, sohbet listesi, sohbet silme.

```dart
enum ChatStatus {
  initial, loading,
  timerTick,           // her saniye güncellenir (secondsLeft azalır)
  timeExpired,         // geçici chat süresi doldu
  conversationsLoaded, // sohbet listesi hazır
  conversationDeleted, // sohbet silindi
  error,
}

class ChatState {
  final List<MessageEntity> messages;
  final List<ConversationEntity> conversations;
  final int secondsLeft;     // -1 = kalıcı chat (timer yok)
  final String? errorMessage;
}
```

### `initChat(id, fallbackCreatedAt, isPermanent)`

```dart
void initChat(String id, DateTime fallbackCreatedAt, {bool isPermanent = false}) {
  watchMessages(id, isPermanent: isPermanent);
  if (!isPermanent) {
    _startTimer(id, fallbackCreatedAt);
  } else {
    emit(state.copyWith(secondsLeft: -1)); // kalıcı → timer yok
  }
}
```

`isPermanent` tek parametre ile iki farklı mod seçiliyor.
`false` → `chats/{id}/messages` koleksiyonu + geri sayım timer
`true` → `conversations/{id}/messages` koleksiyonu + timer yok

**`fallbackCreatedAt` neden var?**
`chatStartedAt` Firestore'dan asenkron geliyor. Timer hemen kurulursa henüz null olabilir.
`match.createdAt` geçici fallback olarak kullanılır, chatStartedAt gelince gerçek süre hesaplanır.

### `_startTimer` — Her Saniye Firestore Okuma

```dart
_timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  final matchResult = await sl<MatchCubit>().getMatchUsecase.call(matchId);
  matchResult.fold((l) => null, (match) {
    final startTime = match.chatStartedAt ?? fallbackCreatedAt;
    final isWaiting = match.chatStartedAt == null;

    final expireTime = startTime.add(Duration(seconds: chatExpirationSeconds));
    final remaining = expireTime.difference(DateTime.now()).inSeconds;

    if (remaining <= 0) {
      timer.cancel();
      sl<MatchCubit>().expireMatch(matchId);
      emit(state.copyWith(status: ChatStatus.timeExpired));
    } else {
      final display = isWaiting ? chatWaitingDisplaySeconds : remaining;
      emit(state.copyWith(status: ChatStatus.timerTick, secondsLeft: display));
    }
  });
});
```

**Neden her saniye Firestore okuyoruz, stream kullanmıyoruz?**
Timer hesabı için her saniye güncel `chatStartedAt` lazım.
`chatStartedAt` server timestamp'i — her iki kullanıcı sunucudan aynı değeri okuduğu için
tam olarak aynı anda expire oluyorlar. Client saati kullanılsaydı kayma olabilirdi.

**`isWaiting` neden sabit gösteriyor?**
Karşı taraf henüz kabul etmemişse `chatStartedAt` null.
Bu durumda timer sabit `chatWaitingDisplaySeconds` gösteriyor — "hazır olunca başlayacak" hissi.
Gerçek sayım başlamadığından kullanıcıyı yanıltmamak için.

### `watchMessages` — Stream Mantığı

```dart
void watchMessages(String id, {bool isPermanent = false}) {
  emit(state.copyWith(status: ChatStatus.loading));
  _subscription = watchMessagesUsecase.call(id, isPermanent: isPermanent).listen(
    (messages) {
      final currentSeconds = state.status == ChatStatus.timerTick
          ? state.secondsLeft       // timer çalışıyorsa mevcut değeri koru
          : (isPermanent ? -1 : chatWaitingDisplaySeconds);

      emit(state.copyWith(status: ChatStatus.timerTick, messages: messages));
    },
  );
}
```

Yeni mesaj gelince `secondsLeft` korunuyor. Neden?
Mesaj stream'i ve timer bağımsız emit yapıyor.
Yeni mesaj gelince `secondsLeft` sıfırlanmasın — kullanıcı saydacın sıfırlandığını görürdü.

### `sendMessage` — Neden Başarılıda Emit Yok?

```dart
Future<void> sendMessage(String id, MessageEntity message, {bool isPermanent}) async {
  final result = await sendMessageUsecase.call(id, message, isPermanent: isPermanent);
  result.fold(
    (l) => emit(state.copyWith(status: ChatStatus.error, ...)),
    (r) => null,  // başarılıda hiçbir şey yapma
  );
}
```

Mesaj Firestore'a yazılır → `watchMessages` stream'i tetiklenir → messages listesi güncellenir → UI rebuild.
Fazladan emit gerekmez, zaten stream halleder.
Hem de aynı mesajın iki kez görünmesini önler.

### `watchConversations` — Neden `Stream<ChatState>` Dönüyor?

```dart
Stream<ChatState> watchConversations(String uid) {
  return watchConversationsUsecase.call(uid).map((result) => result.fold(...));
}
```

Diğer metodlar `emit` kullanıyor. Bu metod `Stream` dönüyor.
Neden? Sohbet listesi sayfası `StreamBuilder` kullanıyor.
`StreamBuilder` kendi aboneliğini yönetiyor — cubit state'ine gerek yok.
Bu sayede mesaj stream'i ve sohbet listesi stream'i birbirinden bağımsız çalışıyor.

### `deleteConversation`

```dart
Future<void> deleteConversation(String conversationId) async {
  final result = await deleteConversationUsecase.call(conversationId);
  result.fold(
    (l) => emit(state.copyWith(status: ChatStatus.error, ...)),
    (l) => emit(state.copyWith(status: ChatStatus.conversationDeleted)),
  );
}
```

`conversationDeleted` emit edilince `ChatPage` bunu dinler ve `/main/chats`'e navigate eder.
Datasource'da arka planda: alt mesajlar silinir, conversation doc silinir, 24 saat cooldown yazılır.
Cubit bunları bilmez — sadece "başarılı mı, değil mi" bilgisini alır.

---

---

## Cubitler Arası İlişki

```
AuthCubit ─────────────────────────── currentUid sağlar
    │
    ▼
OnboardingCubit ──── saveProfileUsecase ──── Firestore users/{uid}
    │
    ▼ (onboarding tamamlandı)
ProfileCubit ────── loadProfile() ────────── Firestore users/{uid}
    │
    └── state.user?.vibes ──┐
                            │
ShakeCubit ─────────────── vibes'ı shake'e ekler
    │
    └── MatchCubit.watchMatch() başlatır
              │
              ▼ (match bulundu)
         MatchCubit ─── acceptMatch → expireMatch → moveToPermanentChat
              │
              └── ChatCubit._timer her saniye getMatchUsecase çağırır
                       │
                       ▼ (remaining <= 0)
                  expireMatch() → MatchCubit stream yakalar → expired state
```

**Bağımlılık yönü:**
- ShakeCubit → MatchCubit (watchMatch başlatır)
- ChatCubit → MatchCubit (expireMatch çağırır, getMatchUsecase kullanır)
- OnboardingCubit → AuthCubit (currentUid alır)
- ProfileCubit → AuthCubit'e bağımlı değil (uid dışarıdan gelir)

**Neden bu yön?**
Alt seviye cubitler üst seviyeye bağımlı olmamalı.
NavigationCubit hiçbir şeye bağımlı değil.
AuthCubit hiçbir şeye bağımlı değil.
ChatCubit MatchCubit'e bağımlı — bu kabul edilebilir çünkü chat match olmadan var olamaz.

---

## Ortak Tasarım Kararları

| Karar | Neden |
|-------|-------|
| State immutable + copyWith | Flutter diff algoritması çalışsın, gereksiz rebuild olmasın |
| Equatable + props | Aynı değeri emit etmek rebuild tetiklemesin |
| Her cubit kendi usecase'lerini tutar | Katmanlı mimari — Firestore değişse cubit değişmez |
| Singleton cubitler (GetIt) | Sayfalar arası state korunur, aynı stream tekrar açılmaz |
| `close()` her cubit'te temizlik | Timer, stream, controller leak bırakmasın |
| Guard kontrolleri metodların başında | Geçersiz state'te işlem yapılmasın |
