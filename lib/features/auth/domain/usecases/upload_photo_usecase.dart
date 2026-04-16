import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class UploadPhotoUsecase {
  final AuthRepository repo;
  UploadPhotoUsecase({required this.repo});

  Future<Either<Failure, String>> call(String uid, String filePath) async {
    return await repo.uploadPhoto(uid, filePath);
  }
}
