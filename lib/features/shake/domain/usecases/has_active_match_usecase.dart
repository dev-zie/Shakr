import 'package:shakr/features/shake/domain/repositories/shake_repository.dart';

class HasActiveMatchUsecase {
  final ShakeRepository repo;

  HasActiveMatchUsecase({required this.repo});

  Future<bool> call(String uid) => repo.hasActiveMatch(uid);
}
