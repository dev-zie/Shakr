# Konum Servisi: Sessiz Geri Dönüş Mekanizması

## Neden Bu Değişiklik?

Uygulama, kullanıcı GPS iznini reddetse bile çalışmaya devam eder. Reddedildiğinde IP adresi üzerinden şehir seviyesinde bir konum alınır. Bu davranış kullanıcıya bildirilmeden gerçekleşir — yani kullanıcıya hiçbir uyarı gösterilmez, snackbar açılmaz, UI değişmez.

---

## Konum Alma Akışı

```
kullanıcı shake yapar
        │
        ▼
LocationService.getCurrentLocation()
        │
        ├─ GPS izni VAR → Geolocator.getCurrentPosition() → GeoPoint(lat, lon)
        │
        └─ GPS izni YOK → _getCityLocation() → IP ile şehir merkezi → GeoPoint(lat, lon)
                                    │
                                    └─ IP de başarısız → GeoPoint(0, 0)
```

Her durumda dönen tip aynıdır: `LocationResult` (sadece `GeoPoint location` alanı vardır).

---

## Kaldırılan `isFallback` Zinciri

Önceden `isFallback: true/false` bayrağı şu zincir boyunca taşınıyordu:

```
LocationResult.isFallback
    → ShakeCubit.recordShake(shake, isFallback: ...)
        → ShakeRecorded(isFallbackLocation: isFallback)
            → ShakingScreen listener: snackbar göster
```

Bu zincirin tamamı kaldırıldı:

| Dosya                                                       | Yapılan Değişiklik                                                  |
| ----------------------------------------------------------- | ------------------------------------------------------------------- |
| `lib/core/models/location_result.dart`                      | `isFallback` alanı silindi                                          |
| `lib/core/services/location_service.dart`                   | Tüm `isFallback` referansları kaldırıldı                            |
| `lib/features/shake/presentation/cubit/shake_state.dart`    | `ShakeRecorded.isFallbackLocation` kaldırıldı                       |
| `lib/features/shake/presentation/cubit/shake_cubit.dart`    | `recordShake({bool isFallback})` parametresi kaldırıldı             |
| `lib/features/shake/presentation/widgets/shake_body.dart`   | `isFallback: locationResult.isFallback` çağrısı kaldırıldı          |
| `lib/features/shake/presentation/pages/shaking_screen.dart` | Ölü `isFallbackLocation` bloğu ve `app_strings` import'u kaldırıldı |

---

## Şu Anki `LocationResult` Modeli

```dart
class LocationResult {
  final GeoPoint location;
  const LocationResult({required this.location});
}
```

Tek alan: konum. Nasıl elde edildiği bilgisi dışarıya sızamaz.

---

## Eşleşme Kalitesine Etkisi

- GPS izni verilen iki kullanıcı → gerçek koordinatlar karşılaştırılır, hassas yakınlık tespiti.
- GPS izni verilmeyen iki kullanıcı → her ikisi de şehir merkezi koordinatıyla kaydedilir; aynı şehirde olup olmadıkları anlaşılır ama cadde düzeyinde kesinlik yoktur.
- Karma durum (biri izinli, diğeri değil) → geohash sorgusu yine de çalışır, şehir mesafesi kadar tolerans oluşur.

Eşleşme algoritması bu farklılıktan habersizdir; `GeoPoint` alır ve geohash hesabı yapar.
