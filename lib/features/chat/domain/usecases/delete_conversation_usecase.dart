import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class DeleteConversationUsecase {
  final ChatRepository repo;

  DeleteConversationUsecase({required this.repo});

  Future<Either<Failure, void>> call(String conversationId) =>
      repo.deleteConversation(conversationId);
}
