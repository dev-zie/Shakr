# Cloud Function: findMatch

`functions/index.js` dosyasındaki tek Cloud Function'ın satır satır açıklaması.

---

## Genel Bakış

```
Tetikleyici: shakes/{uid} koleksiyonuna yeni döküman eklendiğinde
Bölge: europe-west3 (Frankfurt)
Amaç: Sallayan kullanıcıya uygun bir eşleşme bul ve matches dökümanı oluştur
```

Bu fonksiyon client'ta değil, Firebase sunucusunda çalışır.
İki kullanıcı aynı anda salladığında her ikisi için ayrı tetiklenir —
sunucu taraflı olduğu için yarış koşulları (race condition) Firestore transaction'ları ile güvence altına alınır.

---

## Kod Açıklaması — Adım Adım

### 1. Kurulum (dosyanın tepesi)

```javascript
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const geolib = require("geolib");

admin.initializeApp();
const db = admin.firestore();
```

| Satır | Ne yapar |
|-------|----------|
| `onDocumentCreated` | Firestore v2 trigger — koleksiyona yeni doc eklenince çalışır |
| `admin` | Firebase Admin SDK — sunucu tarafında Firestore'a tam erişim sağlar |
| `geolib` | İki koordinat arasındaki mesafeyi metre cinsinden hesaplayan kütüphane |
| `admin.initializeApp()` | Firebase bağlantısını başlatır, her fonksiyon dosyasında bir kez yapılır |
| `db` | Firestore örneği — tüm okuma/yazma işlemleri bu üzerinden yapılır |

---

### 2. Fonksiyon Tanımı ve Tetikleyici

```javascript
exports.findMatch = onDocumentCreated({
    document: "shakes/{uid}",
    region: "europe-west3",
}, async (event) => {
```

- `exports.findMatch` → fonksiyonu dışa aktarır, Firebase bu isimle deploy eder
- `document: "shakes/{uid}"` → `shakes` koleksiyonuna herhangi bir döküman eklenince tetiklenir; `{uid}` wildcard'dır, kim eklerse onun UID'i olur
- `region: "europe-west3"` → fonksiyon Frankfurt sunucusunda çalışır (Türkiye'ye yakın olduğu için gecikme düşük)
- `async` → içinde `await` kullanılacak, asenkron işlemler var

---

### 3. Olay Verisini Al

```javascript
const snap = event.data;
const newShake = snap.data();
const uid = event.params.uid;
```

- `event.data` → yeni oluşturulan Firestore dökümanının snapshot'ı
- `snap.data()` → dökümanın içindeki veriyi JavaScript objesi olarak alır (`location`, `timestamp`, `vibes`, `status`)
- `event.params.uid` → URL pattern'indeki `{uid}` wildcard'ının değeri — hangi kullanıcının shake'i tetikledi

---

### 4. Veri Doğrulama (Guard)

```javascript
if (!newShake || !newShake.location || !newShake.timestamp) {
    console.log("Geçersiz veya eksik shake verisi.");
    return null;
}
```

Eksik veri varsa fonksiyon erken çıkar. `return null` Cloud Function'da "başarıyla tamamlandı ama işlem yapılmadı" anlamına gelir. `throw` edilseydi fonksiyon hata sayılıp retry edilirdi — burada istemiyoruz.

---

### 5. Aday Listesini Çek (Zaman Filtresi)

```javascript
const fiveSecondsAgo = new Date(Date.now() - 5000);

const candidatesSnap = await db
    .collection("shakes")
    .where("status", "==", "waiting")
    .where("timestamp", ">=", fiveSecondsAgo)
    .get();
```

Firestore'dan son 5 saniye içinde `waiting` durumundaki tüm shake'leri çeker.

**Neden `fiveSecondsAgo`?**
Firestore'un `where` filtresi sunucu timestamp'lerine göre çalışır.
`Date.now() - 5000` → şu andan 5 saniye öncesini hesaplar.
Bu tarihten **sonra** oluşturulan shake'ler aday listesine girer.

**Neden status == "waiting"?**
Zaten eşleşmiş (`matched`) veya aktif (`active`) kullanıcılar tekrar eşleşmesin diye.

---

### 6. Geçersiz Adayları Filtrele

```javascript
const validCandidates = candidatesSnap.docs.filter((doc) => {
    if (doc.id === uid) return false;           // kendini eşleştirme
    const candidateData = doc.data();
    if (!candidateData.location) return false;  // konumu eksik

    // ±5 saniye zaman farkı
    const timeDiff = Math.abs(
        newShake.timestamp.toDate() - candidateData.timestamp.toDate()
    );
    if (timeDiff > 5000) return false;

    // 150 metre mesafe
    const distance = geolib.getDistance(
        { latitude: newShake.location.latitude, longitude: newShake.location.longitude },
        { latitude: candidateData.location.latitude, longitude: candidateData.location.longitude }
    );
    return distance <= 150;
});
```

Her adayı 4 kritere göre filtreler:

| Kriter | Kod | Neden |
|--------|-----|-------|
| Kendisi değil | `doc.id === uid` | Kişi kendisiyle eşleşemez |
| Konumu var | `!candidateData.location` | Eksik veriyle hesaplama yapılamaz |
| ±5 sn zaman farkı | `timeDiff > 5000` | Sadece aynı anda sallayanlar eşleşir |
| ≤150 metre mesafe | `distance <= 150` | Fiziksel yakınlık şartı |

**`timestamp.toDate()`** → Firestore Timestamp objesini JavaScript Date'e çevirir, çıkarma işlemi milisaniye verir.

**`geolib.getDistance()`** → İki koordinat arasındaki düz mesafeyi metre cinsinden döndürür. Haversine formülü kullanır (dünya yuvarlaklığını hesaba katar).

---

### 7. Aday Bulunamazsa Çık

```javascript
if (validCandidates.length === 0) {
    console.log("Yakınlarda uyumlu shake bulunamadı, bekleniyor...");
    return null;
}
```

Geçerli aday yoksa fonksiyon durur. Shake dökümanı Firestore'da kalır.
Client tarafında `ShakeCubit` 15 saniye bekler, kimse eşleşmezse `noMatch` state'i emit eder ve shake dökümanını siler.

---

### 8. Vibe Uyumuna Göre Sırala

```javascript
const myVibes = newShake.vibes ?? [];
validCandidates.sort((a, b) => {
    const aVibes = a.data().vibes ?? [];
    const bVibes = b.data().vibes ?? [];
    const aShared = aVibes.filter(v => myVibes.includes(v)).length;
    const bShared = bVibes.filter(v => myVibes.includes(v)).length;
    return bShared - aShared;
});
```

Geçerli adayları ortak vibe sayısına göre büyükten küçüğe sıralar.

**Nasıl çalışır:**
```
Benim vibelerim:    [müzik, spor, doğa]

Aday A vibeleri:    [müzik, spor, yemek]  → 2 ortak
Aday B vibeleri:    [müzik, film, seyahat] → 1 ortak
Aday C vibeleri:    [yemek, sanat, dans]   → 0 ortak

Sıralama sonucu: [A, B, C]
→ A ile eşleşilir
```

`?? []` → vibe alanı null/undefined ise boş dizi kullan (eski kullanıcı verileri için güvenlik).

`return bShared - aShared` → negatif değer A'yı öne alır, pozitif B'yi — bu JavaScript sort'un çalışma mantığı.

---

### 9. En Uyumlu Adayla Eşleş

```javascript
const matchDoc = validCandidates[0];
const matchUid = matchDoc.id;

const user1Doc = await db.collection("users").doc(uid).get();
const user2Doc = await db.collection("users").doc(matchUid).get();

const user1Vibes = user1Doc.exists ? user1Doc.data().vibes ?? [] : [];
const user2Vibes = user2Doc.exists ? user2Doc.data().vibes ?? [] : [];
```

Sıralama sonrası `[0]` en fazla ortak vibeli aday.

**Neden tekrar `users` koleksiyonundan vibe çekiliyor?**
`shakes` dökümanındaki vibeler shake anındaki anlık kopyadır.
`users` koleksiyonundaki vibeler profil güncellemesindeki en güncel halidir.
Match dökümanına en güncel vibeler yazılır, shake'tekiler eşleşme kararı içindir.

---

### 10. Atomik Yazma — Batch Commit

```javascript
const batch = db.batch();

const matchRef = db.collection("matches").doc();   // yeni ID üret
batch.set(matchRef, {
    user1: uid,
    user2: matchUid,
    users: [uid, matchUid],       // arrayContains sorgusu için
    user1Vibes: user1Vibes,
    user2Vibes: user2Vibes,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: "active"
});

batch.delete(db.collection("shakes").doc(uid));
batch.delete(db.collection("shakes").doc(matchUid));

await batch.commit();
```

3 işlem tek seferde yapılır: **match oluştur + iki shake'i sil**.

**Neden batch?**
Batch ya tamamen başarılı olur ya da tamamen başarısız — ikisi arasında bir durum olmaz.
Batch olmadan: match yazılır ama shake silinemezse aynı kişi birden fazla match'e girebilir.

**`FieldValue.serverTimestamp()`**
Sunucunun kendi saatini yazar. Client saati yerine sunucu saati kullanılır çünkü:
- İki kullanıcının cihaz saati farklı olabilir
- Match süresi hesabı (15 sn kabul penceresi) hep aynı kaynaktan yapılır

**`users: [uid, matchUid]`**
Firestore `arrayContains` sorgusu için. Client'ta `where('users', arrayContains: uid)` ile her iki kullanıcı da kendi match'ini tek sorguyla bulabilir.

**`db.collection("matches").doc()`** → ID parametresi verilmediğinde Firestore otomatik benzersiz ID üretir.

---

## Tüm Akış Özeti

```
shakes/A dökümanı oluştu
        ↓
findMatch tetiklendi (A için)
        ↓
Son 5 sn içinde "waiting" shake'leri çek
        ↓
Kendini çıkar → Konumu olmayanları çıkar
→ ±5 sn dışındakileri çıkar → 150m dışındakileri çıkar
        ↓
Kalan adayları ortak vibe sayısına göre sırala
        ↓
Aday yok → return null (shake Firestore'da kalır, client 15 sn bekler)
        ↓
En uyumlu aday seçildi (validCandidates[0])
        ↓
users/A ve users/B'den güncel vibeleri çek
        ↓
Batch: matches/{newId} yaz + shakes/A sil + shakes/B sil
        ↓
İki client'ta watchMatch stream tetiklenir → UI güncellenir
```

---

## Önemli Kısıtlar

- **Tek eşleşme**: İlk (en uyumlu) adayla eşleşir, kalanlar beklemede kalır
- **Race condition**: A ve B için fonksiyon eş zamanlı tetiklenirse, her ikisi de `shakes/B`'yi silmeye çalışır — Firestore bu durumu graceful handle eder, ikinci silme işlemi sessizce başarılı sayılır
- **Vibe yoksa**: `?? []` ile boş dizi döner, ortak vibe 0 olur — mesafe/zaman kriterini geçen ilk kişiyle eşleşir (eski davranış korunur)
- **150m sabit**: Şu an hardcoded. Dinamik yapmak için Firestore config veya Remote Config kullanılabilir
