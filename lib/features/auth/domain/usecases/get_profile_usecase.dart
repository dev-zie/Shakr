import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class GetProfileUsecase {
  final AuthRepository repo;

  GetProfileUsecase({required this.repo});

  Future<Either<Failure, UserEntity>> call(String uid) async {
    return await repo.getProfile(uid);
  }
}
