import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';

class MatchCubit extends Cubit<MatchState> {
  final WatchMatchUsecase watchMatchUsecase;
  StreamSubscription? _subscription;

  MatchCubit({required this.watchMatchUsecase}) : super(MatchInitial());

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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
