import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/match/domain/usecases/get_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/keep_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';

class MatchCubit extends Cubit<MatchState> {
  final WatchMatchUsecase watchMatchUsecase;
  final GetMatchUsecase getMatchUsecase;
  final KeepConnectionUsecase keepConnectionUsecase;

  StreamSubscription? _subscription;

  MatchCubit({
    required this.watchMatchUsecase,
    required this.getMatchUsecase,
    required this.keepConnectionUsecase,
  }) : super(MatchInitial());

  void watchMatch(String uid) {
    emit(MatchLoading());
    _subscription = watchMatchUsecase
        .call(uid)
        .listen(
          (match) {
            if (match == null) {
              emit(MatchNotFound());
            } else {
              emit(MatchFound(match));
            }
          },
          onError: (error) {
            emit(MatchError(error.toString()));
          },
        );
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
