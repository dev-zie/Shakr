import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class WatchMatchUsecase {
  final MatchRepository repo;

  WatchMatchUsecase({required this.repo});

    Stream<MatchEntity?> call(String uid) {
      return repo.watchMatch(uid);
    }
}