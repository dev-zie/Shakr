# Shakr App - Proje Mimarisi ve Kod İzleme Rehberi

Merhaba! Bu belge, `shakr` uygulamasının kodlarını, genel yapısını ve çalışma mantığını kolayca anlayabilmen için hazırlanmıştır. Bu belgeyi okuyarak projede hangi dosyanın ne işe yaradığını ve uygulamanın genel mimarisini rahatlıkla kavrayabilirsin.

---

## 📱 Proje Özeti
**Shakr**, Flutter ile geliştirilmiş, Firebase tabanlı modern bir eşleşme ve sohbet uygulamasıdır. 
Uygulamanın ana konsepti; kullanıcıların telefonlarını **sallayarak (shake)** bir eşleşme (match) bulması ve kısıtlı süreleri olabilecek sohbet (chat) odalarında iletişim kurmasıdır.

### 🛠 Kullanılan Temel Teknolojiler ve Paketler
Uygulamada endüstri standartlarında modern teknolojiler kullanılmış:
- **Flutter & Dart:** Ana framework.
- **State Management (Durum Yönetimi):** `flutter_bloc` (Temel olarak `Cubit` kullanılıyor).
- **Dependency Injection (Bağımlılık Enjeksiyonu):** `get_it` (Servisleri ve Cubit'leri uygulamanın her yerinden erişilebilir yapmak için).
- **Navigation (Yönlendirme):** `go_router` (Sayfalar arası geçiş ve deeplink yönetimi için modern yönlendirme paketi).
- **Firebase Cihazları:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`.
- **Cihaz Donanımı & İzinler:** Cihaz sallama algılaması için `sensors_plus`, konum için `geolocator`, izin yönetimleri için `permission_handler`.
- **Eklentiler:** Animasyonlar için `lottie`, fonksiyonel programlama prensipleri için `dartz` (Either, Left, Right kullanımı), eşitlik kontrolü için `equatable`.

---

## 📂 Dizin (Klasör) Mimarisi 

Proje klasörü **"Feature-First" (Özellik Odaklı)** ve **"Clean Architecture" (Temiz Mimari)** tarzında yapılandırılmış. Bu, her bir özelliğin kendi ayakları üzerinde durduğu ve projenin çok kolay ölçeklenebilir (büyütülebilir) olduğu anlamına gelir.

Bütün kodlar `lib/` klasörünün altındadır. `lib/` altındaki 3 ana klasörün görevleri şunlardır:

### 1. `lib/features/` (Uygulamanın Özellikleri)
Uygulamanın her bir ekranı/özelliği kendi klasörüne ayrılmıştır. Örneğin telefonu sallama ekranı (`shake`) ile giriş ekranı (`auth`) ayrı klasörlerdedir. Her bir klasörün içinde genellikle şu yapı bulunur:
- **`presentation/`**: Kullanıcının gördüğü ekranlar (`pages`), küçük arayüz parçaları (`widgets`) ve o ekranın state'ini (durumunu) yöneten `cubit`'ler buradadır.
- **`domain/`** (İsteğe bağlı): O özelliğin iş kurallarını (Use-cases) ve Entity'lerini (Saf veri modellerini) barındırır.
- **`data/`** (İsteğe bağlı): İnternet veya veritabanı ile konuşan ve datayı getiren (Repository, Models) dosyaları barındırır.

**Projendeki Temel Özellikler (Features):**
- 🚀 **`splash/`**: Uygulama açılış ekranı.
- 👋 **`onboarding/`**: Uygulamayı ilk kez açan kullanıcılar için tanıtım veya bilgi toplama.
- 🔐 **`auth/`**: Kullanıcı kayıt, giriş ve Firebase doğrulama işlemleri.
- 📳 **`shake/`**: Uygulamanın en temel özelliği! Kullanıcı telefonu salladığında `sensors_plus` ile bu algılanır ve bir eşleşme arama başlatılır. (`home_screen.dart`, `shaking_screen.dart` vb.)
- ❤️ **`match/`**: Sallama işleminden sonra bir eşleşme bulunduğunda gösterilen ekran (`match_found_screen.dart`).
- 💬 **`chat/` & `chats/`**: `chats` büyük ihtimalle konuşulan kişilerin listesi, `chat` ise aktif özel mesajlaşma ekranıdır. Zamanı biten eşleşmeler veya sohbetler için bir `chat_expired_screen.dart` mantığı mevcuttur.
- 👤 **`profile/` & `settings/`**: Kullanıcı profil bilgileri ve uygulama ayarları.
- 🏠 **`main/`**: Muhtemelen Alt Gezinme Çubuğunu (Bottom Navigation Bar) barındıran temel taşıyıcı iskelet ekran.

### 2. `lib/core/` (Çekirdek Servisler)
Hemen hemen uygulamanın her yerinde lazım olabilecek, iş mantığına sahip olan ve belirli bir "özelliğe" (feature) ait olmayan yapılar buradadır.
- **`services/`**: Veritabanı ve donanım işlerini yapan dosyalar.
  - `shake_service.dart`: Telefonun sallandığını algılayan mantık.
  - `location_service.dart`: Kişinin lokasyonunu alan (yakındaki kişileri bulmak için) mantık.
  - `media_service.dart`: Fotoğraf vb. seçme işlemleri.
  - `local_storage_service.dart`: Telefona ufak ayar ve dataları (`shared_preferences` ile) kaydetme servisi.
- **`error/`**: Hata (Exception/Failure) yakalama ve standartlaştırma sınıfları.

### 3. `lib/common/` (Ortak Yapılar)
Uygulama içinde hiçbir iş kodu (mantık) içermeyen ama arayüz için ortak olan yardımcılardır:
- **`router/app_router.dart`**: Tüm sayfalar arası geçiş yolları burada tanımlanır. (Örn: `/home`, `/chat/:matchId`). Hangi ekrana nasıl gidileceğini buradan görebilirsin.
- **`theme/app_theme.dart`**: Uygulamanın renkleri, fontları, karanlık mod (Dark Mode) / aydınlık mod renk ayarları.
- **`getit/injection.dart`**: Tüm servislerin, repository'lerin ve Cubit'lerin kayıt edildiği "Kayıt Merkezi".
- **`widgets/`**: Ortak butonlar, text inputlar, uygulamanın farklı yerlerinde tekrar tekrar kullanılacak UI parçaları.
- **`constants/`**: Sabit değişkenler, API anahtarları veya Asset (resim/icon) dosya yollarının metin (string) olarak tutulduğu yer.

---

## ⚙️ Uygulama Akışı Nasıl İlerliyor?

1. **Açılış (`main.dart`)**: Uygulama `Firebase.initializeApp` ve `initDependencies` ile gerekli kurulumları yaparak başlar.
2. **Kayıt ve Login**: Kullanıcı `auth` sayfasından geçer.
3. **Konum & İzinler**: Eşleşme sistemi çalıştığı için arka planda veya başta `location_service.dart` yardımıyla kullanıcıdan Konum izni (ve bildirim) alınır.
4. **Sallama (Shake)**: Kullanıcı `/main/shake` sayfasına gelir. `shake_service.dart` aracılığıyla telefon ivme ölçeri sensörleri (accelerometer) dinlenir. Telefon sallandığında sistem bunu algılar ve eşleşme (match) algoritmasını aktif eder.
5. **Eşleşme (Match)**: Sistemin arkasında (Firebase/Cloud Functions) veya cihazda iki farklı kullanıcının o anda sallaması, konuma göre bulunur ve iki taraf da `/match/:matchId` (MatchFoundScreen) sayfasına atılır.
6. **Sohbet (Chat)**: Eşleşen kişiler `/chat/:matchId` içerisinde Firebase Firestore üzerinden dinlenen mesaj sistemiyle konuşur.
7. **Süreli Konuşma**: Bu uygulamanın heyecanı! Bir süre kısıtı konulmuş görünüyor zira süre dolduğunda uygulama Router üzerinden kullanıcıyı `ChatExpiredScreen`'e yönlendiriyor.

## 💡 Kodlarını İncelerken Verebileceğim İpuçları

- Eğer "Uygulama nereden başlıyor? Sayfalar arası geçiş nerede?" diyorsan ilk bakman gereken yer: **`lib/main.dart`** ve **`lib/common/router/app_router.dart`**.
- Eğer "Arayüz rengini veya genel buton tasarımlarını nasıl değiştiririm?" diyorsan: **`lib/common/theme/app_theme.dart`**.
- Eğer bir ekranın tasarımına veya butonuna bakmak istiyorsan: Daima `lib/features/[ozellik-ismi]/presentation/pages/` içine git.
- Eğer sayfanın arkasındaki "Veri nereden geliyor? Login tıklandığında ne çalışıyor?" diyorsan o sayfanın **`cubit/`** klasöründeki dosyalara bakmalısın.

Uygulamanın mimarisi oldukça temiz, okunabilir ve profesyonel temeller üzerine kurgulanmış. Şimdiden kodlamada ve projeni incelemede başarılar dilerim!
