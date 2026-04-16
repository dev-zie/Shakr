import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repo;

  SendMessageUsecase({required this.repo});

  Future<Either<Failure, void>> call(
    String matchId,
    MessageEntity message, {
    bool isPermanent = false,
  }) async {
    return await repo.sendMessage(matchId, message, isPermanent: isPermanent);
  }
}
