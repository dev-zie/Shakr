import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUsecase {
  final AuthRepository repo;

  DeleteAccountUsecase({required this.repo});

  Future<Either<Failure, void>> call() async {
    return await repo.deleteAccount();
  }
}
