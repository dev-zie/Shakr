# Shakr — Kod Analiz Raporu

Bu rapor tüm Dart dosyaları incelenerek hazırlanmıştır. Elle girilen (hardcoded) değerler, eksik senaryolar ve önerilen düzeltmeler burada listelenmektedir.

---

## 1. Elle Girilen (Hardcoded) Değerler

### 1.1 Firebase Koleksiyon Adları

Koleksiyon adları her datasource'ta string literal olarak tekrar tekrar yazılmış. Herhangi bir koleksiyon adı değiştiğinde tüm dosyaları taramak gerekecek.

**Etkilenen dosyalar:**
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/match/data/datasources/match_remote_datasource.dart`
- `lib/features/chat/data/datasources/chat_remote_datasource.dart`
- `lib/features/shake/data/datasources/shake_remote_datasource.dart`

**Önerilen çözüm — yeni dosya:** `lib/common/constants/app_firebase.dart`

```dart
class AppFirebase {
  AppFirebase._();

  // Koleksiyonlar
  static const String colUsers         = 'users';
  static const String colShakes        = 'shakes';
  static const String colMatches       = 'matches';
  static const String colChats         = 'chats';
  static const String colConversations = 'conversations';
  static const String colMessages      = 'messages';

  // Storage yolları
  static const String storageProfilePhotos = 'profile_photos';

  // Match alan adları
  static const String fieldUser1              = 'user1';
  static const String fieldUser2              = 'user2';
  static const String fieldUsers              = 'users';
  static const String fieldStatus             = 'status';
  static const String fieldCreatedAt          = 'createdAt';
  static const String fieldChatStartedAt      = 'chatStartedAt';
  static const String fieldUser1Accepted      = 'user1Accepted';
  static const String fieldUser2Accepted      = 'user2Accepted';
  static const String fieldUser1KeepConn      = 'user1KeepConnection';
  static const String fieldUser2KeepConn      = 'user2KeepConnection';
  static const String fieldUser1Vibes         = 'user1Vibes';
  static const String fieldUser2Vibes         = 'user2Vibes';
  static const String fieldParticipants       = 'participants';
  static const String fieldLastMessage        = 'lastMessage';
  static const String fieldLastMessageAt      = 'lastMessageAt';

  // Kullanıcı alan adları
  static const String fieldUid      = 'uid';
  static const String fieldName     = 'name';
  static const String fieldAge      = 'age';
  static const String fieldGender   = 'gender';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldVibes    = 'vibes';

  // Mesaj alan adları
  static const String fieldSenderId = 'senderId';
  static const String fieldText     = 'text';

  // Match durumları
  static const String statusWaiting = 'waiting';
  static const String statusActive  = 'active';
  static const String statusExpired = 'expired';
  static const String statusMatched = 'matched';
  static const String statusUnknown = 'unknown';

  // Cinsiyet değerleri
  static const String genderMale   = 'male';
  static const String genderFemale = 'female';
}
```

---

### 1.2 Süre (Duration) Değerleri

| Değer | Dosya | Satır | Açıklama |
|-------|-------|-------|----------|
| `Duration(seconds: 15)` | `shake_cubit.dart` | 96 | Eşleşme kabul penceresi |
| `Duration(seconds: 30)` | `chat_cubit.dart` | 65 | Geçici sohbet süresi |
| `300` (int) | `chat_cubit.dart` | 82, 138 | Bekleme ekranında gösterilen süre (saniye) |
| `Duration(seconds: 5)` | `location_service.dart` | 17, 30 | Konum servis timeout |
| `Duration(seconds: 3)` | `splash_screen.dart` | 21 | Splash bekleme süresi |
| `Duration(seconds: 3)` | `custom_snackbar.dart` | 26 | Snackbar görünme süresi |
| `Duration(milliseconds: 16)` | `shake_cubit.dart` | 61 | Radar animasyon tick aralığı |
| `3000` (int) | `shake_cubit.dart` | 62 | Radar bir tur tamamlama süresi (ms) |
| `Duration(milliseconds: 300)` | `intro_step.dart` | 149 | Intro geçiş animasyonu |

**`AppConstants`'a eklenecek değerler:**

```dart
// Süreler (saniye)
static const int matchAcceptWindowSecs  = 15;
static const int tempChatDurationSecs   = 30;
static const int chatWaitingDisplaySecs = 300;
static const int locationTimeoutSecs    = 5;
static const int splashDelaySeconds     = 3;
static const int snackbarDurationSecs   = 3;

// Radar animasyonu (ms)
static const int radarTickMs       = 16;
static const int radarCycleDurMs   = 3000;
```

---

### 1.3 UI Boyut Değerleri

| Değer | Dosya | Açıklama |
|-------|-------|----------|
| `150` (double) | `splash_body.dart:24-25` | Logo genişlik/yükseklik |
| `300` (double) | `shake_body.dart:37-38` | Radar widget boyutu |
| `300` (double) | `birth_year_picker_dialog.dart:25` | Tarih seçici yüksekliği |
| `54` (double) | `app_theme.dart:81,204` | Buton yüksekliği |
| `16` (double) | `vibe_chip.dart:26` | İkon boyutu |

**`AppConstants`'a eklenecek değerler:**

```dart
// UI boyutları
static const double logoSize        = 150.0;
static const double radarSize       = 300.0;
static const double pickerHeight    = 300.0;
static const double buttonHeight    = 54.0;
static const double iconSizeSmall   = 16.0;
```

---

### 1.4 Shake Algılama Eşiği

| Değer | Dosya | Satır | Açıklama |
|-------|-------|-------|----------|
| `15.0` | `shake_service.dart` | 8 | İvme eşiği (m/s²) |

**Önerilen konum:** `AppConstants` içinde

```dart
// Shake algılama
static const double shakeThreshold = 15.0;
```

---

### 1.5 Responsive Breakpoint'ler

`responsive_helper.dart` içindeki `600` ve `1200` değerleri `AppConstants`'a taşınabilir:

```dart
// Ekran boyutu kırılma noktaları
static const double breakpointTablet  = 600.0;
static const double breakpointDesktop = 1200.0;
```

---

## 2. Önerilen Sabit Dosyaları (Özet)

```
lib/common/constants/
├── app_constants.dart   ← Mevcut (genişletilecek)
├── app_strings.dart     ← Mevcut (yeterli)
├── app_enums.dart       ← Mevcut
├── app_assets.dart      ← Mevcut
├── app_spacing.dart     ← Mevcut
├── app_radius.dart      ← Mevcut
├── app_vibes.dart       ← Mevcut
└── app_firebase.dart    ← YENİ (oluşturulacak)
```

---

## 3. Eksik Senaryolar ve Boşluklar

### 3.1 Kritik — Veri Tutarlılığı

#### Hesap Silme Yarı Yolda Kalırsa
**Dosya:** `auth_remote_datasource.dart:68-120`  
**Sorun:** Firestore batch silme işlemi gerçekleşse ama `auth.currentUser?.delete()` başarısız olursa kullanıcı verisi silinmiş fakat auth hesabı ayakta kalır. Uygulama bir daha açılınca yönlendirme karışır.  
**Öneri:** Auth silmeyi Firestore silmeden önce dene veya her ikisini de ayrı `try-catch` ile yönet; hata durumunu kullanıcıya bildirme ekle.

#### Kalıcı Sohbete Geçişte Race Condition
**Dosya:** `match_remote_datasource.dart:82-154`  
**Sorun:** İki kullanıcı aynı anda "Bağlantıyı Koru" butonuna basarsa her ikisi de `moveToPermanentChat`'i çalıştırabilir; sonuçta `conversations` koleksiyonuna iki kez yazma ya da kısmi yazma gerçekleşebilir.  
**Öneri:** Firestore Transaction kullan; `conversations/{matchId}` dokümanı yoksa yaz, varsa atla mantığıyla.

#### Mesajlar Kopyalanırken Bağlantı Koparsa
**Dosya:** `match_remote_datasource.dart:89-154`  
**Sorun:** `chats/{matchId}/messages` koleksiyonu büyükse ve kopyalama başarısız olursa eski geçici chat silinmez ama `conversations` dokümanı kısmen oluşmuş olabilir.  
**Öneri:** Tüm batch işlemlerini atomik bir transaction içine al; başarılı commit sonrasında eski dokümanı sil.

---

### 3.2 Yüksek Öncelik — Kullanıcı Deneyimi

#### Konum İzni Reddedildiğinde
**Dosya:** `location_service.dart`  
**Sorun:** `Permission.location.request()` reddedildiğinde catch'e düşüp `null` döndürülüyor. Bu null konum, shake kaydına `null` GeoPoint olarak yazılabilir.  
**Öneri:** İzin reddedildikten sonra kullanıcıya "Konum izni olmadan yakınındaki kişileri bulamayız" uyarısı göster; eşleşme akışını başlatma.

#### Shake Timer Sırasında Uygulama Arka Plana Alınırsa
**Dosya:** `shake_cubit.dart`  
**Sorun:** Kullanıcı telefonu salladıktan sonra 15 saniyelik pencere içinde uygulamayı arka plana alırsa timer çalışmaya devam eder. Kullanıcı geri döndüğünde zaman dolmuş olabilir ve herhangi bir uyarı gösterilmez.  
**Öneri:** `AppLifecycleState` dinleyerek arka plana geçildiğinde timer'ı duraklat ya da en azından kullanıcıyı bilgilendir.

#### Mesaj Kutusu Boşken Gönder Butonu
**Dosya:** `chat_cubit.dart` / `chat_screen.dart`  
**Sorun:** Boş string gönderilebilir mi? `sendMessageFromInput()` içinde giriş doğrulama var mı kontrol et.  
**Öneri:** `trim().isNotEmpty` kontrolü ekle; boşsa butonu disable yap.

#### Süre Dolduğunda Açık Klavye
**Dosya:** `chat_screen.dart` / `chat_cubit.dart`  
**Sorun:** Kullanıcı yazarken süre dolup `/chat-expired` ekranına yönlendirilirse klavye açık kalabilir.  
**Öneri:** `ChatTimeExpiredState` geldiğinde `FocusScope.of(context).unfocus()` çağır.

---

### 3.3 Orta Öncelik — Hata Yönetimi

#### Stream Hataları Yakalanmıyor
**Dosya:** `chat_repository_impl.dart:56-86`, `match_remote_datasource.dart:13`  
**Sorun:** Firestore stream abonelikleri yalnızca `map` işlemini sarıyor; gerçek ağ hatası (offline, izin iptali) `onError` ile handle edilmiyor.  
**Öneri:** Stream subscribe olurken `onError` callback ekle:
```dart
.listen(
  (data) => ...,
  onError: (e) => emit(ChatError('Bağlantı kesildi')),
);
```

#### Cubit Kapandıktan Sonra Emit
**Dosya:** `match_cubit.dart`, `chat_cubit.dart`  
**Sorun:** `_acceptTimer` veya `_timer` callback'i tetiklendiğinde cubit zaten `close()` edilmiş olabilir. `emit()` closed bir stream'e yazarsa exception fırlar.  
**Öneri:** Her timer callback'inde `if (isClosed) return;` ekle.

#### Firestore Timestamp Null Safety
**Dosya:** `match_model.dart`, `message_model.dart`, `conversation_model.dart`  
**Sorun:** `map['createdAt'] as Timestamp` — eğer Firestore dokümanı bu alanı içermiyorsa (ör: geç yazılan serverTimestamp) `null as Timestamp` hata fırlatır.  
**Öneri:**
```dart
createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
```

---

### 3.4 Düşük Öncelik — Performans ve Güvenlik

#### Fotoğraf Yükleme Doğrulama Eksik
**Dosya:** `auth_remote_datasource.dart:62-65`  
**Sorun:** Dosya boyutu ve format kontrolü yok. Kullanıcı 50MB PNG yüklemeye çalışırsa timeout'a ya da storage quota hatasına düşer.  
**Öneri:** `media_service.dart`'ta `File.lengthSync()` ile boyut kontrolü; izin verilen format listesi (jpg, png, heic).

#### Mesaj Tekrar Gönderme (Duplicate)
**Dosya:** `chat_remote_datasource.dart:25-45`  
**Sorun:** Gönder butonuna hızlı iki kez tıklanırsa veya ağ yavaşsa aynı mesaj çift gönderilebilir.  
**Öneri:** `SendMessageUsecase` çağrısını UI'dan tetiklerken `ChatCubit`'te basit bir `_isSending` flag'i ekle.

#### Eski Shake Kaydı Temizlenmiyor
**Dosya:** `shake_remote_datasource.dart`  
**Sorun:** Kullanıcı eşleşmeden önce uygulamayı kapattıysa `shakes/{uid}` koleksiyonunda eski kayıt kalabilir ve sonraki oturumda yanlış eşleşmeye yol açabilir.  
**Öneri:** Uygulama başlatılırken (Splash) veya ShakingScreen'e girilirken `deleteShake()` çağır.

---

## 4. Mevcut Sabitler ile Karşılaştırma

| Kategori | Mevcut | Eksik |
|----------|--------|-------|
| Animasyon süreleri | ✅ `animationDurationFast/Medium/Slow` | — |
| Border radius | ✅ `borderRadiusS/M/L/XL` | — |
| Yaş limitleri | ✅ `minUserAge`, `maxUserAge` | — |
| Firebase koleksiyon adları | ❌ | `AppFirebase` sınıfı oluşturulmalı |
| Oyun süreleri (15s, 30s, 300s) | ❌ | `AppConstants`'a eklenmeli |
| Shake eşiği (15.0) | ❌ | `AppConstants`'a eklenmeli |
| UI boyutları (logo 150, radar 300) | ❌ | `AppConstants`'a eklenmeli |
| Snackbar süresi (3s) | ❌ | `AppConstants`'a eklenmeli |
| Konum timeout (5s) | ❌ | `AppConstants`'a eklenmeli |
| Radar animasyon (16ms, 3000ms) | ❌ | `AppConstants`'a eklenmeli |

---

## 5. Öneri Sıralaması

| Öncelik | İş | Dosya |
|---------|-----|-------|
| 🔴 Kritik | `AppFirebase` sabit dosyası oluştur | `lib/common/constants/app_firebase.dart` |
| 🔴 Kritik | Hesap silme akışına rollback ekle | `auth_remote_datasource.dart` |
| 🔴 Kritik | `moveToPermanentChat`'i transaction'a al | `match_remote_datasource.dart` |
| 🟠 Yüksek | Konum izni reddine kullanıcı mesajı ekle | `location_service.dart` + shake UI |
| 🟠 Yüksek | Timer callback'lerinde `isClosed` kontrolü | `match_cubit.dart`, `chat_cubit.dart` |
| 🟠 Yüksek | Stream `onError` handler ekle | `chat_repository_impl.dart` |
| 🟡 Orta | Oyun sürelerini `AppConstants`'a taşı | `chat_cubit.dart`, `shake_cubit.dart` |
| 🟡 Orta | UI boyutlarını `AppConstants`'a taşı | `splash_body.dart`, `shake_body.dart` |
| 🟡 Orta | Timestamp null-safety ekle | model dosyaları |
| 🟢 Düşük | Gönder butonu için `_isSending` flag | `chat_cubit.dart` |
| 🟢 Düşük | Fotoğraf boyut/format doğrulama | `media_service.dart` |
| 🟢 Düşük | Splash'ta eski shake kaydını temizle | `splash_screen.dart` |
