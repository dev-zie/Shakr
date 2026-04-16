import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class AcceptMatchUsecase {
  final MatchRepository repository;
  AcceptMatchUsecase({required this.repository});

  Future<Either<Failure, void>> call(String matchId, String uid) {
    return repository.acceptMatch(matchId, uid);
  }
}
