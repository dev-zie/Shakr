import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shakr/features/match/data/models/match_model.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

class MatchRemoteDatasource {
  final FirebaseFirestore db;

  MatchRemoteDatasource({required this.db});

  Stream<MatchEntity?> watchMatch(String uid) {
    return db
        .collection('matches')
        .where('users', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final activeDocs = snapshot.docs.where((doc) {
            final status = doc.data()['status'];
            return status == 'active' || status == 'expired';
          }).toList();
          if (activeDocs.isEmpty) return null;
          final doc = activeDocs.first;
          return MatchModel.fromMap(doc.data(), doc.id);
        });
  }

  Future<MatchEntity?> getMatch(String matchId) async {
    final doc = await db.collection('matches').doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> acceptMatch(String matchId, String uid) async {
    final match = await db.collection('matches').doc(matchId).get();
    if (!match.exists) return;
    final data = match.data()!;

    final isUser1 = data['user1'] == uid;
    final field = isUser1 ? 'user1Accepted' : 'user2Accepted';
    final otherAccepted = isUser1
        ? (data['user2Accepted'] ?? false)
        : (data['user1Accepted'] ?? false);

    final updates = <String, dynamic>{field: true};
    if (otherAccepted) {
      updates['chatStartedAt'] = FieldValue.serverTimestamp();
    }

    await db.collection('matches').doc(matchId).update(updates);
  }

  Future<void> keepConnection(String matchId, String uid) async {
    final doc = await db.collection('matches').doc(matchId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final field = data['user1'] == uid ? 'user1KeepConnection' : 'user2KeepConnection';
    await db.collection('matches').doc(matchId).update({field: true});
  }

  Future<void> expireMatch(String matchId) async {
    await db.collection('matches').doc(matchId).update({
      'status': MatchStatus.expired.name,
    });
  }

  Future<void> deleteMatch(String matchId) async {
    final messages = await db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }

    await db.collection('chats').doc(matchId).delete();
    await db.collection('matches').doc(matchId).delete();
  }

  Future<void> moveToPermanentChat(String matchId) async {
    try {
      final matchDoc = await db.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) return;
      final matchData = matchDoc.data()!;

      final messages = await db
          .collection('chats')
          .doc(matchId)
          .collection('messages')
          .orderBy('createdAt')
          .get();

      final convId = matchId;
      
      // Robust ID extraction
      final u1 = matchData['user1'] ?? matchData['user1Id'];
      final u2 = matchData['user2'] ?? matchData['user2Id'];
      
      if (u1 == null || u2 == null) {
        throw Exception('Kullanıcı ID\'leri bulunamadı: u1=$u1, u2=$u2');
      }

      final participants = [u1, u2];

      String lastMsg = 'Sohbet başladı!';
      DateTime lastTime = DateTime.now();

      if (messages.docs.isNotEmpty) {
        final last = messages.docs.last.data();
        lastMsg = last['text'] ?? '';
        lastTime = (last['createdAt'] as Timestamp).toDate();
      }

      final user1Doc = await db.collection('users').doc(u1).get();
      final user2Doc = await db.collection('users').doc(u2).get();

      final user1Name = user1Doc.data()?['name'] ?? 'Kullanıcı';
      final user2Name = user2Doc.data()?['name'] ?? 'Kullanıcı';
      final user1Photo = user1Doc.data()?['photoUrl'];
      final user2Photo = user2Doc.data()?['photoUrl'];

      await db.collection('conversations').doc(convId).set({
        'participants': participants,
        'lastMessage': lastMsg,
        'lastMessageAt': Timestamp.fromDate(lastTime),
        'user1': u1,
        'user2': u2,
        'user1Name': user1Name,
        'user2Name': user2Name,
        'user1Photo': user1Photo,
        'user2Photo': user2Photo,
        'user1Vibes': matchData['user1Vibes'],
        'user2Vibes': matchData['user2Vibes'],
      });

      final batch = db.batch();
      for (final doc in messages.docs) {
        final newMsgRef = db
            .collection('conversations')
            .doc(convId)
            .collection('messages')
            .doc(doc.id);
        batch.set(newMsgRef, doc.data());
      }
      await batch.commit();

      await deleteMatch(matchId);
    } catch (e) {
      debugPrint('Sohbet taşıma hatası: $e');
      rethrow;
    }
  }
}
