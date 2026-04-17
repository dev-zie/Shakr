import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';

abstract class ShakeRepository {
  Future<Either<Failure, void>> recordShake(ShakeEntity shake);
  Future<Either<Failure, void>> deleteShake(String uid);
  Future<bool> hasActiveMatch(String uid);
}
