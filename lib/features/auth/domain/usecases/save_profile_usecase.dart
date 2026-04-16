import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class SaveProfileUsecase {
  final AuthRepository repo;

  SaveProfileUsecase({required this.repo});

  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repo.saveProfile(user);
  }
}
