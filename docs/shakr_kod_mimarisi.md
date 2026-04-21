# Shakr — Kod Mimarisi ve Akış Özeti

## Genel Bakış

Shakr, kullanıcıların telefonlarını sallayarak yakınlarındaki kişilerle eşleştiği sosyal bir Flutter uygulamasıdır. Backend olarak Firebase (Auth + Firestore) kullanılmaktadır.

---

## Mimari Yapı

Uygulama **Clean Architecture** prensiplerine göre özellik (feature) bazında yapılandırılmıştır:

```
lib/
├── common/          # Paylaşılan sabitler, tema, widget'lar, yönlendirme
│   ├── constants/   # AppStrings, AppColors, AppSpacing, AppDimensions...
│   ├── getit/       # Dependency injection (GetIt)
│   ├── router/      # GoRouter tanımları
│   ├── theme/       # AppTheme, AppColors, AppShadows
│   └── widgets/     # VibeChip, VibeCard, CustomSnackBar, SaveButton
├── core/            # Platformdan bağımsız servisler
│   ├── services/    # LocationService, ShakeService, VibrationService...
│   ├── error/       # Failure sınıfları
│   └── models/      # LocationResult
└── features/        # Her özellik kendi klasöründe
    ├── auth/
    ├── splash/
    ├── onboarding/
    ├── main/
    ├── shake/
    ├── match/
    ├── chat/
    ├── profile/
    └── settings/
```

Her feature klasörü şu katmanlara sahiptir:

| Katman | Sorumluluk |
|--------|-----------|
| `domain/entities` | Saf Dart veri modelleri (UI veya Firebase bağımlılığı yok) |
| `domain/repositories` | Soyut repository interface'leri |
| `domain/usecases` | Tek bir iş kuralını çalıştıran sınıflar |
| `data/models` | Entity'den türeyen, Firestore serialization içeren modeller |
| `data/datasources` | Firebase/HTTP çağrılarını yapan sınıflar |
| `data/repositories` | Repository impl; datasource'u sarar, hataları `Either<Failure, T>` ile döner |
| `presentation/cubit` | State yönetimi (flutter_bloc) |
| `presentation/pages` | Ekranlar — sadece Scaffold + listener barındırır |
| `presentation/widgets` | UI parçaları — sadece çizim yapar, iş mantığı içermez |

---

## Dependency Injection

`lib/common/getit/injection.dart` içindeki `initDependencies()` fonksiyonu uygulama başlarken çağrılır.

- **`registerLazySingleton`** — uygulama boyunca tek örnek (Firebase, servisler, cubit'ler)
- **`registerFactory`** — her istekte yeni örnek (OnboardingCubit, ProfileCubit, SettingsCubit)

Widget'lar `sl<T>()` ile bu nesnelere erişir.

---

## Uygulama Başlangıç Akışı

```
main() → initDependencies() → runApp(MyApp)
       → GoRouter → '/' → SplashScreen
```

### SplashScreen
1. `sl<AuthCubit>().getCurrentUser()` çağrılır.
2. Firebase'de mevcut kullanıcı varsa `AuthStatus.success` emit edilir; yoksa anonim giriş yapılır (`signInAnonymously`).
3. `LocalStorageService.isOnboardingCompleted()` kontrol edilir.
4. `AppConstants.splashDelaySeconds` (3sn) beklenir.
5. Onboarding tamamlandıysa `/main/shake`, tamamlanmadıysa `/onboarding` yönlendirilir.

**Neden anonim giriş?** Kullanıcının herhangi bir hesap oluşturmasına gerek kalmadan hemen kullanmaya başlaması için. UID, shake ve eşleşme kayıtlarında kimlik olarak kullanılır.

---

## Onboarding Akışı

`/onboarding` → `OnboardingScreen` → `OnboardingBody` → adım widget'larına yönlendirir.

### Adımlar (OnboardingCubit.step)

| Step | Widget | Açıklama |
|------|--------|----------|
| 0 | `IntroStep` | 4 slaytlık tanıtım carousel'ı |
| 1 | `NameStep` | İsim girişi |
| 2 | `PhotoStep` | Profil fotoğrafı yükleme |
| 3 | `AgeStep` | CupertinoPicker ile yaş seçimi |
| 4 | `GenderStep` | Cinsiyet seçimi |
| 5 | `VibeStep` | Tam 3 vibe seçimi |

### OnboardingCubit Mantığı

- **State**: `OnboardingStepChanged` — tüm form alanlarını (name, age, gender, photo, vibes, step) tek bir değişmez (immutable) state nesnesinde taşır.
- Her `set*` metodu mevcut state'i `copyWith` ile kopyalayıp `step` değerini artırır → otomatik sayfa geçişi sağlar.
- `setPhoto()`: Eğer fotoğraf seçildiyse `UploadPhotoUsecase` ile Firebase Storage'a yükler, dönen URL'i state'e yazar.
- `saveProfile()`: Son adımda önce konum izni ister, sonra `SaveProfileUsecase` ile profili Firestore'a yazar, ardından `LocalStorageService.setOnboardingCompleted()` ile onboarding'i tamamlandı işaretler → `OnboardingCompleted` emit eder → router `/main/shake`'e yönlendirir.

**Neden CupertinoPicker?** iOS tarzı kaydırmalı seçici daha iyi bir yaş seçimi deneyimi sunar; `FixedExtentScrollController(initialItem: 2)` ile başlangıç değeri 20 (minAge=18 + index=2) olarak ayarlanır.

---

## Ana Ekran (Main)

`/main/*` → `MainScreen` → `IndexedStack` + `MainBottomNav`

3 tab **IndexedStack** ile tutulur — her tab canlı kalır, yeniden build olmaz:
- Index 0: `ShakingScreen`
- Index 1: `MyChatsScreen`
- Index 2: `ProfileScreen`

`NavigationCubit` aktif tab index'ini yönetir. Tab 0'a geçişte `ShakeCubit.init()` çağrılarak shake dinleyicisi yeniden başlatılır.

---

## Shake & Eşleşme Akışı

### ShakeCubit

```
init()
  → ShakeService.startListening(callback)
  → MatchCubit.watchMatch(uid)    ← Firestore stream başlar

callback() tetiklendiğinde:
  → HasActiveMatchUsecase ile aktif eşleşme var mı kontrol edilir
  → LocationService.getCurrentLocation() ile konum alınır
  → RecordShakeUsecase → Firestore'a shake kaydı yazılır
  → ShakeRecorded emit edilir
  → startMatchTimer() (AppConstants.matchAcceptanceWindowSeconds = 15sn)
```

**Neden 15 saniyelik timer?** Eğer süre içinde Firestore'dan bir eşleşme gelmezse `ShakeNoMatch` emit edilip kullanıcıya kimse bulunamadı mesajı gösterilir.

### ShakeRemoteDatasource — Eşleşme Mantığı

`recordShake()` fonksiyonu Firestore transaction'ı ile çalışır:

1. `shakes` koleksiyonuna `{uid, location, geohash, status: 'waiting', timestamp}` yazar.
2. Aynı koleksiyonda bekleyen başka bir kullanıcı (`status: 'waiting'`, farklı UID) arar.
3. Bulursa:
   - Her iki shake kaydını `status: 'active'` olarak günceller.
   - `matches` koleksiyonuna `{user1Id, user2Id, vibes, status: 'active', createdAt}` yazar.

**Neden geohash?** Coğrafi yakınlık sorgusunu Firestore'da yapabilmek için lat/lon çifti geohash'e dönüştürülür ve prefix ile sorgu yapılır.

### MatchCubit — watchMatch()

Firestore'daki match dokümanını stream olarak dinler. Gelen değişikliklere göre state geçişleri:

| Firestore durumu | State |
|-----------------|-------|
| match.status = 'active', ikisi de kabul etmedi | `MatchFound` + `_startAcceptTimer` |
| Ben kabul ettim, karşı taraf bekliyor | `MatchAcceptancePending` |
| İkisi de kabul etti | `MatchAccepted` → `/chat/:matchId` |
| match.status = 'expired' | `MatchExpired` veya `MatchConnectionPending` |
| Doküman silindi | `MatchDeleted` |

`_startAcceptTimer()`: createdAt'den geçen süreyi hesaplayıp kalan süre kadar timer başlatır. Süre dolunca `deleteMatch()` çağrılır.

**Neden stream?** İki farklı cihazdaki kullanıcının kararları gerçek zamanlı senkronize edilmesi gerektiği için polling yerine Firestore stream tercih edilir.

---

## Sohbet Akışı

### Geçici Sohbet (Temporary Chat)

Eşleşme kabul edildiğinde `MatchCubit.acceptMatch()` Firestore'daki match kaydına `{userId}Accepted: true` yazar. Her iki kullanıcı kabul edince `chatStartedAt` alanı set edilir ve `/chat/:matchId` ekranına geçilir.

**ChatCubit — _startTimer()**

```
Timer.periodic(1sn) {
  getMatch(matchId) → match.chatStartedAt kontrolü
  
  chatStartedAt == null → displayRemaining = AppConstants.chatWaitingDisplaySeconds (300)
                          (Her iki taraf girmeden süre işlemez)
  
  chatStartedAt != null → expireTime = chatStartedAt + AppConstants.chatExpirationSeconds (30sn)
                          remaining = expireTime - now
                          
  remaining <= 0 → expireMatch() → ChatTimeExpiredState → /chat-expired/:matchId
}
```

Mesajlar `chats/{matchId}/messages` alt koleksiyonuna yazılır.

**Neden 30 saniye?** Kısa süreli tanışma konsepti — kullanıcıyı bağlantı kararı almaya zorlar.

### Kalıcı Sohbet (Permanent Chat)

Sohbet süresi dolunca `/chat-expired` ekranında:
- **Bağlantıyı Koru**: `keepConnectionUsecase` match'te `{userId}KeepConnection: true` yazar. İkisi de seçerse `moveToPermanentChatUsecase` çalışır.
- **Sohbeti Bitir**: `deleteMatch()` ile match silinir.

`moveToPermanentChatUsecase`:
1. `chats/{matchId}/messages` altındaki tüm mesajları `conversations/{matchId}/messages`'a kopyalar.
2. `conversations/{matchId}` dokümanı oluşturur (`participants`, `lastMessage`, `readBy` alanları ile).
3. Geçici `chats/{matchId}` dokümanını siler.

Kalıcı sohbetler `conversations` koleksiyonundan okunur, `lastMessage` ve `readBy` alanları güncellenir.

**`readBy` alanı**: Okunmamış mesaj takibi için kullanılır. Mesaj gönderildiğinde `readBy: [senderId]` set edilir. Alıcı sohbeti açtığında `FieldValue.arrayUnion([receiverId])` ile kendi UID'si eklenir.

---

## Profil Akışı

`ProfileCubit` iki modu yönetir: görüntüleme (view) ve düzenleme (edit).

**ProfileLoaded state**:
- `user`: Firestore'dan gelen mevcut profil
- `editName`, `editAge`, `editGender`, `editVibes`: Düzenleme sırasında geçici değerler
- `hasChanges` getter: `listEquals` kullanarak mevcut değerlerle düzenlenenleri karşılaştırır — değişiklik yoksa kaydet butonu pasif kalır

**pickAndUploadPhoto()**: `MediaService` ile galeriden seçim, `UploadPhotoUsecase` ile Firebase Storage'a yükleme, URL'i state'e yazma — tek metotta üç adım.

---

## Ayarlar Akışı

`SettingsCubit` bildirim tercihi ve hesap silme işlemlerini yönetir.

**deleteAccount()**:
1. `DeleteAccountUsecase` → Firebase Auth kullanıcısını ve Firestore profil dokümanını siler.
2. `LocalStorageService.resetOnboarding()` → onboarding bayrağını sıfırlar.
3. `SettingsAccountDeleted` emit eder → `SettingsBody` dinler → `/` rotasına gider → yeni anonim oturum başlar.

---

## Konum Servisi

`LocationService.getCurrentLocation()` şu sırayla çalışır:

1. GPS izni iste → `Geolocator.getCurrentPosition()`
2. GPS başarısız olursa: `https://api.ipify.org` ile cihaz IP'sini al
3. `http://ip-api.com/json/{ip}?fields=city,lat,lon` ile şehir bazlı konum al
4. Her ikisi de başarısız olursa varsayılan konum (0,0) döner

`isFallback: true` dönerse `ShakingScreen`'de `AppStrings.locationFallbackWarning` snackbar'ı gösterilir.

---

## Sabitler Haritası

| Dosya | İçerik |
|-------|--------|
| `AppStrings` | Tüm Türkçe UI metinleri |
| `AppColors` | Renk paleti (primary + status renkleri) |
| `AppSpacing` | Boşluk değerleri (xs=4, s=8, m=16, l=24, xl=32, xxl=48) |
| `AppRadius` | Border radius değerleri (xs=4, s=8, m=12, l=16, xl=24, chip=20, full=999) |
| `AppDimensions` | Pixel boyutları (avatar, ikon, lottie, picker boyutları) |
| `AppTextSizes` | Font boyutları |
| `AppConstants` | Zamanlama sabitleri, yaş sınırları, vibe limitleri |
| `AppAssets` | Görsel yolları ve Lottie URL'leri |
| `AppVibes` | Vibe kategorileri, renkleri ve ikonları |

---

## Önemli Tasarım Kararları

### Neden `Either<Failure, T>`?
Repository'ler `dartz` paketinin `Either` tipini döner. Sol taraf (`Left`) hatayı, sağ taraf (`Right`) başarılı sonucu taşır. Bu sayede `try/catch` yerine fonksiyonel hata yönetimi yapılır; cubit her zaman başarı ve hata durumunu açıkça ele almak zorunda kalır.

### Neden IndexedStack?
Bottom navigation'da tab değiştiğinde widget ağacı yok edilmez ve yeniden oluşturulmaz. ShakingScreen'deki stream'ler ve timer'lar tab geçişlerinde bozulmaz.

### Neden anonim auth?
Kullanıcının kayıt olmadan uygulamayı kullanabilmesi için. UID, shake ve eşleşme kayıtlarında kimlik olarak yeterlidir. Hesap silme işlemi hem Firebase Auth'tan hem Firestore'dan veriyi temizler.

### Neden Firestore stream'ler?
Eşleşme ve sohbet durumları iki farklı cihazdan eş zamanlı değişir. Polling yerine Firestore realtime listener'ları kullanmak hem daha verimli hem de anlık tepki sağlar.
