import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class DeleteMatchUsecase {
  final MatchRepository repo;
  DeleteMatchUsecase({required this.repo});

  Future<Either<Failure, void>> call(String matchId) async {
    return await repo.deleteMatch(matchId);
  }
}
