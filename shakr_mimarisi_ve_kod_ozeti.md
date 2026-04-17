# Shakr — Mimari, Kod Yapısı ve Sistem Akışı

Bu doküman Shakr uygulamasını sıfırdan öğrenmek isteyenler için yazılmıştır.
Sadece "ne yapıyor" değil, **"neden böyle yapılmış"** ve **"kod nasıl çalışıyor"** sorularını da yanıtlamaktadır.

---

## İçindekiler

1. [Uygulamanın Vizyonu](#1-uygulamanın-vizyonu)
2. [Proje Klasör Yapısı](#2-proje-klasör-yapısı)
3. [Clean Architecture Nedir ve Neden Kullanılır?](#3-clean-architecture-nedir-ve-neden-kullanılır)
4. [Katmanlar Arası Veri Akışı](#4-katmanlar-arası-veri-akışı)
5. [State Yönetimi — BloC / Cubit](#5-state-yönetimi--bloc--cubit)
6. [Dependency Injection — GetIt](#6-dependency-injection--getit)
7. [Navigasyon — GoRouter](#7-navigasyon--gorouter)
8. [Firebase Veri Modeli](#8-firebase-veri-modeli)
9. [Adım Adım Uygulama Akışı](#9-adım-adım-uygulama-akışı)
   - 9a. Splash ve Kimlik Doğrulama
   - 9b. Onboarding
   - 9c. Shake (Sallama) Akışı
   - 9d. Eşleşme (Match) Akışı
   - 9e. Geçici Sohbet (Chat) Akışı
   - 9f. Kalıcı Sohbete Geçiş
10. [Önemli Tasarım Kararları](#10-önemli-tasarım-kararları)
11. [Güvenlik ve Kalite Mekanizmaları](#11-güvenlik-ve-kalite-mekanizmaları)
    - 11a. Konum Stratejisi ve GPS Fallback
    - 11b. GeoHash ile Coğrafi Eşleşme
    - 11c. Aktif Eşleşme Koruması
    - 11d. Cooldown Mekanizması (24 Saat)
12. [Tasarım Sistemi](#12-tasarım-sistemi)

---

## 1. Uygulamanın Vizyonu

**Ana Fikir:** Kullanıcılar telefonu sallayarak (shake), o an yakınlarında olan ve aynı "vibe"da olan başka bir kişiyle eşleşir. Eşleşme ardından 30 saniyelik bir geçici sohbet başlar. Süre dolduğunda her iki taraf da "Bağlantıyı Koru" seçerse sohbet kalıcı hale gelir.

Bu akış 3 temel ilkeye dayanır:

- **Anlık:** Bekleme süresi yok, telefonu salla, eşleş.
- **Riskli ama heyecanlı:** 30 saniye sınırı gerçek bir baskı yaratır.
- **Çift onay (mutual):** Her iki taraf da onay vermeden kalıcı bağlantı kurulmaz.

---

## 2. Proje Klasör Yapısı

```
lib/
├── main.dart                    ← Uygulamanın giriş noktası
├── common/                      ← Tüm feature'lar tarafından paylaşılan kod
│   ├── constants/               ← AppStrings, AppConstants, AppVibes…
│   ├── getit/injection.dart     ← Dependency Injection (GetIt) kurulumu
│   ├── router/app_router.dart   ← GoRouter route tanımları
│   ├── theme/                   ← AppColors, AppTheme, AppShadows
│   └── widgets/                 ← Paylaşılan UI bileşenleri (VibeChip, SaveButton…)
│
├── core/                        ← Altyapı servisleri
│   ├── error/failures.dart      ← Hata tipleri (NetworkFailure vb.)
│   └── services/
│       ├── shake_service.dart   ← İvmeölçer (accelerometer) yönetimi
│       ├── location_service.dart
│       ├── media_service.dart
│       ├── vibration_service.dart
│       └── local_storage_service.dart
│
└── features/                    ← Özellikler (feature-first organizasyon)
    ├── auth/
    ├── chat/
    ├── main/
    ├── match/
    ├── onboarding/
    ├── profile/
    ├── settings/
    ├── shake/
    └── splash/
```

Her feature içinde aynı yapı tekrarlanır:

```
features/chat/
├── data/
│   ├── datasources/  ← Firebase ile doğrudan konuşan sınıflar
│   ├── models/       ← JSON ↔ Dart dönüşümü yapan sınıflar
│   └── repositories/ ← Repository interface'ini uygulayan sınıflar
├── domain/
│   ├── entities/     ← Saf Dart nesneleri (UI ve iş mantığı için)
│   ├── repositories/ ← Soyut interface (contract)
│   └── usecases/     ← Tek bir iş kuralı = 1 usecase sınıfı
└── presentation/
    ├── cubit/        ← State sınıfları ve iş mantığını UI'a bağlayan Cubit
    ├── pages/        ← Tam ekranlar
    └── widgets/      ← Sayfaya özgü küçük bileşenler
```

---

## 3. Clean Architecture Nedir ve Neden Kullanılır?

Clean Architecture üç temel prensibi uygular:

### Bağımlılık Yönü (Dependency Rule)

İçe doğru bağımlılık kuralı: dıştaki katmanlar içtekilere bağımlıdır, içtekiler dışarıdan haberdar değildir.

```
Presentation  →  Domain  ←  Data
(Cubit/UI)       (Entity,     (Firebase,
                  UseCase)     Model)
```

Domain katmanı (Entity + UseCase) hiçbir Flutter ya da Firebase kütüphanesi import etmez. Bu sayede domain katmanı bağımsız olarak test edilebilir.

### Pratikte Ne Anlama Gelir?

**Örnek:** Mesaj göndermek için kullanılan `SendMessageUsecase`:

```dart
// domain/usecases/send_message_usecase.dart
class SendMessageUsecase {
  final ChatRepository repository;            // sadece interface'i biliyor
  SendMessageUsecase(this.repository);

  Future<Either<Failure, void>> call(
    String chatId,
    MessageEntity message, {
    bool isPermanent = false,
  }) {
    return repository.sendMessage(chatId, message, isPermanent: isPermanent);
  }
}
```

Usecase, Firebase'i, Firestore'u veya HTTP'yi bilmiyor. Sadece `ChatRepository` interface'ine bağımlı. `ChatRepositoryImpl` sınıfı bu interface'i uygular ve asıl Firebase işlemini yapar.

**Neden bu kadar katman?**

- Firebase'i başka bir servisle değiştirmek istersen sadece `data/` katmanını değiştirirsin, UI ve iş mantığı etkilenmez.
- Usecase'leri test ederken gerçek Firebase'e bağlanmak zorunda kalmazsın, mock repository yeterlidir.
- Her sınıfın tek bir sorumluluğu (Single Responsibility) vardır.

---

## 4. Katmanlar Arası Veri Akışı

Kullanıcı bir mesaj gönderdiğinde gerçekte şu olur:

```
ChatScreen (Widget)
    ↓ buton tıklandı
ChatCubit.sendMessageFromInput()
    ↓ MessageEntity oluşturuldu
SendMessageUsecase.call(id, message)
    ↓ ChatRepository.sendMessage() (interface)
ChatRepositoryImpl.sendMessage()
    ↓ hata varsa → Left(Failure)
ChatRemoteDatasource.sendMessage()    ← Firebase ile konuşuyor
    ↓ Firestore'a yazıldı
    ↑ Either<Failure, void> döndü
ChatCubit → emit(state) veya emit(ChatError)
    ↑
ChatScreen → BlocBuilder ile güncel state'i render ediyor
```

Her katman bir öncekinden sadece kendi beklediği tipi alır; Firestore `DocumentSnapshot`'ı doğrudan UI'a hiçbir zaman ulaşmaz.

---

## 5. State Yönetimi — BloC / Cubit

Cubit, BloC'un basitleştirilmiş versiyonudur. Event sınıfı yoktur; metod çağrısı yaparsın, o da `emit()` ile yeni bir state yayınlar. UI bu state'i `BlocBuilder` veya `BlocListener` ile dinler.

### ChatCubit Örneği

```dart
class ChatCubit extends Cubit<ChatState> {
  Timer? _timer;
  StreamSubscription? _subscription;

  ChatCubit(...) : super(ChatInitial());

  void initChat(String id, DateTime fallback, {bool isPermanent = false}) {
    watchMessages(id, isPermanent: isPermanent);
    if (!isPermanent) {
      _startTimer(id, fallback);
    } else {
      emit(ChatTimerTickState(-1, []));   // Kalıcı sohbette timer yok
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();          // Memory leak önleme
    _subscription?.cancel();
    messageController.dispose();
    return super.close();
  }
}
```

### State Hiyerarşisi

```dart
abstract class ChatState {}

class ChatInitial      extends ChatState {}
class ChatLoading      extends ChatState {}
class ChatTimerTickState extends ChatState {
  final int secondsLeft;
  final List<MessageEntity> messages;
}
class ChatTimeExpiredState extends ChatState {}
class ChatError        extends ChatState { final String message; }
```

UI'da kullanımı:

```dart
BlocListener<ChatCubit, ChatState>(
  listener: (context, state) {
    if (state is ChatTimeExpiredState) {
      context.go('/chat-expired/$matchId');
    }
  },
  child: BlocBuilder<ChatCubit, ChatState>(
    builder: (context, state) {
      if (state is ChatTimerTickState) {
        return ChatBody(
          messages: state.messages,
          secondsLeft: state.secondsLeft,
        );
      }
      return const LoadingWidget();
    },
  ),
)
```

`BlocListener` yan etkileri (navigasyon, snackbar) için; `BlocBuilder` sadece UI render için kullanılır.

---

## 6. Dependency Injection — GetIt

`GetIt` bir service locator kütüphanesidir. Uygulama başlarken tüm bağımlılıklar tek bir yerde kayıt edilir ve sonra her yerden `sl<TürAdı>()` ile erişilir.

```dart
// lib/common/getit/injection.dart (özetlenmiş)
final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Servisler (Singleton — tek bir örnek uygulama boyunca yaşar)
  sl.registerLazySingleton<VibrationService>(() => VibrationService());
  sl.registerLazySingleton<ShakeService>(() => ShakeService());

  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Datasources
  sl.registerLazySingleton(() => ChatRemoteDatasource(db: sl()));

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => SendMessageUsecase(sl()));

  // Cubits (Factory — her çağrıda yeni örnek)
  sl.registerFactory(() => ChatCubit(
    sendMessageUsecase: sl(),
    watchMessagesUsecase: sl(),
    ...
  ));
}
```

`registerLazySingleton` → ilk çağrıda oluştur, sonraki çağrılarda aynı örneği ver.  
`registerFactory` → her çağrıda yeni örnek oluştur (Cubit'ler için ideal, her ekranda taze state başlar).

---

## 7. Navigasyon — GoRouter

GoRouter, URL tabanlı navigasyon sağlar. Her route bir path ile tanımlanır.

```dart
// common/router/app_router.dart (özetlenmiş)
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',           builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/shaking',    builder: (_, __) => const ShakingScreen()),
    GoRoute(
      path: '/chat/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        final isPermanent = state.uri.queryParameters['permanent'] == 'true';
        final extra = state.extra as DateTime?;
        return ChatScreen(
          matchId: matchId,
          isPermanent: isPermanent,
          fallbackCreatedAt: extra ?? DateTime.now(),
        );
      },
    ),
  ],
);
```

**Path parametresi** → dinamik değerler için (`/chat/:matchId`)  
**Query parametresi** → opsiyonel bayraklar için (`?permanent=true&name=Ali`)  
**Extra** → Dart nesnesi geçirmek için (URL'e yazılamayan `DateTime` gibi)

---

## 8. Firebase Veri Modeli

```
Firestore
├── users/{uid}
│       uid, name, age, gender, photoUrl, vibes[]
│
├── shakes/{uid}                  ← Geçici, eşleşme beklenirken
│       location (GeoPoint), status, timestamp
│
├── matches/{matchId}             ← Eşleşme ve geçici sohbet meta verisi
│       user1, user2, users[]     ← "users" array Firebase arrayContains sorgusu için
│       user1Accepted, user2Accepted
│       user1KeepConnection, user2KeepConnection
│       chatStartedAt (her ikisi kabul ettiğinde set edilir)
│       status: 'active' | 'expired'
│
├── chats/{matchId}/messages/{msgId}   ← Geçici mesajlar
│       senderId, text, createdAt
│
└── conversations/{convId}             ← Kalıcı sohbet (matchId ile aynı ID)
        participants[], user1, user2
        user1Name, user2Name, user1Photo, user2Photo  ← Denormalize (hızlı okuma)
        user1Vibes[], user2Vibes[]
        lastMessage, lastMessageAt
        └── messages/{msgId}
                senderId, text, createdAt
```

**Neden denormalize?**  
`conversations` dokümanına kullanıcı adı ve fotoğrafı kopyalanmıştır. Sohbet listesi yüklenirken her kullanıcı için ayrıca `users/{uid}` dokümanı çekmek yerine tek sorguda tüm bilgiler gelir. Firestore'da JOIN yoktur; bu yüzden sık okunan veriler tekrarlanır.

---

## 9. Adım Adım Uygulama Akışı

### 9a. Splash ve Kimlik Doğrulama

```
SplashScreen açılır
    ↓ 3 saniye bekle
AuthCubit.getCurrentUser()
    ├── Kullanıcı zaten var → profilini getir
    │       ├── Profil tamamlanmış → /main/shake
    │       └── Profil eksik     → /onboarding
    └── Kullanıcı yok → signInAnonymously()
            └── Yeni UID oluşturuldu → /onboarding
```

Uygulama anonim kimlik doğrulaması kullanır. Kullanıcı bir form doldurmadan önce bile Firebase'de bir hesabı vardır. Onboarding tamamlandığında profil bu anonim UID'e yazılır.

---

### 9b. Onboarding

5 bağımsız adım vardır; her adım ayrı bir widget'tır:

```
NameStep → PhotoStep → AgeStep → GenderStep → VibesStep
```

Her adım `OnboardingCubit.nextStep()` çağrısıyla ilerler. Son adımda `AuthCubit.saveProfile()` çağrılır ve `users/{uid}` dokümanı yazılır.

Vibe seçimi (`VibesStep`) tam olarak 3 seçim zorunludur (`AppStrings.selectThree`). Bu kural `OnboardingCubit` içinde kontrol edilir.

---

### 9c. Shake (Sallama) Akışı

```
ShakingScreen açılır
    ↓
ShakeCubit.init()
    ├── ShakeService.startListening()     → ivmeölçer aboneliği başlar
    ├── MatchCubit.watchMatch(uid)        → Firestore stream başlar
    └── _radarTimer başlar                → radar animasyonu (16ms tick)

Kullanıcı telefonu sallar (ivme > 15.0 m/s²)
    ↓
ShakeCubit.recordShake()
    ├── LocationService.getCurrentLocation()  (5 sn timeout)
    ├── Firestore'a yaz: shakes/{uid} = { location, status: 'waiting' }
    ├── VibrationService.shakeDetectedFeedback()
    └── 15 saniyelik eşleşme timer'ı başlar

Paralel süreç: Cloud Function veya başka bir kullanıcının shake kaydı
    → matches/{matchId} oluşturulur
    → MatchCubit stream bunu yakalar → MatchFound state'i
    → /match/:matchId'ye yönlendir

15 saniye doldu, eşleşme yok
    → ShakeNoMatch state → dialog göster
```

**ShakeService nasıl çalışır?**

```dart
// core/services/shake_service.dart
class ShakeService {
  static const double _shakeThreshold = 15.0;
  StreamSubscription? _subscription;

  void startListening(VoidCallback onShake) {
    _subscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x +
        event.y * event.y +
        event.z * event.z,
      );
      if (magnitude > _shakeThreshold) {
        onShake();
      }
    });
  }
}
```

İvmeölçer 3 eksendeki ivmeyi verir. Bunların karekök toplamı (vektör büyüklüğü) eşiği aşarsa kullanıcı sallamış kabul edilir.

---

### 9d. Eşleşme (Match) Akışı

```
MatchFoundScreen (/match/:matchId) açılır
    ↓
MatchCubit.watchMatch(uid) hâlâ dinliyor
Ekranda: eşleşilen kişinin vibe'ları + 15 saniyelik geri sayım

Kullanıcı "Hemen Sohbete Başla" butonuna basar
    ↓
MatchCubit.acceptMatch(matchId, uid)
    ├── Firestore'dan match dokümanı okunur
    ├── user1Accepted veya user2Accepted = true yazılır
    └── Diğer kullanıcı da kabul ettiyse: chatStartedAt = serverTimestamp()

Sadece bu kullanıcı kabul etti
    → MatchAcceptancePending state → "Karşı taraf bekleniyor" mesajı

Her iki kullanıcı da kabul etti (stream üzerinden gelir)
    → MatchAccepted state
    → VibrationService.matchAcceptedFeedback()
    → /chat/:matchId 'ye yönlendir, extra: match.createdAt
```

**Zaman hesabı neden `createdAt`'e göre değil `chatStartedAt`'e göre?**  
İki kullanıcı farklı zamanlarda "Kabul Et" butonuna basabilir. Sürenin her ikisi de kabul ettiği andan itibaren başlaması adil bir deneyim sağlar. `chatStartedAt` sunucu zaman damgası (serverTimestamp) ile yazılır, saat dilimi farklılıklarından etkilenmez.

---

### 9e. Geçici Sohbet (Chat) Akışı

```
ChatScreen (/chat/:matchId) açılır
    ↓
ChatCubit.initChat(matchId, fallbackCreatedAt, isPermanent: false)
    ├── watchMessages(matchId)           → messages stream başlar
    └── _startTimer(matchId, fallback)   → 1 saniyelik periyodik timer

Her saniye timer tetiklenir:
    ├── getMatch(matchId) → Firestore'dan güncel match çekilir
    ├── expireTime = chatStartedAt + 30 saniye
    ├── remaining = expireTime - şimdi
    ├── remaining > 0  → emit(ChatTimerTickState(remaining, messages))
    └── remaining <= 0 → timer.cancel()
                       → matchCubit.expireMatch(matchId)  ← Firestore güncellenir
                       → emit(ChatTimeExpiredState)
                       → /chat-expired/:matchId 'ye yönlendir

Kullanıcı mesaj yazar ve gönderir:
    ChatCubit.sendMessageFromInput()
    ├── text.trim().isEmpty → return (boş mesaj engellenir)
    ├── UUID ile MessageEntity oluşturulur
    └── chats/{matchId}/messages/{uuid} = { senderId, text, createdAt }
```

**Neden her saniye Firestore okunuyor?**  
`chatStartedAt` alanı her iki kullanıcı kabul ettiğinde sunucudan yazılır. Timer başladığında bu alan henüz null olabilir. Bu durumda `isWaiting = true` ve ekranda `300` (max süre) gösterilir, süre akmaz. Firestore stream yerine polling kullanılmasının nedeni `chatStartedAt`'in kesin değerini yakalamaktır.

---

### 9f. Kalıcı Sohbete Geçiş

```
ChatExpiredScreen (/chat-expired/:matchId) açılır
    ↓
MatchCubit.ensureLoaded(matchId)  → match okunur
MatchCubit.watchMatch stream dinleniyor

Kullanıcı A "Bağlantıyı Koru" seçer:
    keepConnection(matchId, uid)
    → matches/{matchId}.user1KeepConnection = true
    → MatchConnectionPending state → "Karşı tarafı bekliyoruz" snackbar

Kullanıcı B de "Bağlantıyı Koru" seçer:
    → matches/{matchId}.user2KeepConnection = true
    → Firestore'da her ikisi de true → stream her iki tarafta MatchBothKept yayar

MatchBothKept state'inde:
    MatchCubit.moveToPermanentChat(matchId)
        ├── matches/{matchId} okunur (user1, user2, vibes)
        ├── chats/{matchId}/messages tüm mesajlar çekilir
        ├── users/{u1} ve users/{u2} dokümanları okunur (isim, fotoğraf)
        ├── conversations/{matchId} oluşturulur (metadata + denormalize bilgiler)
        ├── Batch: tüm mesajlar conversations/{matchId}/messages'a kopyalanır
        └── deleteMatch(matchId) → eski match + chats silinir

    → "Bağlantı kalıcı hale getirildi! 🎉" snackbar
    → /main/chats 'e yönlendir

Bir kullanıcı "Sohbeti Bitir" seçer:
    endMatch(matchId)
    → match + chats silinir
    → MatchExpired state → "Maalesef bağınız koptu 💔" snackbar
    → /main/shake 'e yönlendir
```

**Denormalize etme kararı:**  
`conversations` dokümanına `user1Name`, `user2Name`, `user1Photo`, `user2Photo` alanları kopyalanır. Böylece sohbet listesi ekranında her sohbet için ayrıca `users/{uid}` çekmek gerekmez, tek Firestore sorgusu yeterlidir.

---

## 10. Önemli Tasarım Kararları

### Either<Failure, T> — Güvenli Hata Yönetimi

Repository ve usecase'ler exception fırlatmak yerine `Either<Failure, T>` döndürür. Bu Haskell'den gelen bir fonksiyonel programlama konseptidir.

```dart
// Başarılıysa Right(data), hatalıysa Left(failure) döner
Future<Either<Failure, void>> sendMessage(...) async {
  try {
    await datasource.sendMessage(...);
    return const Right(null);
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}

// Cubit'te kullanımı:
result.fold(
  (failure) => emit(ChatError(failure.message)),   // Left
  (_) => null,                                      // Right → başarı
);
```

Bu pattern sayesinde:

- Beklenmediği yerde exception fırlamaz.
- Hata yönetimi zorunlu hale gelir (her `fold` çağrısı her iki durumu da handle etmek zorundadır).
- Hata türleri (`NetworkFailure`, `NotFoundFailure`, `UnexpectedFailure`) ayrıştırılabilir.

---

### Radar Animasyonu — ValueNotifier ile Timer

Radar animasyonu BloC'a bağlanmamış, doğrudan `ValueNotifier<double>` kullanır. Nedeni: saniyede 60 kare render için state emit etmek gereksiz yeniden çizime yol açar.

```dart
// shake_cubit.dart
final radarProgress = ValueNotifier<double>(0.0);

_radarTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
  radarProgress.value = (radarProgress.value + 16 / 3000) % 1.0;
  // 16ms / 3000ms = her tick'te ilerleme miktarı
  // % 1.0 = 0-1 arasında döngüsel değer
});

// Widget'ta kullanımı:
ValueListenableBuilder<double>(
  valueListenable: shakeCubit.radarProgress,
  builder: (_, progress, __) => RadarPainter(progress: progress),
)
```

`RadarPainter` sadece `progress` değiştiğinde yeniden çizilir, cubit'in diğer state değişikliklerinden bağımsızdır.

---

### Modüler Widget Yaklaşımı

Büyük sayfalar küçük, tek sorumluluğu olan widget'lara bölünmüştür:

```
ChatScreen (page)
├── ChatTimerTitle       ← Sadece geri sayımı gösterir
├── MessageList          ← Sadece mesajları listeler
├── MessageInputBar      ← Sadece yazma alanı
└── ChatAppBar           ← Başlık + "Eşleşmeyi Bitir" butonu
```

Bu ayrım sayesinde:

- Her widget bağımsız test edilebilir.
- Bir bileşeni değiştirmek diğerlerini etkilemez.
- Büyük sayfalar (500+ satır) oluşmaz.

---

## 11. Güvenlik ve Kalite Mekanizmaları

Bu bölüm sonradan eklenen — ama uygulamanın doğru çalışması için kritik olan — dört mekanizmayı açıklamaktadır.

---

### 11a. Konum Stratejisi ve GPS Fallback

**Problem:** Kullanıcı GPS iznini reddederse `GeoPoint` döndürülemiyor ve shake kaydedilemiyordu.

**Çözüm:** İki katmanlı konum stratejisi. `LocationService.getCurrentLocation()` artık `LocationResult` döndürüyor:

```dart
class LocationResult {
  final GeoPoint location;
  final bool isFallback;   // true → GPS reddedildi, IP bazlı şehir konumu kullanıldı
}
```

Akış:

```
GPS izni var?
  ├─ EVET → Geolocator ile yüksek hassasiyetli konum (±10m)
  └─ HAYIR → http://ip-api.com/json/ ile şehir düzeyinde konum (±5km)
             → isFallback = true
```

`ShakeCubit`, fallback olduğunda `ShakeRecorded(isFallbackLocation: true)` emit eder. `ShakingScreen`'deki `BlocListener` bunu yakalar ve kullanıcıya Snackbar gösterir:

```
"GPS erişimin yok — şehir düzeyinde konum kullanılıyor.
 Eşleşme daha az hassas olabilir."
```

Kullanıcı bilgilendirilir ama uygulama bloke olmaz — sallama akışı devam eder.

---

### 11b. GeoHash ile Coğrafi Eşleşme

**Problem:** Firestore'da "bana yakın kullanıcıları bul" sorgusu doğrudan `GeoPoint` ile yapılamaz. Firestore compound query desteklemediği için hem enlem hem boylam aralığı filtrelenemez.

**Çözüm:** [GeoHash](https://en.wikipedia.org/wiki/Geohash) algoritması. Konum, hiyerarşik bir string'e dönüştürülür.

```
Enlem 41.0082, Boylam 28.9784 (İstanbul)
  → GeoHash precision 7 = "sxk9zue"
```

GeoHash'in anahtarı şu: **aynı prefix'i paylaşan iki hash yakın konumdadır.**

```
"sxk9zue" ile "sxk9zu8" → aynı ~153m hücre içinde
"sxk9zue" ile "u4pruyd" → farklı kıtalar
```

Precision 7 ≈ 153m × 153m hücre büyüklüğü sağlar. Bu, Shakr için ideal: aynı kafede, sokakta veya meydanda olan kullanıcılar aynı ya da komşu hücrelerdedir.

`GeoHashUtils.encode()` tek bir utility class olarak uygulandı:

```dart
// core/utils/geohash_utils.dart
static String encode(double lat, double lng, {int precision = 7}) {
  // Standart GeoHash algoritması: lng/lat bitleri dönüşümlü encode edilir
  // 5 bit → 1 base32 karakter
  // 7 karakter × 5 bit = 35 bit toplam
  ...
}
```

`ShakeRemoteDatasource.recordShake()` her shake kaydedildiğinde GeoHash'i hesaplar ve Firestore'a yazar:

```dart
final geohash = GeoHashUtils.encode(shake.location.latitude, shake.location.longitude);
await db.collection('shakes').doc(shake.uid).set({
  ...shakeModel.toMap(),
  'geohash': geohash,        // "sxk9zue" formatında
});
```

Cloud Function bu `geohash` alanını kullanarak `prefix` sorgusu yapar:

```
geohash >= "sxk9z"  AND  geohash <= "sxk9z~"
```

Bu, `startAt` / `endAt` ile Firestore'da etkin bir coğrafi arama sağlar.

---

### 11c. Aktif Eşleşme Koruması

**Problem:** İki kullanıcı birbirini kabul etti ve chat ekranına geçti. Birisi "Salla" sekmesine döndüğünde `ShakeCubit.init()` çalışır ve `MatchCubit.reset()` çağrılır — yani aktif eşleşme sıfırlanır. Kullanıcı tekrar sallarsa aynı kişiyle yeni bir eşleşme oluşabilir.

**Çözüm:** `ShakeCubit`, sallama dinleyicisi tetiklenmeden önce doğrudan Firestore'u sorgulayan `HasActiveMatchUsecase` çağırır:

```dart
// ShakeCubit.init() içindeki shake callback:
sl<ShakeService>().startListening(() async {
  // 1. Aktif eşleşme kontrolü (Firestore sorgusu)
  final hasMatch = await hasActiveMatchUsecase.call(uid);
  if (hasMatch) return;   // ← Yeni shake kaydedilmez

  // 2. Konum al
  final locationResult = await sl<LocationService>().getCurrentLocation();

  // 3. Shake kaydet
  recordShake(...);
});
```

`HasActiveMatchUsecase` → `ShakeRepository.hasActiveMatch()` → `ShakeRemoteDatasource`:

```dart
Future<bool> hasActiveMatch(String uid) async {
  final snapshot = await db
      .collection('matches')
      .where('users', arrayContains: uid)
      .where('status', isEqualTo: 'active')
      .limit(1)
      .get();
  return snapshot.docs.isNotEmpty;
}
```

**Neden Firestore sorgusu, Cubit state kontrolü değil?**
Cubit state'i `reset()` çağrısıyla temizlenmiş olabilir. Firestore doğrudan gerçeği tutar. State bellekte yaşar ve geçersiz kalabilir; Firestore her zaman günceldir.

---

### 11d. Cooldown Mekanizması (24 Saat)

**Problem:** Aynı iki kullanıcı chat yaptıktan sonra tekrar sallayıp eşleşebiliyordu. Bu hem gerçekçi değil (tesadüfi olmaktan çıkıyor) hem de spam riski yaratıyor.

**Çözüm:** `matchCooldowns` koleksiyonu. İki kullanıcı birbirleriyle chat yaptıktan sonra bu koleksiyona 24 saatlik bir kayıt eklenir.

#### Cooldown Anahtarı

```dart
String _cooldownKey(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}
```

UID'ler her zaman alfabetik sırayla birleştirilir. Bu sayede "A_B" ve "B_A" sorunu yaşanmaz — her çift için tek bir doküman vardır.

```
matchCooldowns/"abc123_xyz789"
  → user1: "abc123"
  → user2: "xyz789"
  → expiresAt: (şimdi + 24 saat)
```

#### Ne Zaman Yazılır?

**1. `deleteMatch()` — Chat sonrası eşleşme silme:**

```dart
Future<void> deleteMatch(String matchId) async {
  final data = matchDoc.data()!;
  // chatStartedAt varsa = her iki kullanıcı da chat ekranına girmiş
  if (data['chatStartedAt'] != null) {
    await writeCooldown(u1, u2);   // ← cooldown yaz
  }
  await _hardDeleteMatch(matchId);
}
```

**2. `moveToPermanentChat()` — Kalıcı sohbete geçiş:**

```dart
Future<void> moveToPermanentChat(String matchId) async {
  await writeCooldown(u1, u2);   // ← kalıcı hale gelenler de cooldown'a girer
  ...
}
```

Kapsanan senaryolar:

- ✅ 30 saniye bitti, biri "Bitir" seçti → `deleteMatch` + cooldown
- ✅ İkisi de "Bağlantıyı Koru" seçti → `moveToPermanentChat` + cooldown
- ❌ 15 saniye dolmadan kabul penceresi kapandı → cooldown yazılmaz (chat olmadı)
- ❌ Biri "Kabul Et" basmadı → cooldown yazılmaz

#### Eşleşme Geldiğinde Kontrol

`MatchRemoteDatasource.watchMatch()` artık `asyncMap` kullanıyor. Her yeni eşleşme dokümanı geldiğinde, henüz kimse "Kabul Et" basmamışsa cooldown kontrolü yapılır:

```dart
.asyncMap((snapshot) async {
  ...
  // Sadece taze match için kontrol et (kimse henüz kabul etmedi)
  if (match.status == MatchStatus.active &&
      !match.user1Accepted &&
      !match.user2Accepted) {
    final inCooldown = await isCooldownActive(match.user1Id, match.user2Id);
    if (inCooldown) {
      await _hardDeleteMatch(match.matchId);   // sessizce sil
      return null;                              // stream'e null gönder
    }
  }
  return match;
})
```

Stream `null` alınca `MatchCubit` `MatchDeleted` emit eder. `ShakingScreen`'de `MatchCooldownActive` state için bir Snackbar gösterilir:

```
"Bu kişiyle yakın zamanda eşleştin. 24 saat sonra tekrar dene."
```

#### `.map` yerine `.asyncMap` — Neden?

Firestore stream'leri normalde `.map()` ile dönüştürülür. Ama `.map()` senkron çalışır; içinde `await` kullanamazsın. Cooldown kontrolü async bir Firestore okuması gerektirdiği için `.asyncMap()` kullanılır.

```dart
// .map → senkron, await yok
.map((snapshot) => processSync(snapshot))

// .asyncMap → async, await kullanılabilir
.asyncMap((snapshot) async {
  final result = await asyncCheck();
  return result;
})
```

Dezavantajı: her stream event için bir Firestore okuma yapılır. Pratikte bu kabul edilebilir çünkü yeni bir eşleşme nadiren gelir ve cooldown kontrolü küçük bir dokümandır.

---

## 12. Tasarım Sistemi

```dart
// common/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF...);

  // 10 ton palet
  static const Color primary50  = Color(0xFF...);
  static const Color primary100 = Color(0xFF...);
  // ...

  // Tema duyarlı renkler (light/dark)
  static Color textPrimary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black87;
}

// common/theme/app_shadows.dart
class AppShadows {
  static List<BoxShadow> soft   = [...];  // Hafif derinlik
  static List<BoxShadow> medium = [...];  // Orta derinlik
  static List<BoxShadow> upward = [...];  // Yukarı doğru gölge (card efekti)
}
```

Tüm UI bileşenleri bu sabitler üzerinden tanımlanır; hiçbir widget içine `Color(0xFF...)` gibi ham değer yazılmaz.

---

## Sonuç

Shakr'ın mimarisini 3 cümleyle özetlemek gerekirse:

> **"Clean Architecture + Cubit"** iş mantığını UI'dan ayırır.  
> **"Firebase Streams"** gerçek zamanlı eşleşme ve mesajlaşmayı sağlar.  
> **"Denormalizasyon"** sık okunan verileri hızlı getirir, Firestore okuma maliyetini düşürür.

Bu üç kararın kombinasyonu, hem ölçeklenebilir hem de bakımı kolay bir kod tabanı oluşturur.
