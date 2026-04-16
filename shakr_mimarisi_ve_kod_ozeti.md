# 🚀 Shakr App: Teknik Mimari ve Senaryo Bazlı Kod Akışı (V3)

Bu belge, **Shakr** uygulamasının stateless Cubit mimarisini, Firestore tabanlı reaktif akışlarını ve kullanıcı deneyiminin (UX) teknik karşılıklarını detaylandırmak için hazırlanan güncel rehberdir.

---

## 🏛 1. Sistem Mimarisi

Uygulama, **Clean Architecture** prensiplerinden ilham alan 4 temel katman üzerine kuruludur:

-   **Data:** Remote Datasource (Firestore), Models (JSON mapping).
-   **Domain:** Entities, Repositories (Interface), Use Cases (Business Logic).
-   **Presentation:** Cubits (State Management), Screens & Widgets.
-   **Core:** Errors, Constants (Colors, Spacing), DI (GetIt).

> [!IMPORTANT]
> Tüm akış **Stateless**'tır. Durumlar (State), Firestore stream'lerinin Cubit'ler tarafından dinlenmesi ve UI'ın `BlocBuilder`/`BlocListener` ile reaktif olarak güncellenmesiyle yönetilir.

---

## 🔄 2. Kullanıcı Senaryoları ve Kod Akışları

### **Senaryo A: Başlangıç ve Hazırlık**
1.  **Splash & Auth:** `SplashScreen`, kullanıcının oturum durumunu kontrol eder. Kullanıcı yoksa `OnboardingScreen`'e yönlendirir.
2.  **Main Screen (Home):** Uygulama `MainScreen` ile açılır. Burada 3 ana sekme bulunur: **Shake (Radar), Chats (Mesajlar), Profile (Profil)**.
3.  **Radar Aktivasyonu:** `ShakeCubit`, fiziksel ivmeölçeri sadece Shake sekmesi aktifken dinler.

### **Senaryo B: Eşleşme ve "Büyük Karar" Aşaması**
1.  **Sallama (Matchmaking):** Kullanıcı telefonunu salladığında `shakes` koleksiyonuna bir doküman eklenir. `Cloud Functions` veya repository tabanlı eşleştirme algoritması uygun birini bulunca `matches` koleksiyonunda yeni bir doküman oluşturulur.
2.  **Match Found:** `MatchCubit` bu yeni kaydı yakalar ve kullanıcıyı `MatchFoundScreen`'e yönlendirir.
3.  **15 Saniyelik Karar (Decision Phase):** `MatchFoundBody` içinde 15 saniyelik dairesel bir geri sayım başlar.
    *   **Kabul:** Kullanıcı "Sohbete Başla" dediğinde `AcceptMatchUsecase` tetiklenir ve `userXAccepted = true` olur.
    *   **Bekleme:** Bir taraf kabul edip diğeri etmemişse ekran `MatchAcceptancePending` durumuna geçer ve "Onay bekleniyor..." yazar.
    *   **İptal:** Sayaç biterse veya bir taraf "İptal" derse `DeleteMatchUsecase` ile kayıt silinir ve radar ekranına dönülür.
    *   **Mutabakat:** Her iki taraf da kabul ettiğinde akış doğrudan `/chat/:matchId` rotasına akar.

### **Senaryo C: 5 Dakikalık Gizli Sohbet ve Kalıcılık**
1.  **Geçici Chat:** Sohbet `chats` koleksiyonu üzerinden yürür. `ChatCubit` 5 dakikalık bir geri sayım yönetir.
2.  **Bağlantıyı Koruma:** Süre sonunda (veya her an) kullanıcı "Bağlantıyı Koru" butonuna basabilir (`KeepConnectionUsecase`).
3.  **Kalıcı Arkadaşlığa Geçiş (Move to Permanent):**
    *   Eğer her iki taraf da onay verirse, `MoveToPermanentChatUsecase` devreye girer.
    *   Tüm `chats` mesajları okunur ve `conversations` koleksiyonuna kopyalanır.
    *   Eski `match` dokümanı silinir. Kullanıcı radar ekranında "özgür" kalırken, mesajları "Mesajlar" sekmesine WhatsApp tarzı kalıcı olarak düşer.

### **Senaryo D: Mesajlar Sekmesi ve WhatsApp Deneyimi**
1.  **WhatsApp Style List:** `MyChatsScreen`, `conversations` koleksiyonunu `StreamBuilder` ile dinler.
2.  **Mesaj Listeleme:** Kullanıcı ismi, son mesaj ve akıllı zaman formatı (Bugünse saat, dünse "Dün") ile listelenir.
3.  **Sınırsız Sohbet:** Bu listeden tıklanan sohbetler `isPermanent: true` bayrağı ile `ChatScreen`'e gider. Burada artık 5 dakikalık süre kısıtı yoktur.

---

## 📂 3. Kritik Veri Yapıları (Firestore)

| Koleksiyon | Amaç | Kritik Alanlar |
| :--- | :--- | :--- |
| `matches` | Geçici eşleşme ve karar süreci | `status`, `userXAccepted`, `userXKeepConnection` |
| `chats` | 5 dakikalık gizli sohbet mesajları | `matchId`, `text`, `createdAt`, `senderId` |
| `conversations` | Kalıcı arkadaşlıklar ve WhatsApp mesajları | `participants`, `lastMessage`, `lastMessageAt`, `userXName` |
| `users` | Minimalist profil verileri | `name`, `age`, `vibes` |

---

## 🎨 4. Tasarım İlkeleri

-   **Görsel Dil:** `AppSpacing` ve `AppColors` üzerinden yönetilen, koyu mod odaklı ve temiz (premium) bir arayüz.
-   **Geri Bildirim:** Mikro animasyonlar ve Lottie dosyaları ile (matching süreci vb.) kullanıcıya akış hakkında canlı bilgi verilir.
-   **Minimalizm:** Sadece o an gerekli olan butonlar gösterilir (Karar aşamasında sadece kabul/red, chat bittiğinde koruma butonları).

---

> [!TIP]
> **Geliştirici Notu:** Bu yapı sayesinde veritabanı maliyetleri minimize edilmiştir (geçici kayıtlar silinir) ve kullanıcılar sadece "gerçekten" bağlantı kurmak istedikleri kişileri kalıcı listelerinde görürler.
