import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class MoveToPermanentChatUsecase {
  final MatchRepository repository;
  MoveToPermanentChatUsecase({required this.repository});

  Future<Either<Failure, void>> call(String matchId) {
    return repository.moveToPermanentChat(matchId);
  }
}
