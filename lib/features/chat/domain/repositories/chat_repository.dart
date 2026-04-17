import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage(
    String id,
    MessageEntity message, {
    bool isPermanent = false,
  });

  Stream<List<MessageEntity>> watchMessage(
    String id, {
    bool isPermanent = false,
  });

  Stream<Either<Failure, List<ConversationEntity>>> watchConversations(
    String uid,
  );

  Future<Either<Failure, void>> markConversationRead(String id, String uid);

  Future<Either<Failure, void>> deleteConversation(String conversationId);
}
