import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/repositories/shake_repository.dart';

class RecordShakeUsecase {
  final ShakeRepository repo;

  RecordShakeUsecase({required this.repo});

  Future<Either<Failure, void>> call(ShakeEntity shake) async {
    return await repo.recordShake(shake);
  }
}
