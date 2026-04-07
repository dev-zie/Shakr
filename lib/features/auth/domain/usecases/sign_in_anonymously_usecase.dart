import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class SignInAnonymouslyUsecase {
  final AuthRepository repo;

  SignInAnonymouslyUsecase({required this.repo});

  Future<Either<Failure, UserEntity>> call() async {
    return await repo.signInAnonymously();
  }
}
