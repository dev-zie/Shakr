import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUsecase {
  final ChatRepository repo;

  WatchMessagesUsecase({required this.repo});

  Stream<List<MessageEntity>> call(String matchId) {
    return repo.watchMessage(matchId);
  }
}
