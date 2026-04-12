import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class GetUserVibesUsecase {
  final AuthRepository repo;

  GetUserVibesUsecase({required this.repo});

  Future<Either<Failure, List<String>>> call(String uid) async {
    return await repo.getUserVibes(uid);
  }
}