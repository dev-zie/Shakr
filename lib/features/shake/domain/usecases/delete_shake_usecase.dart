import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/shake/domain/repositories/shake_repository.dart';

class DeleteShakeUsecase {
  final ShakeRepository repo;

  DeleteShakeUsecase({required this.repo});

  Future<Either<Failure, void>> call(String uid) async {
    return await repo.deleteShake(uid);
  }
}
