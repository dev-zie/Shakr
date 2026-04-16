
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const geolib = require("geolib");

admin.initializeApp();
const db = admin.firestore();

exports.findMatch = onDocumentCreated({
    document: "shakes/{uid}",
    region: "europe-west3",
}, async (event) => {
    const snap = event.data;
    const newShake = snap.data();
    const uid = event.params.uid;

    if (!newShake || !newShake.location || !newShake.timestamp) {
        console.log("Geçersiz veya eksik shake verisi.");
        return null;
    }

    // 5 Saniye Kuralı (±5 saniye içinde sallayanlar eşleşir)
    // -5 saniye öncesine kadar olanları çekiyoruz
    const fiveSecondsAgo = new Date(Date.now() - 5000);

    const candidatesSnap = await db
        .collection("shakes")
        .where("status", "==", "waiting")
        .where("timestamp", ">=", fiveSecondsAgo)
        .get();

    // Kendimizi listeden çıkarıyoruz ve eşleşme kriterlerine uyanları filtreliyoruz
    const validCandidates = candidatesSnap.docs.filter((doc) => {
        if (doc.id === uid) return false;

        const candidateData = doc.data();
        if (!candidateData.location) return false;

        // Zaman farkı kontrolü (±5 sn)
        const timeDiff = Math.abs(newShake.timestamp.toDate() - candidateData.timestamp.toDate());
        if (timeDiff > 5000) return false;

        // Mesafe hesaplaması (150 metre yarıçap kuralı)
        const distance = geolib.getDistance(
            { latitude: newShake.location.latitude, longitude: newShake.location.longitude },
            { latitude: candidateData.location.latitude, longitude: candidateData.location.longitude }
        );

        return distance <= 150; // Sadece 150m ve altındakiler
    });

    if (validCandidates.length === 0) {
        console.log("Yakınlarda uyumlu shake bulunamadı, bekleniyor...");
        return null;
    }

    // İlk uyumlu adayla eşleş
    const matchDoc = validCandidates[0];
    const matchUid = matchDoc.id;

    const user1Doc = await db.collection("users").doc(uid).get();
    const user2Doc = await db.collection("users").doc(matchUid).get();

    const user1Vibes = user1Doc.exists ? user1Doc.data().vibes ?? [] : [];
    const user2Vibes = user2Doc.exists ? user2Doc.data().vibes ?? [] : [];

    const batch = db.batch();

    const matchRef = db.collection("matches").doc();
    batch.set(matchRef, {
        user1: uid,
        user2: matchUid,
        users: [uid, matchUid],
        user1Vibes: user1Vibes,
        user2Vibes: user2Vibes,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "active"
    });

    batch.delete(db.collection("shakes").doc(uid));
    batch.delete(db.collection("shakes").doc(matchUid));

    await batch.commit();

    console.log(`Başarılı eşleşme: ${uid} ve ${matchUid} (Zaman ve Mesafe Doğrulandı)`);
    return null;
});