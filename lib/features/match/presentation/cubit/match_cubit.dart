import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/match/domain/usecases/check_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/delete_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/expire_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/get_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/keep_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';

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

  /// Eşleşme verilerini bir kez çeker (stream olmadan).
  Future<void> init(String matchId) => getMatch(matchId);

  /// Maç verisi henüz yüklü değilse çeker; tekrar çağrılması güvenlidir.
  void ensureLoaded(String matchId) {
    if (state is MatchLoading || state is MatchFound || state is MatchExpired) {
      return;
    }
    getMatch(matchId);
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

  Future<void> expireMatch(String matchId) async {
    final result = await expireMatchUsecase.call(matchId);
    result.fold((l) => emit(MatchError(l.message)), (_) => null);
  }

  Future<void> deleteMatch(String matchId) async {
    final result = await deleteMatchUsecase.call(matchId);
    result.fold((l) => emit(MatchError(l.message)), (_) => null);
    emit(MatchInitial());
  }

  /// Bağlantıyı koruma akışı: keepConnection → ikisi de kabul ettiyse MatchBothKept,
  /// aksi hâlde MatchConnectionPending emit eder.
  Future<void> keepConnectionFlow(String matchId, String uid) async {
    final currentState = state;

    await keepConnectionUsecase.call(matchId, uid);

    final checkResult = await checkConnectionUsecase.call(matchId);
    final bothKept = checkResult.fold((_) => false, (r) => r);

    if (bothKept) {
      final match = currentState is MatchExpired
          ? currentState.match
          : currentState is MatchFound
              ? currentState.match
              : null;

      // Stream aboneliğini iptal et — silme işlemi MatchDeleted tetiklemesin
      _subscription?.cancel();
      _subscription = null;

      if (match != null) emit(MatchBothKept(match));

      // Arka planda temizlik
      await deleteMatchUsecase.call(matchId);
    } else {
      emit(MatchConnectionPending());
    }
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(MatchInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
