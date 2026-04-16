import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class WatchConversationsUsecase {
  final ChatRepository repo;

  WatchConversationsUsecase({required this.repo});

  Stream<Either<Failure, List<ConversationEntity>>> call(String uid) {
    return repo.watchConversations(uid);
  }
}
