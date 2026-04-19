# Shakr — Kodun Tamamı Nasıl Çalışıyor?

Bu döküman uygulamanın ilk açılışından tüm senaryolara kadar her adımı, hangi kodun neden yazıldığını açıklar.

---

## İçindekiler

1. [Mimari Genel Bakış](#1-mimari-genel-bakış)
2. [Uygulama Başladığında Ne Olur?](#2-uygulama-başladığında-ne-olur)
3. [Dependency Injection — GetIt](#3-dependency-injection--getit)
4. [Kimlik Doğrulama — Auth](#4-kimlik-doğrulama--auth)
5. [Onboarding Akışı](#5-onboarding-akışı)
6. [Ana Navigasyon](#6-ana-navigasyon)
7. [Sallama ve Eşleşme — Shake & Match](#7-sallama-ve-eşleşme--shake--match)
8. [Geçici Sohbet — Temporary Chat](#8-geçici-sohbet--temporary-chat)
9. [Kalıcı Sohbet — Permanent Chat](#9-kalıcı-sohbet--permanent-chat)
10. [Profil Yönetimi](#10-profil-yönetimi)
11. [Ayarlar](#11-ayarlar)
12. [State Management — BLoC/Cubit](#12-state-management--bloccubit)
13. [Firebase Veri Yapısı](#13-firebase-veri-yapısı)
14. [Servisler](#14-servisler)
15. [Tema ve Stiller](#15-tema-ve-stiller)
16. [Router — Sayfa Geçişleri](#16-router--sayfa-geçişleri)

---

## 1. Mimari Genel Bakış

Uygulama **Clean Architecture** kullanır. Her feature üç katmana ayrılır:

```
feature/
├── domain/          ← Saf iş mantığı. Flutter'a bağımlı değil.
│   ├── entities/    ← Veri modelleri (sade Dart sınıfları)
│   ├── repositories/← Soyut arayüzler (ne yapılacağını tanımlar, nasıl değil)
│   └── usecases/   ← Tek bir işi yapan sınıflar (sendMessage, endMatch...)
├── data/            ← Teknik detaylar. Firebase, HTTP, LocalStorage.
│   ├── models/      ← Entity'lerin JSON'a dönüşen versiyonları
│   ├── repositories/← Repository arayüzlerinin gerçek implementasyonu
│   └── datasources/ ← Direkt Firebase/API çağrıları buradadır
└── presentation/    ← Flutter UI. Cubit + Widget'lar.
    ├── cubit/       ← State yönetimi
    └── widgets/     ← UI bileşenleri
```

**Neden böyle?**
- `domain` katmanı hiçbir zaman Firebase'e bağımlı değil. Firebase'i yarın Supabase ile değiştirsen sadece `data` katmanını değiştirirsin.
- Her use case tek bir iş yapar → test etmesi ve anlaması kolay.
- UI sadece state'e bakar, veriyi nasıl çektiğini bilmez.

---

## 2. Uygulama Başladığında Ne Olur?

### `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjection();  // GetIt'i hazırla
  runApp(const ShakrApp());
}
```

1. `WidgetsFlutterBinding.ensureInitialized()` — Flutter motorunu başlatır. Firebase gibi native kodları `runApp`'tan önce çağırabilmek için gereklidir.
2. `Firebase.initializeApp()` — `firebase_options.dart`'taki API anahtarlarıyla Firebase'e bağlanır.
3. `setupInjection()` — Tüm bağımlılıkları hazırlar (aşağıda detay var).
4. `runApp(ShakrApp())` — Widget ağacı başlar.

### `ShakrApp` Widget'ı

```dart
class ShakrApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..getCurrentUser()),
        BlocProvider(create: (_) => sl<MatchCubit>()),
        BlocProvider(create: (_) => sl<NavigationCubit>()),
      ],
      child: MaterialApp.router(routerConfig: appRouter),
    );
  }
}
```

- `MultiBlocProvider` global cubit'leri tüm widget ağacına sağlar.
- `AuthCubit` hemen `getCurrentUser()` çağırır — uygulama açılır açılmaz kimlik kontrolü başlar.
- `MatchCubit` global tutulur çünkü eşleşme bildirimleri her sayfadan dinlenmeli.
- `MaterialApp.router` GoRouter ile çalışır.

### Splash Ekranı — İlk Routing Kararı

`SplashPage` açılır ve şunu yapar:

```
AuthCubit.getCurrentUser() çalıştır
    ↓
Firestore'da kullanıcı var mı?
    ↓ Evet              ↓ Hayır
LocalStorage'da        signInAnonymously()
onboarding_completed   ile yeni anonim hesap oluştur
var mı?                    ↓
    ↓ Evet             Onboarding'e gönder
3 saniye bekle
    ↓
/main/shake'e git
```

**Neden anonim giriş?**
Kullanıcıdan e-posta/şifre istemiyoruz. Firebase'in anonim giriş özelliği sayesinde kullanıcıya bir UID atanır ve bu UID kalıcıdır (uygulama silinmedikçe). Sosyal medya hesabı olmadan bile benzersiz kimlik elde ederiz.

**Neden 3 saniye bekliyoruz?**
`AppConstants.splashDelaySeconds = 3`. Firebase çağrısı genelde 1-2 saniyede tamamlanır; splash animasyonu sırasında bu işlemler arka planda yapılır.

---

## 3. Dependency Injection — GetIt

**Dosya:** `lib/common/getit/injection.dart`

GetIt bir "service locator"dır. Tüm nesneleri tek bir merkezde oluşturur, gerektiğinde `sl<T>()` ile alırsın.

```dart
// Servisler (Singleton — tek örnek, sürekli aynı nesne)
sl.registerLazySingleton<ShakeService>(() => ShakeService());
sl.registerLazySingleton<LocationService>(() => LocationService());
sl.registerLazySingleton<VibrationService>(() => VibrationService());

// Datasource → Repository → UseCase → Cubit sırası
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(firestore: sl(), auth: sl(), storage: sl()),
);
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(remoteDataSource: sl()),
);
sl.registerLazySingleton<SignInAnonymouslyUsecase>(
  () => SignInAnonymouslyUsecase(sl()),
);

// Cubit'ler Factory — her çağrıda yeni örnek
sl.registerFactory<AuthCubit>(() => AuthCubit(
  signInAnonymouslyUsecase: sl(),
  getCurrentUserUsecase: sl(),
  ...
));
```

**`registerLazySingleton` vs `registerFactory`:**
- `LazySingleton`: İlk kullanımda oluşturulur, sonraki çağrılarda aynı nesne döner. Servisler için uygundur.
- `Factory`: Her `sl<T>()` çağrısında yeni nesne oluşturur. Cubit'ler için gereklidir çünkü her sayfa kendi temiz state'iyle başlamalı.

---

## 4. Kimlik Doğrulama — Auth

**Dosyalar:** `features/auth/`

### Akış

```
AuthCubit.getCurrentUser()
    ↓
GetCurrentUserUsecase → AuthRepository → AuthRemoteDataSource
    ↓
FirebaseAuth.currentUser var mı?
    ↓ Evet                    ↓ Hayır
Firestore'dan profil al    → AuthCubit.signInAnonymously()
    ↓                              ↓
emit(AuthState.success)     Firebase anonim UID oluşturur
                                   ↓
                            emit(AuthState.success, user: yeni kullanıcı)
```

### `UserEntity`

```dart
class UserEntity {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String? photoUrl;
  final List<String> vibes;
}
```

Bu saf bir Dart sınıfıdır. Firebase veya Flutter bağımlılığı yok. `UserModel` ise bunu JSON'a çevirir:

```dart
class UserModel extends UserEntity {
  factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toMap() { ... }
}
```

**Neden entity ve model ayrı?**
Entity iş mantığını temsil eder. Model ise teknik detayı — Firestore'un formatını. Yarın veri yapısı değişirse sadece `toMap/fromFirestore` değişir, entity değişmez.

### Hesap Silme

`deleteAccount()` şunları yapar:
1. Kullanıcının tüm match'lerini siler
2. Tüm conversation'larını siler
3. Firestore'daki `users/{uid}` dökümanını siler
4. Firebase Storage'daki fotoğrafı siler
5. `FirebaseAuth.currentUser.delete()` çağırır

Sıra önemlidir — Auth silinince Firestore'a erişim kesilir, bu yüzden Firestore işlemleri en sonda değil önce yapılır.

---

## 5. Onboarding Akışı

**Dosyalar:** `features/onboarding/`

### 6 Adımlı Akış

```
Step 0: IntroStep    → Karşılama ekranı, "Başla" butonu
Step 1: NameStep     → İsim girişi (TextField)
Step 2: PhotoStep    → Fotoğraf seçimi (kamera veya galeri)
Step 3: AgeStep      → Yaş seçimi (scroll wheel)
Step 4: GenderStep   → Cinsiyet (Erkek/Kadın)
Step 5: VibeStep     → 3 vibe seçimi
```

### `OnboardingBody` Nasıl Çalışır?

```dart
// onboarding_body.dart
switch (state.step) {
  case 0: return IntroStep();
  case 1: return NameStep();
  case 2: return PhotoStep();
  ...
}
```

`state.step` değiştikçe widget değişir. Animasyon için `AnimatedSwitcher` kullanılır — sayfa geçişinde widget içinden dışarı kayar.

### `OnboardingCubit` Metotları

- `start()` → step 0'dan 1'e geçer
- `setName(String)` → ismi state'e kaydeder, step 2'ye geçer
- `setPhoto()` → `MediaService` ile fotoğraf seçer, `UploadPhotoUsecase` ile yükler, step 3'e geçer
- `setAge(int)` → yaşı kaydeder, step 4'e geçer
- `setGender(String)` → cinsiyet kaydeder, step 5'e geçer
- `selectVibe(String)` → vibe listesine ekler (max 3)
- `saveProfile()` → tüm veriyi `SaveProfileUsecase` ile Firestore'a yazar, `LocalStorageService`'e `onboarding_completed = true` kaydeder

### Neden `LocalStorageService`?

Firebase'e kaydetmek yeterli değil mi? Hayır. Splash ekranında "kullanıcı onboarding'i tamamladı mı?" sorusunu **çok hızlı** cevaplamamız gerekiyor. Firestore çağrısı ağ gerektirir, 1-2 saniye sürer. LocalStorage (`SharedPreferences`) milisaniyelerde cevap verir. Bu yüzden bir bayrak yerel olarak saklanır.

### Vibe Seçimi

```dart
// vibe_step.dart
AppVibes.categories.map((category) => 
  Column(
    children: [
      Text(category.name), // "Kültür", "Yaşam"...
      Wrap(
        children: category.vibes.map((vibe) =>
          VibeChip(
            isSelected: state.vibes.contains(vibe.name),
            onTap: () => cubit.selectVibe(vibe.name),
          )
        )
      )
    ]
  )
)
```

`AppVibes.categories` sabit bir listedir. Her kategorinin vibeleri var, her vibenin rengi ve ikonu var. `colorForVibe(String)` metodu vibe adından rengini bulur.

---

## 6. Ana Navigasyon

**Dosyalar:** `features/main/`

### Bottom Navigation

Ana sayfa 3 tab içerir:

```
Tab 0: ShakingPage   → Sallama ekranı
Tab 1: MyChatsPage   → Sohbet listesi
Tab 2: ProfilePage   → Profil
```

### `NavigationCubit`

Sadece `int` tutan basit bir cubit:

```dart
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);
  void navigateTo(int index) => emit(index);
}
```

### `MainBody` — `IndexedStack` Kullanımı

```dart
IndexedStack(
  index: state,  // NavigationCubit'ten gelen int
  children: [
    ShakingPage(),
    MyChatsPage(),
    ProfilePage(),
  ],
)
```

**Neden `IndexedStack`?**
`PageView` veya `Navigator` kullansaydık, her tab değişiminde widget yeniden oluşurdu. `IndexedStack` tüm widget'ları hafızada tutar — tab değiştirdiğinde state kaybolmaz. Örneğin chats listesi tab'ından çıkıp geri geldiğinde sıfırdan yüklenmez.

---

## 7. Sallama ve Eşleşme — Shake & Match

Bu uygulamanın kalbi burası.

### ShakeService Nasıl Çalışır?

```dart
// shake_service.dart
accelerometerEventStream().listen((event) {
  final magnitude = sqrt(event.x² + event.y² + event.z²);
  if (magnitude > 15.0) {
    onShake();  // callback çağrılır
  }
});
```

Telefon 3 eksende ivmeölçer verisini sürekli yayınlar. Vektörün büyüklüğü 15.0'ı (≈1.5g) aşarsa "sallama" olarak kabul edilir. Neden 15? Bu değer test sonucu bulunmuş — normal taşıma sırasında tetiklenmeyecek, ama kasıtlı sallama yapınca tetiklenecek eşik.

### ShakeCubit Akışı

```
ShakeCubit.init()
    ↓
ShakeService.startListening(onShake: recordShake)
MatchCubit.watchMatch(uid) başlatılır

    [Kullanıcı telefonu sallar]
    ↓
ShakeCubit.recordShake()
    ↓
HasActiveMatchUsecase → kullanıcının aktif match'i var mı?
    ↓ Evet                    ↓ Hayır
işlem yapma              LocationService.getCurrentLocation()
                              ↓
                         RecordShakeUsecase → Firestore'a yaz
                              ↓
                         emit(ShakeCubitStatus.recorded)
                         VibrationService.shakeFeedback()
                         SearchingBody göster (radar animasyonu)
                         startMatchTimer() → 15 saniye sayaç başlar
```

### Eşleşme Mantığı — Backend Tarafı

Firestore'a shake kaydedildiğinde bir **Cloud Function** devreye girer (bu kodlar Flutter'da değil, Firebase Functions'da). Yakındaki diğer shake kayıtlarını geohash ile bulur ve `matches` koleksiyonuna yeni bir eşleşme yazar.

**Geohash nedir?**
GPS koordinatları geohash algoritmasıyla kısa bir string'e dönüştürülür (`u4pruydqqvj` gibi). Aynı bölgedeki koordinatlar ortak prefix'e sahip olur. Bu sayede Firestore'da "100 metre yakınımda kim var?" sorusunu verimli şekilde sorabilirsin — tüm kullanıcıların koordinatlarını karşılaştırmana gerek kalmaz.

### MatchCubit — Eşleşmeyi İzleme

```dart
// match_cubit.dart
void watchMatch(String uid) {
  _matchSubscription = watchMatchUsecase(uid).listen((either) {
    either.fold(
      (failure) => emit(state.copyWith(status: MatchCubitStatus.error)),
      (match) {
        if (match == null) {
          emit(state.copyWith(status: MatchCubitStatus.notFound));
          return;
        }
        // Cooldown kontrolü
        if (cooldownActive) { ... return; }
        
        emit(state.copyWith(status: MatchCubitStatus.found, match: match));
        VibrationService.matchFeedback();
      },
    );
  });
}
```

`watchMatchUsecase` bir Firestore stream'idir. Kullanıcının `users` array'inde UID'si olan matches'ı dinler. Yeni eşleşme gelince `MatchCubitStatus.found` emit eder.

### `ShakingPage` BlocListener'ı

```dart
BlocListener<MatchCubit, MatchState>(
  listener: (context, state) {
    if (state.status == MatchCubitStatus.found) {
      context.go('/match/${state.match!.matchId}');
    }
  },
)
```

Cubit state değişince sayfa otomatik route değiştirir. UI mantığı cubit'te değil, listener'da.

**Neden BlocListener, BlocBuilder değil?**
`BlocBuilder` widget'ı yeniden çizer. `BlocListener` ise sadece yan etki üretir (navigasyon, snackbar, dialog). Navigasyon bir "çizim" değil, bir "eylem" — bu yüzden listener kullanılır.

### MatchFoundPage

Eşleşme bulununca bu sayfa açılır. Gösterdikleri:
- Karşı kullanıcının vibe'ları
- 15 saniyelik kabul penceresi sayacı
- "Kabul Et" butonu

```dart
// match_found_body.dart
ElevatedButton(
  onPressed: () => sl<MatchCubit>().acceptMatch(matchId, currentUid),
)
```

Her iki kullanıcı kabul edince Firestore'da `user1Accepted = true`, `user2Accepted = true` olur ve `chatStartedAt` timestamp'i set edilir.

### Kabul Akışı

```
İlk kullanıcı "Kabul Et" → acceptMatch()
    ↓
Firestore: user1Accepted = true
    ↓
Stream tetiklenir → MatchCubit.watchMatch()
    ↓ (sadece bir kabul)
emit(MatchCubitStatus.acceptancePending)

    [İkinci kullanıcı da kabul eder]
    ↓
Firestore: user2Accepted = true, chatStartedAt = now
    ↓
Stream tetiklenir
    ↓
emit(MatchCubitStatus.accepted)
    ↓
BlocListener → context.go('/chat/$matchId')
```

### 15 Saniye Sayacı — `startMatchTimer()`

```dart
void startMatchTimer() {
  _matchTimer = Timer(Duration(seconds: AppConstants.matchAcceptanceWindowSeconds), () {
    if (state.status != MatchCubitStatus.accepted) {
      deleteShake(uid);
      emit(state.copyWith(status: MatchCubitStatus.notFound));
    }
  });
}
```

15 saniye sonra eşleşme kabul edilmediyse shake kaydı silinir ve "eşleşme bulunamadı" durumuna geçilir.

### Cooldown Sistemi

İki kullanıcı bir gün içinde tekrar eşleşmesin diye `matchCooldowns` koleksiyonu kullanılır:

```
key: "uid1_uid2" (UIDs alfabetik sırayla birleştirilir)
expiresAt: şimdiden 24 saat sonra
```

Neden UIDs sıralanır? "A_B" ile "B_A" aynı çifti temsil eder. Sıralama yapmazsan iki farklı anahtar oluşur, cooldown çalışmaz.

---

## 8. Geçici Sohbet — Temporary Chat

### Başlangıç

```dart
// chat_cubit.dart
void initChat(String matchId, DateTime chatStartTime, {bool isPermanent = false}) {
  _isPermanent = isPermanent;
  _matchId = matchId;
  
  if (!isPermanent) {
    _startTimer(chatStartTime);
  }
  
  watchMessages(matchId, isPermanent: isPermanent);
}
```

`isPermanent = false` ise timer başlar ve mesajlar `chats/{matchId}/messages` koleksiyonundan okunur.

### 30 Saniyelik Sayaç

```dart
void _startTimer(DateTime chatStartTime) {
  _chatTimer = Timer.periodic(Duration(seconds: 1), (_) async {
    final match = await getMatchUsecase(matchId);
    final startedAt = match?.chatStartedAt ?? chatStartTime;
    final expireAt = startedAt.add(Duration(seconds: AppConstants.chatExpirationSeconds));
    final remaining = expireAt.difference(DateTime.now()).inSeconds;
    
    if (remaining <= 0) {
      _chatTimer?.cancel();
      expireMatch(matchId);
      emit(state.copyWith(status: ChatStatus.timeExpired));
    } else {
      emit(state.copyWith(
        status: ChatStatus.timerTick,
        secondsLeft: remaining,
      ));
    }
  });
}
```

Her saniye Firestore'dan `chatStartedAt`'ı okur ve kalan süreyi hesaplar. Neden her saniye Firestore'dan okuyoruz? Çünkü `chatStartedAt` iki kullanıcı kabul ettiğinde server-side set edilir — iki telefon aynı anda bu değeri bilmiyor olabilir. Firestore'dan okuyarak doğru zamanlama elde ederiz.

**`AppConstants.chatWaitingDisplaySeconds = 300`:** `chatStartedAt == null` iken (henüz iki kullanıcı da kabul etmemişken) 300 saniye (5 dakika) gösterilir. Bu gerçekten 5 dakika beklediğimiz anlamına gelmez — sadece UI'da makul bir değer görünsün diye.

### `ChatTimerTitle`

AppBar'da görünen geri sayım:

```dart
// chat_timer_title.dart
BlocBuilder<ChatCubit, ChatState>(
  builder: (context, state) {
    if (state.secondsLeft < 0) return Text(AppStrings.chatDefaultTitle);
    
    final minutes = state.secondsLeft ~/ 60;
    final seconds = state.secondsLeft % 60;
    return Text('$minutes:${seconds.toString().padLeft(2, '0')}');
  },
)
```

`padLeft(2, '0')` → "5:03" yerine "5:3" yazmaması için.

### Mesaj Gönderme

```dart
// chat_input_bar.dart
IconButton(
  onPressed: () => cubit.sendMessageFromInput(matchId, uid, isPermanent),
)
```

```dart
// chat_cubit.dart
void sendMessageFromInput(String id, String uid, bool isPermanent) {
  final text = messageController.text.trim();
  if (text.isEmpty) return;
  
  messageController.clear();
  sendMessageUsecase(MessageEntity(
    senderId: uid,
    text: text,
    id: '',
    createdAt: DateTime.now(),
  ), id, isPermanent: isPermanent);
}
```

Neden `trim()`? Sadece boşluktan oluşan mesajların gönderilmesini engeller.

### Mesaj Görüntüleme

```dart
// chat_message_list.dart
ListView.builder(
  reverse: true,  // En yeni mesaj altta
  itemBuilder: (context, index) {
    final message = messages[index];
    final isMe = message.senderId == currentUid;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
        ...
      ),
    );
  },
)
```

`reverse: true` ile ListView ters sırada render edilir — en son mesaj en altta görünür ve yeni mesaj gelince otomatik scroll gerçekleşir.

---

## 9. Kalıcı Sohbet — Permanent Chat

### Sohbet Süresi Dolunca

`ChatStatus.timeExpired` emit edilince:

```dart
// chat_page.dart
BlocListener<ChatCubit, ChatState>(
  listener: (context, state) {
    if (state.status == ChatStatus.timeExpired) {
      context.go('/chat-expired/$matchId');
    }
  },
)
```

`ChatExpiredBody` açılır. Burada "Bağlantıyı Koru" seçeneği var.

### `keepConnectionFlow()`

```dart
// match_cubit.dart
Future<void> keepConnectionFlow() async {
  await keepConnectionUsecase(matchId, currentUid);
  // Firestore'da user1KeepConnection veya user2KeepConnection = true yapılır
  
  final match = await getMatchUsecase(matchId);
  
  if (match!.user1KeepConnection && match.user2KeepConnection) {
    await moveToPermanentChatUsecase(matchId);
    emit(state.copyWith(status: MatchCubitStatus.bothKept));
  } else {
    emit(state.copyWith(status: MatchCubitStatus.connectionPending));
  }
}
```

İki kullanıcı da "Koru" derse `moveToPermanentChat()` çalışır. Bu Firestore transaction'ı ile `chats/{matchId}/messages` koleksiyonundaki mesajları `conversations/{matchId}/messages`'a kopyalar ve bir `conversations/{matchId}` dökümanı oluşturur.

### Kalıcı Sohbet vs Geçici Farkı

| | Geçici | Kalıcı |
|---|---|---|
| Koleksiyon | `chats/{id}/messages` | `conversations/{id}/messages` |
| Süre | 30 saniye | Sınırsız |
| AppBar | Geri sayım timer | İsim + fotoğraf |
| isPermanent | `false` | `true` |
| Silme | Match silinince otomatik | `deleteConversation()` ile manuel |
| readBy | Yok | Var — okundu takibi |

### Okundu Takibi

```dart
// conversation_tile.dart
onTap: () {
  sl<ChatCubit>().markAsRead(conversation.id, currentUid);
  context.push('/chat/${conversation.id}?permanent=true...');
}
```

`markAsRead()` Firestore'da `readBy` array'ine `currentUid` ekler. Yeni mesaj gelince server-side (veya mesaj gönderen) `readBy` array'ini temizler. `readBy.contains(uid)` false ise mesaj okunmamış — kalın yazı tipiyle gösterilir.

### ConversationTile — Swiping ile Silme

```dart
// conversation_tile.dart
Dismissible(
  confirmDismiss: (_) => ConfirmDialog.show(
    context,
    title: AppStrings.deleteConversation,
    content: AppStrings.deleteConversationConfirm,
  ),
  onDismissed: (_) => sl<ChatCubit>().deleteConversation(conversation.id),
)
```

`confirmDismiss` bir `Future<bool>` döner. `true` dönerse silme animasyonu devam eder, `false` dönerse iptal edilir. Kullanıcı diyalogdan dışarı tıklarsa (dismiss) `ConfirmDialog.show()` `false` döner — yanlışlıkla silme önlenir.

---

## 10. Profil Yönetimi

### View/Edit Modu

```dart
// profile_page.dart
BlocBuilder<ProfileCubit, ProfileState>(
  builder: (context, state) {
    if (state.isEditing) return ProfileEditBody(state: state);
    return ProfileViewBody(state: state);
  },
)
```

Tek sayfada iki farklı body. `toggleEditMode()` ile geçiş yapılır. `ProfileState.hasChanges` mevcut değerleri orijinallerle karşılaştırır — değişiklik yoksa kaydet butonu disabled kalır.

### Kaydet Butonu Koşulu

```dart
// profile_edit_body.dart
onPressed: state.editVibes.length == 3 
    && state.hasChanges 
    && state.editName.trim().isNotEmpty
  ? () => context.read<ProfileCubit>().saveProfile()
  : null,
```

Üç koşul birden sağlanmalı:
1. Tam 3 vibe seçili olmalı
2. En az bir şey değişmiş olmalı
3. İsim boş olmamalı

`onPressed: null` Flutter'da butonu disable eder — ne görsel olarak ne de işlevsel olarak tıklanamaz.

### Fotoğraf Yükleme

```dart
// profile_cubit.dart
Future<void> uploadPhoto(String path) async {
  emit(state.copyWith(isUploadingPhoto: true));
  
  final result = await uploadPhotoUsecase(path, user.uid);
  
  result.fold(
    (failure) => emit(state.copyWith(isUploadingPhoto: false, status: ProfileStatus.photoUploadError)),
    (url) => emit(state.copyWith(
      isUploadingPhoto: false,
      editPhotoUrl: url,
    )),
  );
}
```

Yükleme sırasında `isUploadingPhoto: true` ile bir loading indicator gösterilir. Firebase Storage'a yükleme tamamlanınca dönen URL state'e kaydedilir.

---

## 11. Ayarlar

**Dosyalar:** `features/settings/`

Basit bir liste sayfası:
- Bildirimler toggle (local state, Firebase değil)
- Kullanım Koşulları / Gizlilik Politikası (URL açar)
- Çıkış Yap → LocalStorage temizler, onboarding'e yönlendirir
- Hesabı Sil → `ConfirmDialog` açar, onay gelince `AuthCubit.deleteAccount()`

**Neden "Çıkış Yap" onboarding'e götürüyor?**
Uygulama anonim giriş kullanıyor — gerçek bir "logout" yok. Çıkış yapma aslında onboarding state'ini sıfırlamak demek. Kullanıcı tekrar açtığında yeni bir anonim hesap oluşturulur.

---

## 12. State Management — BLoC/Cubit

### Cubit Nedir?

BLoC'un daha basit versiyonu. State yönetimi için:

```dart
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(ExampleState.initial());

  void doSomething() {
    emit(state.copyWith(status: ExampleStatus.loading));
    // işlem yap...
    emit(state.copyWith(status: ExampleStatus.success));
  }
}
```

`emit()` yeni state yayınlar → `BlocBuilder` yeniden çizer, `BlocListener` tepki verir.

### `copyWith` Pattern'i

```dart
// Örnek state
@immutable
class ChatState {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final int secondsLeft;

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    int? secondsLeft,
  }) => ChatState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    secondsLeft: secondsLeft ?? this.secondsLeft,
  );
}
```

State'in sadece bir kısmını değiştirmek için `copyWith` kullanılır. Immutable state — hiçbir zaman mevcut nesne değiştirilmez, her seferinde yeni nesne oluşturulur. Bu Flutter'ın widget yeniden çizim mekanizmasıyla uyumludur.

### Either Pattern

```dart
// Repository metodu
Future<Either<Failure, UserEntity>> getCurrentUser();

// Cubit'te kullanımı
final result = await getCurrentUserUsecase();
result.fold(
  (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
  (user) => emit(state.copyWith(status: AuthStatus.success, user: user)),
);
```

`Either<L, R>` bir işlemin ya hata (`Left`) ya da başarı (`Right`) döndürdüğünü garanti eder. `try/catch` yerine tip sistemiyle hata yönetimi yapılır.

---

## 13. Firebase Veri Yapısı

### `users/{uid}`
```
{
  name: "Ahmet",
  age: 23,
  gender: "male",
  photoUrl: "https://...",
  vibes: ["muzik", "kahve", "kod"]
}
```

### `shakes/{uid}`
```
{
  uid: "abc123",
  location: GeoPoint(41.0082, 28.9784),
  geohash: "sxk9m...",
  status: "waiting",
  timestamp: Timestamp
}
```

### `matches/{matchId}`
```
{
  user1: "uid1",
  user2: "uid2",
  users: ["uid1", "uid2"],       ← array-contains sorgusu için
  user1Vibes: ["muzik", "kod"],
  user2Vibes: ["kahve", "spor"],
  createdAt: Timestamp,
  chatStartedAt: Timestamp | null,
  status: "active" | "expired",
  user1Accepted: true,
  user2Accepted: false,
  user1KeepConnection: false,
  user2KeepConnection: false
}
```

### `chats/{matchId}/messages/{msgId}`
```
{
  senderId: "uid1",
  text: "Merhaba!",
  createdAt: Timestamp
}
```

### `conversations/{convId}`
```
{
  participants: ["uid1", "uid2"],
  user1Name: "Ahmet", user2Name: "Ayşe",
  user1Photo: "...", user2Photo: "...",
  user1Vibes: [...], user2Vibes: [...],
  lastMessage: "Görüşürüz!",
  lastMessageAt: Timestamp,
  readBy: ["uid1"]               ← uid2 henüz okumadı
}
```

### `matchCooldowns/{key}`
```
{
  key: "uid1_uid2",    ← UIDs alfabetik sırayla
  user1: "uid1",
  user2: "uid2",
  expiresAt: Timestamp  ← 24 saat sonrası
}
```

---

## 14. Servisler

### `ShakeService`

`sensors_plus` paketi ile çalışır. Accelerometer stream'ini dinler:
```
sqrt(x² + y² + z²) > 15.0 → shake!
```

### `LocationService`

1. `geolocator` ile GPS koordinatları alır (5 saniye timeout, yüksek doğruluk).
2. Başarısız olursa (izin reddedildi, GPS kapalı vb.) `ip-api.com` üzerinden IP tabanlı yaklaşık konum alır.
3. Her iki durumda da `GeoPoint(lat, lng)` döner.

**Neden fallback?** GPS izni olmayan kullanıcıları tamamen dışlamamak için. IP bazlı konum şehir seviyesinde doğru — aynı şehirdeki insanlarla eşleşme için yeterli.

### `VibrationService`

Farklı olaylar için farklı titreşim desenleri:

| Metot | Desen | Kullanım |
|---|---|---|
| `shakeFeedback()` | 200ms | Telefon sallandı |
| `matchFeedback()` | [300, 200, 300] | Eşleşme bulundu |
| `matchAcceptedFeedback()` | [150, 100, 150] | Eşleşme kabul edildi |
| `chatStartedFeedback()` | 200ms | Sohbet başladı |
| `endFeedback()` | 150ms | Sohbet bitti |

### `MediaService`

`image_picker` paketi ile kamera veya galeriden fotoğraf seçer.

---

## 15. Tema ve Stiller

### `AppColors`

Ana renk `primary: Color(0xFF7C77EC)` (mor-lavanta). Tüm türevleri programatik:

```dart
static const primary = Color(0xFF7C77EC);
static const primary100 = Color(0xFFE8E7FA);  // %90 açık
static const primary900 = Color(0xFF2E2A8A);  // %90 koyu
```

Light/Dark mode için ayrı tanımlar var:
```dart
static Color get background => 
  _isDark ? Color(0xFF0F0F0F) : Colors.white;
```

### `AppTheme`

Material 3 tabanlı. `ThemeData.colorScheme.copyWith(primary: AppColors.primary)` ile ana renk primary set edilir. Bunun faydası: tüm Material widget'ları (Button, TextField, Switch vb.) otomatik olarak bu rengi kullanır — her widget'ı ayrı ayrı renklendirmene gerek kalmaz.

---

## 16. Router — Sayfa Geçişleri

**Dosya:** `lib/common/router/app_router.dart`

GoRouter kullanılır. Tüm route'lar merkezi bir yerde tanımlı:

```
/                → SplashPage
/onboarding      → OnboardingPage
/main/shake      → MainPage (tab 0: Shake)
/main/chats      → MainPage (tab 1: Chats)
/main/profile    → MainPage (tab 2: Profile)
/match/:matchId  → MatchFoundPage
/chat/:matchId   → ChatPage (query: ?permanent=true&name=...&photo=...)
/chat-expired/:matchId → ChatExpiredPage
/settings        → SettingsPage
```

### Query Parametreler

`/chat/:matchId?permanent=true&name=Ahmet&photo=https://...`

Neden URL'e koyuyoruz? GoRouter'da sayfalar arası parametre taşımanın en temiz yolu bu. `extra` parametresi de kullanılabilir ama deep link veya uygulama yeniden başlatılırsa extra kaybolur. İsim ve fotoğraf URL-encoded olarak geçirilir:

```dart
final encodedName = Uri.encodeComponent(conversation.otherUserName);
// "Ahmet Çelik" → "Ahmet%20%C3%87elik"
```

### Programatik vs Declarative Navigasyon

```dart
// Programatik (kod içinden)
context.go('/main/shake');   // History'yi sıfırlar
context.push('/settings');   // Üstüne ekler, geri tuşu çalışır

// Declarative (GoRouter şablonu)
GoRoute(
  path: '/chat/:matchId',
  builder: (context, state) => ChatPage(
    matchId: state.pathParameters['matchId']!,
    isPermanent: state.uri.queryParameters['permanent'] == 'true',
    otherUserName: state.uri.queryParameters['name'],
  ),
)
```

---

## Tam Senaryo: Sıfırdan Kalıcı Sohbete

```
1.  Uygulama açılır → main.dart → Firebase init → GetIt setup
2.  SplashPage → AuthCubit.getCurrentUser()
3.  [İlk kez] → signInAnonymously() → UID atanır
4.  LocalStorage: onboarding_completed? → Hayır
5.  context.go('/onboarding')
6.  6 adım tamamlanır → saveProfile() → Firestore'a yaz → LocalStorage'a flag yaz
7.  context.go('/main/shake')
8.  MainBody: IndexedStack, ShakingPage tab 0'da
9.  ShakeCubit.init() → ShakeService dinlemeye başlar
10. Kullanıcı telefonu sallar → ivme > 15.0
11. ShakeCubit.recordShake() → GPS al → Firestore'a yaz
12. VibrationService.shakeFeedback()
13. SearchingBody gösterilir (radar animasyonu)
14. [Backend Cloud Function] → Yakındaki diğer shake bulunur → match oluşturulur
15. MatchCubit.watchMatch() stream tetiklenir
16. emit(MatchCubitStatus.found) → BlocListener → context.go('/match/$matchId')
17. VibrationService.matchFeedback()
18. MatchFoundPage: karşı kullanıcının vibe'ları gösterilir, 15 saniye sayacı
19. Her iki kullanıcı "Kabul Et" tıklar → acceptMatch()
20. Firestore: user1Accepted=true, user2Accepted=true, chatStartedAt=now
21. emit(MatchCubitStatus.accepted) → context.go('/chat/$matchId')
22. VibrationService.matchAcceptedFeedback()
23. ChatCubit.initChat() → 30 saniye timer başlar, mesaj stream açılır
24. ChatTimerTitle'da geri sayım gösterilir
25. [30 saniye geçer] → ChatStatus.timeExpired → context.go('/chat-expired/$matchId')
26. VibrationService.endFeedback()
27. ChatExpiredBody: "Bağlantıyı Koru" seçeneği
28. Her iki kullanıcı "Koru" tıklar → keepConnectionFlow()
29. moveToPermanentChat() → conversations koleksiyonu oluşturulur
30. emit(MatchCubitStatus.bothKept) → context.go('/chat/$matchId?permanent=true&...')
31. ChatCubit.initChat(isPermanent: true) → timer yok, conversations stream
32. Sınırsız sohbet
33. Kullanıcı sohbeti silmek ister → sola kaydırır
34. ConfirmDialog.show() → onay → deleteConversation()
```

---

Bu döküman uygulamanın tamamını kapsar. Herhangi bir bölümde daha fazla detay istersen sorabilirsin.
