import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;

  AuthRepositoryImpl({required this.authRemoteDatasource});
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await authRemoteDatasource.getCurrentUser();
      if (user == null) return Left(NotFoundFailure());
      return Right(user);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final user = await authRemoteDatasource.signInAnonymously();
      return Right(user);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveVibes(
    String uid,
    List<String> vibes,
  ) async {
    try {
      await authRemoteDatasource.saveVibes(uid, vibes);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserVibes(String uid) async {
    try {
      final vibes = await authRemoteDatasource.getUserVibes(uid);
      return Right(vibes);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
