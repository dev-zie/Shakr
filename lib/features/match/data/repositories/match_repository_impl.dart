import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/match/data/datasources/match_remote_datasource.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDatasource remoteDatasource;

  MatchRepositoryImpl({required this.remoteDatasource});
  @override
  Stream<MatchEntity?> watchMatch(String uid) {
    return remoteDatasource.watchMatch(uid);
  }

  @override
  Future<Either<Failure, MatchEntity?>> getMatch(String matchId) async {
    try {
      final match = await remoteDatasource.getMatch(matchId);
      return Right(match);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
