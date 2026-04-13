import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class CheckConnectionUsecase {
  final MatchRepository repo;
  CheckConnectionUsecase({required this.repo});

  Future<Either<Failure, bool>> call(String matchId) async {
    return await repo.checkBothKeptConnection(matchId);
  }
}
