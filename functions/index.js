// const { onDocumentCreated } = require("firebase-functions/v2/firestore");
// const admin = require("firebase-admin");

// admin.initializeApp();

// const db = admin.firestore();

// exports.findMatch = onDocumentCreated({
//     document: "shakes/{uid}",
//     region: "europe-west3",
// }, async (event) => {
//     const snap = event.data;
//     const newShake = snap.data();
//     const uid = event.params.uid;

//     const tenSecondsAgo = new Date(Date.now() - 10000);

//     const candidates = await db
//         .collection("shakes")
//         .where("status", "==", "waiting")
//         .where("timestamp", ">=", tenSecondsAgo)
//         .get();

//     const others = candidates.docs.filter((doc) => doc.id !== uid);

//     if (others.length === 0) {
//         console.log("Kimse bulunamadi");
//         return null;
//     }

//     const matchDoc = others[0];
//     const matchUid = matchDoc.id;

//     // Her iki kullanicinin vibe'larini al
//     const user1Doc = await db.collection("users").doc(uid).get();
//     const user2Doc = await db.collection("users").doc(matchUid).get();

//     const user1Vibes = user1Doc.exists ? user1Doc.data().vibes ?? [] : [];
//     const user2Vibes = user2Doc.exists ? user2Doc.data().vibes ?? [] : [];

//     const matchRef = db.collection("matches").doc();

//     await matchRef.set({
//         user1: uid,
//         user2: matchUid,
//         users: [uid, matchUid],
//         user1Vibes: user1Vibes,
//         user2Vibes: user2Vibes,
//         createdAt: admin.firestore.FieldValue.serverTimestamp(),
//         status: "active",
//     });

//     await db.collection("shakes").doc(uid).delete();
//     await db.collection("shakes").doc(matchUid).delete();

//     console.log(`Esleme bulundu: ${uid} - ${matchUid}`);
//     return null;
// });


const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.findMatch = onDocumentCreated({
    document: "shakes/{uid}",
    region: "europe-west3", // Bölge seçimini Avrupa yapman ping süresi için çok iyi!
}, async (event) => {
    const snap = event.data;
    const newShake = snap.data();
    const uid = event.params.uid;

    const tenSecondsAgo = new Date(Date.now() - 10000);

    // Havuzda bekleyen (waiting) ve son 10 sn içinde sallayanları bul
    const candidates = await db
        .collection("shakes")
        .where("status", "==", "waiting")
        .where("timestamp", ">=", tenSecondsAgo)
        .get();

    // Kendimizi listeden çıkarıyoruz
    const others = candidates.docs.filter((doc) => doc.id !== uid);

    if (others.length === 0) {
        console.log("Kimse bulunamadi, bekleniyor...");
        return null;
    }

    // İlk bulduğumuz kişiyle eşleşiyoruz
    const matchDoc = others[0];
    const matchUid = matchDoc.id;

    // Her iki kullanıcının vibe'larını veritabanından çekiyoruz
    const user1Doc = await db.collection("users").doc(uid).get();
    const user2Doc = await db.collection("users").doc(matchUid).get();

    // Veri yoksa hata vermemesi için boş dizi atıyoruz
    const user1Vibes = user1Doc.exists ? user1Doc.data().vibes ?? [] : [];
    const user2Vibes = user2Doc.exists ? user2Doc.data().vibes ?? [] : [];

    // --- BURADAN İTİBAREN TAMAMLADIK ---

    // Toplu işlem (Batch) başlatıyoruz ki işlemlerden biri patlarsa hepsi geri alınsın
    const batch = db.batch();

    // 1. Yeni eşleşme (match) dokümanını oluştur
    const matchRef = db.collection("matches").doc(); // Rastgele güvenli bir ID üretir
    batch.set(matchRef, {
        user1: uid,
        user2: matchUid,
        users: [uid, matchUid], // Flutter'daki arrayContains sorgun için çok kritik!
        user1Vibes: user1Vibes,
        user2Vibes: user2Vibes,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "active"
    });

    // 2. Eşleşen kullanıcıları 'shakes' (sallayanlar) havuzundan sil
    batch.delete(db.collection("shakes").doc(uid));
    batch.delete(db.collection("shakes").doc(matchUid));

    // İşlemleri tek seferde çalıştır
    await batch.commit();

    console.log(`Başarılı eşleşme: ${uid} ve ${matchUid}`);
    return null;
});