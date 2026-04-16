# Shakr Uygulama Sunumu ve Sistem Özeti 🚀

Bu doküman, Shakr uygulamasının mimari yapısını, çalışma mantığını ve teknik detaylarını sunumda kullanabileceğiniz şekilde özetlemektedir.

---

## 1. Uygulama Vizyonu ve Amacı 🌟
Shakr, kullanıcıların fiziksel olarak telefonlarını sallayarak (Shake) o an kendilerine yakın konumda bulunan ve aynı modda (Vibe) olan kişilerle eşleşmesini sağlayan dinamik bir sosyal etkileşim platformudur. 
**Ana Fikir:** Beklemeden, anlık ve oyunlaştırılmış bir eşleşme deneyimi.

---

## 2. Teknik Mimari (Clean Architecture) 🏗️
Uygulama, profesyonel standartlarda **Clean Architecture** prensipleriyle geliştirilmiştir. Bu sayede kodun bakımı kolaydır ve test edilebilirliği yüksektir.

### Katmanlar:
*   **Domain Layer:** Uygulamanın kalbidir. İş kurallarını (UseCases) ve veri yapılarını (Entities) barındırır.
*   **Data Layer:** Verilerin nereden ve nasıl geldiğini yönetir. Firebase entegrasyonu, veri modelleri (Models) ve API çağrıları bu katmandadır.
*   **Presentation Layer:** Kullanıcının gördüğü kısımdır. Flutter widget'ları ve **BloC (Cubit)** state yönetimi burada bulunur.

---

## 3. Sistem Akışı (Workflow) 🔄

### A. Eşleşme Öncesi (Shake & Match)
1.  **Sensör Dinleme:** `ShakeService` telefonun hareketini yakalar.
2.  **Kayıt:** Kullanıcı salladığında konumu ve vibe bilgisi `shakes` koleksiyonuna yazılır.
3.  **Arama:** Cloud Functions veya Listener yardımıyla `matches` koleksiyonunda bir eşleşme dokümanı oluşturulur.
4.  **Kabul Penceresi (15s):** Bir eşleşme bulunduğunda kullanıcının kabul etmesi için 15 saniyesi vardır. Her iki taraf kabul ettiğinde chat başlar.

### B. Geçici Sohbet (Temporary Chat) ⏳
1.  **Zaman Sınırı:** Sohbet ilk başladığında **30 saniye** sürer. `ChatCubit` içindeki timer bunu yönetir.
2.  **Gerginlik & Heyecan:** Bu aşama kullanıcıyı hızlı etkileşime teşvik eder.
3.  **Koleksiyon:** Mesajlar Firebase'de `'chats'` altında tutulur.

### C. Kalıcı Bağlantı (Promotion Flow) 💎
1.  **Çift Onay (Mutual Agreement):** Sohbet sonunda taraflara "Bağlantıyı Koru" seçeneği sunulur.
2.  **Veri Taşıma (Migration):** Her iki taraf da onay verirse, `moveToPermanentChat` fonksiyonu çalışır:
    *   Tüm mesajlar `'chats'` koleksiyonundan `'conversations'` koleksiyonuna taşınır.
    *   Diğer kullanıcının **adı ve fotoğrafı** denormalize edilerek (kopyalanarak) konuşma dokümanına yazılır (Hızlı yükleme için).
    *   Eski geçici match silinir.

---

## 4. Kullanılan Teknolojiler 🛠️
*   **Framework:** Flutter (Android & iOS).
*   **Backend:** Firebase (Auth, Firestore, Storage).
*   **State Management:** BloC / Cubit.
*   **Dependency Injection:** GetIt.
*   **Navigation:** GoRouter.

---

## 5. Sistem Denetimi (Gereksiz/Kullanılmayan Fonksiyonlar) 🧹

Sistem genelinde yapılan incelemede şu an aktif olarak kullanılmayan veya temizlenmesi sunumdan sonra önerilen kısımlar:

> [!NOTE]
> Bu fonksiyonlar kodda mevcuttur ancak şu anki kullanıcı akışında (v1.0) aktif bir tetikleyicisi (UI butonu vb.) bulunmamaktadır.

1.  **`ChatCubit.deleteConversation`**: Sohbet silme fonksiyonu hazır ancak arayüzde henüz sil butonu eklenmemiştir.
2.  **`MatchCubit.checkConnectionUsecase`**: Bağlantı kontrolü mantığı artık `moveToPermanentChat` içinde daha entegre yapılıyor, bağımsız UseCase şu an atıl durumda.
3.  **`OnboardingCubit.setAgeAndGender`**: Onboarding adımları 5'e bölündüğü için bu "toplu kaydetme" metodu yeni sistemde kullanılmamaktadır (Geriye dönük uyumluluk için durmaktadır).

---

### Sunum İçin İpucu 💡
*"Sistemimiz ölçeklenebilir bir mimari üzerine kurulu. Özellikle geçici sohbetten kalıcı sohbete geçişte verileri denormalize ederek Firestore okuma maliyetlerini azalttık ve uygulama hızını (UX) en üst seviyeye çıkardık."* diyerek teknik derinliğinizi gösterebilirsiniz.
