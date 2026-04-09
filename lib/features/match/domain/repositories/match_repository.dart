import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

abstract class MatchRepository {
  Stream<MatchEntity?> watchMatch(String uid);
  Future<Either<Failure, MatchEntity?>> getMatch(String matchId);
}
