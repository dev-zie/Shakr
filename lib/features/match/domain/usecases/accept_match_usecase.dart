import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class AcceptMatchUsecase {
  final MatchRepository repo;
  AcceptMatchUsecase({required this.repo});

  Future<Either<Failure, void>> call(String matchId, String uid) {
    return repo.acceptMatch(matchId, uid);
  }
}
