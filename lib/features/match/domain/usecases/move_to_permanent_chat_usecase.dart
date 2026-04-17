import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class MoveToPermanentChatUsecase {
  final MatchRepository repo;
  MoveToPermanentChatUsecase({required this.repo});

  Future<Either<Failure, void>> call(String matchId) {
    return repo.moveToPermanentChat(matchId);
  }
}
