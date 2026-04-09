const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.findMatch = onDocumentCreated("shakes/{uid}", async (event) => {
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

  const matchRef = db.collection("matches").doc();
  const matchId = matchRef.id;

  await matchRef.set({
    user1: uid,
    user2: matchUid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: "active",
  });

  await db.collection("shakes").doc(uid).delete();
  await db.collection("shakes").doc(matchUid).delete();

  console.log(`Esleme bulundu: ${uid} - ${matchUid}`);
  return null;
});