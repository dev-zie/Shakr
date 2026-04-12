import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class KeepConnectionUsecase {
  final MatchRepository repo;

  KeepConnectionUsecase({required this.repo});

  Future<Either<Failure, void>> call(String matchId, String uid) async {
    return await repo.keepConnection(matchId, uid);
  }
}
