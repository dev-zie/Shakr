const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.findMatch = onDocumentCreated({
    document: "shakes/{uid}",
    region: "europe-west3",
}, async (event) => {
    const snap = event.data;
    const newShake = snap.data();
    const uid = event.params.uid;

    const tenSecondsAgo = new Date(Date.now() - 10000);

    const candidates = await db
        .collection("shakes")
        .where("status", "==", "waiting")
        .where("timestamp", ">=", tenSecondsAgo)
        .get();

    const others = candidates.docs.filter((doc) => doc.id !== uid);

    if (others.length === 0) {
        console.log("Kimse bulunamadi");
        return null;
    }

    const matchDoc = others[0];
    const matchUid = matchDoc.id;

    // Her iki kullanicinin vibe'larini al
    const user1Doc = await db.collection("users").doc(uid).get();
    const user2Doc = await db.collection("users").doc(matchUid).get();

    const user1Vibes = user1Doc.exists ? user1Doc.data().vibes ?? [] : [];
    const user2Vibes = user2Doc.exists ? user2Doc.data().vibes ?? [] : [];

    const matchRef = db.collection("matches").doc();

    await matchRef.set({
        user1: uid,
        user2: matchUid,
        users: [uid, matchUid],
        user1Vibes: user1Vibes,
        user2Vibes: user2Vibes,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "active",
    });

    await db.collection("shakes").doc(uid).delete();
    await db.collection("shakes").doc(matchUid).delete();

    console.log(`Esleme bulundu: ${uid} - ${matchUid}`);
    return null;
});