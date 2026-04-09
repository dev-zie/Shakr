import 'package:shakr/features/match/data/datasources/match_remote_datasource.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDatasource remoteDatasource;

  MatchRepositoryImpl({required this.remoteDatasource});
  @override
  Stream<MatchEntity?> watchMatch(String uid) {
    return remoteDatasource.watchMatch(uid);
  }
}
