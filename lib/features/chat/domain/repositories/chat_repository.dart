import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage(
    String matchId,
    MessageEntity message,
  );

  Stream<List<MessageEntity>> watchMessage(String matchId);
}
