import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/chat/data/models/message_model.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore db;

  ChatRemoteDatasource({required this.db});

  Stream<List<MessageModel>> watchMessage(String id, {bool isPermanent = false}) {
    final collection = isPermanent ? 'conversations' : 'chats';
    return db
        .collection(collection)
        .doc(id)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(String id, MessageEntity message, {bool isPermanent = false}) async {
    final collection = isPermanent ? 'conversations' : 'chats';
    final messageModel = MessageModel(
      id: message.id,
      senderId: message.senderId,
      text: message.text,
      createdAt: message.createdAt,
    );
    await db
        .collection(collection)
        .doc(id)
        .collection('messages')
        .add(messageModel.toMap());

    if (isPermanent) {
      await db.collection('conversations').doc(id).update({
        'lastMessage': message.text,
        'lastMessageAt': Timestamp.fromDate(message.createdAt),
        'readBy': [message.senderId],
      });
    }
  }

  Future<void> markConversationRead(String id, String uid) async {
    await db.collection('conversations').doc(id).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  Stream<List<Map<String, dynamic>>> watchConversations(String uid) {
    return db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> deleteConversation(String conversationId) async {
    // Cooldown'ı kaldır — sohbet silindikten sonra tekrar eşleşebilirler.
    final convDoc = await db.collection('conversations').doc(conversationId).get();
    if (convDoc.exists) {
      final data = convDoc.data()!;
      final u1 = data['user1'] as String?;
      final u2 = data['user2'] as String?;
      if (u1 != null && u2 != null) {
        final sorted = [u1, u2]..sort();
        final cooldownKey = '${sorted[0]}_${sorted[1]}';
        // Sohbet silinince 24 saat cooldown — hemen eşleşemesinler.
        await db.collection('matchCooldowns').doc(cooldownKey).set({
          'user1': u1,
          'user2': u2,
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 24)),
          ),
        });
      }
    }

    final messagesRef = db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    QuerySnapshot snapshot;
    do {
      snapshot = await messagesRef.limit(500).get();
      if (snapshot.docs.isEmpty) break;
      final batch = db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == 500);

    await db.collection('conversations').doc(conversationId).delete();
  }
}
