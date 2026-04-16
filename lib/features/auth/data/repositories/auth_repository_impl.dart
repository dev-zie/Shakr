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
  Future<Either<Failure, UserEntity>> getProfile(String uid) async {
    try {
      final profile = await authRemoteDatasource.getProfile(uid);
      if (profile == null) return Left(NotFoundFailure());
      return Right(profile);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile(UserEntity user) async {
    try {
      await authRemoteDatasource.saveProfile(user);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(
    String uid,
    String filePath,
  ) async {
    try {
      final url = await authRemoteDatasource.uploadPhoto(uid, filePath);
      return Right(url);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
