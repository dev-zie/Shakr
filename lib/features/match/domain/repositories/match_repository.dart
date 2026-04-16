import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

abstract class MatchRepository {
  Stream<MatchEntity?> watchMatch(String uid);
  Future<Either<Failure, MatchEntity?>> getMatch(String matchId);
  Future<Either<Failure, void>> acceptMatch(String matchId, String uid);
  Future<Either<Failure, void>> keepConnection(String matchId, String uid);
  Future<Either<Failure, void>> expireMatch(String matchId);
  Future<Either<Failure, void>> deleteMatch(String matchId);
  Future<Either<Failure, void>> moveToPermanentChat(String matchId);
}
