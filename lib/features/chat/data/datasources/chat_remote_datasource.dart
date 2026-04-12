import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/chat/data/models/message_model.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

class ChatRemoteDatasource {
  final FirebaseFirestore db;

  ChatRemoteDatasource({required this.db});

  Stream<List<MessageModel>> watchMessage(String matchId) {
    return db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(String matchId, MessageEntity message) async {
    final messageModel = MessageModel(
      id: message.id,
      senderId: message.senderId,
      text: message.text,
      createdAt: message.createdAt,
    );
    await db
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .add(messageModel.toMap());
  }
}
