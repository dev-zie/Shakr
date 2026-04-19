# Cubit State Mimarisi: Enum-Tabanlı Tek Sınıf Desenine Geçiş

## Neden Bu Değişiklik?

**Önceki desen — subclass hiyerarşisi:**

```dart
class ShakeState {}
class ShakeInitial extends ShakeState { ... }
class ShakeDetected extends ShakeState { ... }
class ShakeError extends ShakeState { final String message; }
```

**Yeni desen — tek sınıf + enum (AuthState'in deseni):**

```dart
enum ShakeCubitStatus { initial, detected, recorded, noMatch, error }

class ShakeState extends Equatable {
  final ShakeCubitStatus status;
  final String? errorMessage;
  // ...
}
```

### Avantajları

- Tek bir `copyWith` ile durum geçişleri; `as` dönüşümü yok.
- Veri tutarlı kalır — state değişince tüm alanlar korunur.
- `state is XxxSubclass` yerine `state.status == XxxStatus.xxx` okunabilirliği daha yüksektir.
- Tüm cubitler aynı kalıbı izler; birini anlayan hepsini anlar.

---

## Değiştirilen Dosyalar

### State Dosyaları (6 dosya)

| Dosya                   | Yeni Enum          | Taşınan Alanlar                                                                                           |
| ----------------------- | ------------------ | --------------------------------------------------------------------------------------------------------- |
| `shake_state.dart`      | `ShakeCubitStatus` | `errorMessage`                                                                                            |
| `match_state.dart`      | `MatchCubitStatus` | `match`, `errorMessage`                                                                                   |
| `chat_state.dart`       | `ChatStatus`       | `messages`, `conversations`, `secondsLeft`, `errorMessage`                                                |
| `profile_state.dart`    | `ProfileStatus`    | `user`, `editName`, `editAge`, `editGender`, `editVibes`, `isEditing`, `isUploadingPhoto`, `errorMessage` |
| `settings_state.dart`   | `SettingsStatus`   | `selectedVibes`, `notificationsEnabled`, `errorMessage`                                                   |
| `onboarding_state.dart` | `OnboardingStatus` | `step`, `name`, `age`, `gender`, `photoUrl`, `vibes`, `errorMessage`                                      |

> **Not:** `ShakeCubitStatus` ve `MatchCubitStatus` — entity dosyalarında (`shake_entity.dart`, `match_entity.dart`) aynı isimde enum zaten vardı. Çakışmayı önlemek için cubit enum'ları `*CubitStatus` ön ekiyle adlandırıldı.

### Cubit Dosyaları (6 dosya)

Her cubitte yapılan genel değişiklikler:

| Eski                               | Yeni                                                      |
| ---------------------------------- | --------------------------------------------------------- |
| `super(ShakeInitial())`            | `super(const ShakeState())`                               |
| `emit(ShakeDetected())`            | `emit(state.copyWith(status: ShakeCubitStatus.detected))` |
| `if (state is! ShakeInitial)`      | `if (state.status != ShakeCubitStatus.initial)`           |
| `final s = state as ProfileLoaded` | `state.field` (doğrudan erişim)                           |
| `_currentStep()` (OnboardingCubit) | kaldırıldı — `state` doğrudan kullanılıyor                |

### UI Dosyaları (15 dosya)

| Eski                                                | Yeni                                          |
| --------------------------------------------------- | --------------------------------------------- |
| `if (state is ShakeError)`                          | `if (state.status == ShakeCubitStatus.error)` |
| `(state as ShakeError).message`                     | `state.errorMessage ?? ''`                    |
| `final ProfileLoaded state` parametresi             | `final ProfileState state`                    |
| `final OnboardingStepChanged state` parametresi     | `final OnboardingState state`                 |
| `state is OnboardingStepChanged ? state.vibes : []` | `state.vibes`                                 |

---

## Enum Değerleri Referansı

### ShakeCubitStatus

`initial` → `detected` → `recorded` → (timer) → `noMatch`  
Hata: `error`

### MatchCubitStatus

`initial` → `loading` → `found` → `acceptancePending` → `accepted`  
Süre dolunca: `expired` → `bothKept` / `connectionPending`  
Diğer: `notFound`, `deleted`, `cooldownActive`, `error`

### ChatStatus

`initial` → `loading` → `timerTick` (mesajlar + sayaç)  
Bitişte: `timeExpired` / `conversationDeleted`  
Konuşma listesi: `conversationsLoaded`  
Hata: `error`

### ProfileStatus

`initial` → `loading` → `loaded` ↔ (düzenleme döngüsü)  
Başarı sinyali: `updatedSuccess` (hemen `loaded`'a döner)  
Foto hatası: `photoUploadError` (hemen `loaded`'a döner)  
Hata: `error`

### SettingsStatus

`loaded` (başlangıç değeri — ayarlar her zaman erişilebilir)  
`accountDeleted`, `error`

### OnboardingStatus

`initial` → `stepChanged` (adım 0-5 arası) → `completed`  
Hata: `error`

---

## İki-Emit Deseni (Geçici Durum Sinyalleri)

`ProfileCubit`'te bazı işlemler önce sinyal durumu, hemen ardından asıl durumu emit eder:

```dart
// Fotoğraf yükleme hatası
emit(state.copyWith(status: ProfileStatus.photoUploadError, errorMessage: '...'));
emit(state.copyWith(status: ProfileStatus.loaded));  // UI'ya form geri döner

// Profil güncelleme başarısı
emit(state.copyWith(status: ProfileStatus.updatedSuccess, user: updatedUser));
emit(state.copyWith(status: ProfileStatus.loaded, editName: updatedUser.name, ...));
```

Bu desen, listener'ın snackbar/navigasyon tetikleyebilmesi için bir "an" yaratır; ardından UI kullanılabilir duruma döner. Subclass deseninde de aynı yaklaşım kullanılıyordu.
