import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class GetMatchUsecase {
  final MatchRepository repo;

  GetMatchUsecase({required this.repo});

  Future<Either<Failure, MatchEntity?>> call(String matchId) async {
    return await repo.getMatch(matchId);
  }
}
