import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class SaveVibesUsecase {
  final AuthRepository repo;

  SaveVibesUsecase({required this.repo});
  Future<Either<Failure, void>> call(String uid, List<String> vibes) async {
    return await repo.saveVibes(uid, vibes);
  }
}
