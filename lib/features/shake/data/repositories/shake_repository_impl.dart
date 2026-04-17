import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/shake/data/datasources/shake_remote_datasource.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/repositories/shake_repository.dart';

class ShakeRepositoryImpl implements ShakeRepository {
  final ShakeRemoteDatasource remoteDatasource;

  ShakeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, void>> recordShake(ShakeEntity shake) async {
    try {
      await remoteDatasource.recordShake(shake);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteShake(String uid) async {
    try {
      await remoteDatasource.deleteShake(uid);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<bool> hasActiveMatch(String uid) =>
      remoteDatasource.hasActiveMatch(uid);
}
