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

    // Kalıcı sohbet ise lastMessage güncelle
    if (isPermanent) {
      await db.collection('conversations').doc(id).update({
        'lastMessage': message.text,
        'lastMessageAt': Timestamp.fromDate(message.createdAt),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> watchConversations(String uid) {
    return db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}
