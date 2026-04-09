import 'package:shakr/features/match/domain/entities/match_entity.dart';

abstract class MatchRepository {
  Stream<MatchEntity?> watchMatch(String uid);
}
