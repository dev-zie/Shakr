import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/match/domain/usecases/check_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/delete_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/expire_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/get_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/keep_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/injection.dart';

class MatchCubit extends Cubit<MatchState> {
  final WatchMatchUsecase watchMatchUsecase;
  final GetMatchUsecase getMatchUsecase;
  final KeepConnectionUsecase keepConnectionUsecase;
  final ExpireMatchUsecase expireMatchUsecase;
  final DeleteMatchUsecase deleteMatchUsecase;
  final CheckConnectionUsecase checkConnectionUsecase;

  StreamSubscription? _subscription;

  MatchCubit({
    required this.watchMatchUsecase,
    required this.getMatchUsecase,
    required this.keepConnectionUsecase,
    required this.expireMatchUsecase,
    required this.deleteMatchUsecase,
    required this.checkConnectionUsecase,
  }) : super(MatchInitial());

  void init(String matchId) {
    sl<MatchCubit>().getMatch(matchId);
  }

  void watchMatch(String uid) {
    _subscription = watchMatchUsecase.call(uid).listen((match) {
      if (match == null) {
        emit(MatchDeleted());
      } else if (match.status == 'expired') {
        emit(MatchExpired(match));
      } else {
        emit(MatchFound(match));
      }
    });
  }

  Future<void> getMatch(String matchId) async {
    emit(MatchLoading());
    final result = await getMatchUsecase.call(matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (match) =>
          match != null ? emit(MatchFound(match)) : emit(MatchNotFound()),
    );
  }

  Future<void> keepConnection(String matchId, String uid) async {
    final result = await keepConnectionUsecase.call(matchId, uid);
    result.fold((failure) => emit(MatchError(failure.message)), (r) => null);
  }

  Future<void> expireMatch(String matchId) async {
    final result = await expireMatchUsecase.call(matchId);
    result.fold((l) => emit(MatchError(l.message)), (r) => null);
  }

  Future<void> deleteMatch(String matchId) async {
    final result = await deleteMatchUsecase.call(matchId);
    result.fold((l) => emit(MatchError(l.message)), (r) => null);
    emit(MatchInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(MatchInitial());
  }

  Future<bool> checkBothKeptConnection(String matchId) async {
    final result = await checkConnectionUsecase.call(matchId);
    return result.fold((l) => false, (r) => r);
  }
}
