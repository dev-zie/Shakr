import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> signInAnonymously();

  Future<Either<Failure, void>> saveProfile(UserEntity user);

  Future<Either<Failure, UserEntity>> getProfile(String uid);

  Future<Either<Failure, String>> uploadPhoto(String uid, String filePath);

}
