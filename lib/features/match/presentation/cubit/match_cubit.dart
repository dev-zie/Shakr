import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/usecases/accept_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/delete_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/expire_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/get_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/keep_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/move_to_permanent_chat_usecase.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';

class MatchCubit extends Cubit<MatchState> {
  final WatchMatchUsecase watchMatchUsecase;
  final GetMatchUsecase getMatchUsecase;
  final KeepConnectionUsecase keepConnectionUsecase;
  final ExpireMatchUsecase expireMatchUsecase;
  final DeleteMatchUsecase deleteMatchUsecase;
  final AcceptMatchUsecase acceptMatchUsecase;
  final MoveToPermanentChatUsecase moveToPermanentChatUsecase;

  StreamSubscription? _subscription;

  /// 15 saniyelik kabul penceresi için zamanlayıcı
  Timer? _acceptTimer;

  MatchCubit({
    required this.watchMatchUsecase,
    required this.getMatchUsecase,
    required this.keepConnectionUsecase,
    required this.expireMatchUsecase,
    required this.deleteMatchUsecase,
    required this.acceptMatchUsecase,
    required this.moveToPermanentChatUsecase,
  }) : super(const MatchState());

  /// Eşleşme verilerini bir kez çeker (stream olmadan).
  Future<void> init(String matchId) => getMatch(matchId);

  /// Maç verisi henüz yüklü değilse çeker; tekrar çağrılması güvenlidir.
  void ensureLoaded(String matchId) {
    const loaded = {
      MatchCubitStatus.loading,
      MatchCubitStatus.found,
      MatchCubitStatus.expired,
      MatchCubitStatus.connectionPending,
      MatchCubitStatus.bothKept,
      MatchCubitStatus.acceptancePending,
      MatchCubitStatus.accepted,
    };
    if (loaded.contains(state.status)) return;
    getMatch(matchId);
  }

  void watchMatch(String uid) {
    _subscription = watchMatchUsecase.call(uid).listen((match) {
      if (match == null) {
        _cancelAcceptTimer();
        emit(state.copyWith(status: MatchCubitStatus.deleted, match: null));
      } else if (match.status == MatchStatus.expired) {
        _cancelAcceptTimer();
        final isUser1 = match.user1Id == uid;
        final myKeep = isUser1 ? match.user1KeepConnection : match.user2KeepConnection;
        final otherKeep = isUser1 ? match.user2KeepConnection : match.user1KeepConnection;

        if (myKeep && otherKeep) {
          emit(state.copyWith(status: MatchCubitStatus.bothKept, match: match));
          moveToPermanentChat(match.matchId);
        } else if (myKeep) {
          emit(state.copyWith(status: MatchCubitStatus.connectionPending, match: match));
        } else {
          emit(state.copyWith(status: MatchCubitStatus.expired, match: match));
        }
      } else if (match.status == MatchStatus.active) {
        final isUser1 = match.user1Id == uid;
        final myAccepted = isUser1 ? match.user1Accepted : match.user2Accepted;

        if (match.user1Accepted && match.user2Accepted) {
          _cancelAcceptTimer();
          emit(state.copyWith(status: MatchCubitStatus.accepted, match: match));
        } else if (myAccepted) {
          emit(state.copyWith(status: MatchCubitStatus.acceptancePending, match: match));
        } else {
          _startAcceptTimer(match.matchId, match.createdAt);
          emit(state.copyWith(status: MatchCubitStatus.found, match: match));
        }
      } else {
        _startAcceptTimer(match.matchId, match.createdAt);
        emit(state.copyWith(status: MatchCubitStatus.found, match: match));
      }
    });
  }

  /// Kabul penceresi için 15 saniyelik tek-atış zamanlayıcı başlatır.
  /// Zaten çalışıyorsa yeniden başlatmaz (idempotent).
  void _startAcceptTimer(String matchId, DateTime createdAt) {
    if (_acceptTimer?.isActive == true) return;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    final remaining = (AppConstants.matchAcceptanceWindowSeconds - elapsed)
        .clamp(0, AppConstants.matchAcceptanceWindowSeconds);
    if (remaining <= 0) {
      deleteMatch(matchId);
      return;
    }
    _acceptTimer = Timer(Duration(seconds: remaining), () {
      deleteMatch(matchId);
    });
  }

  void _cancelAcceptTimer() {
    _acceptTimer?.cancel();
    _acceptTimer = null;
  }

  Future<void> getMatch(String matchId) async {
    emit(state.copyWith(status: MatchCubitStatus.loading));
    final result = await getMatchUsecase.call(matchId);
    result.fold(
      (failure) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: failure.message)),
      (match) => match != null
          ? emit(state.copyWith(status: MatchCubitStatus.found, match: match))
          : emit(state.copyWith(status: MatchCubitStatus.notFound)),
    );
  }

  Future<void> expireMatch(String matchId) async {
    final result = await expireMatchUsecase.call(matchId);
    result.fold(
      (l) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: l.message)),
      (_) => null,
    );
  }

  Future<void> acceptMatch(String matchId, String uid) async {
    final result = await acceptMatchUsecase.call(matchId, uid);
    result.fold(
      (l) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: l.message)),
      (_) => null,
    );
  }

  Future<void> endMatch(String matchId) async {
    final result = await deleteMatchUsecase.call(matchId);
    result.fold(
      (l) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: l.message)),
      (_) => emit(state.copyWith(status: MatchCubitStatus.deleted)),
    );
  }

  Future<void> moveToPermanentChat(String matchId) async {
    final result = await moveToPermanentChatUsecase.call(matchId);
    result.fold(
      (l) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: l.message)),
      (_) => null,
    );
  }

  Future<void> deleteMatch(String matchId) async {
    final result = await deleteMatchUsecase.call(matchId);
    result.fold(
      (l) => emit(state.copyWith(status: MatchCubitStatus.error, errorMessage: l.message)),
      (_) => null,
    );
    emit(const MatchState());
  }

  /// Bağlantıyı koruma akışı: keepConnection kaydeder,
  /// watchMatch stream üzerinden state otomatik güncellenir.
  Future<void> keepConnectionFlow(String matchId, String uid) async {
    await keepConnectionUsecase.call(matchId, uid);
  }

  void reset() {
    _cancelAcceptTimer();
    _subscription?.cancel();
    _subscription = null;
    emit(const MatchState());
  }

  @override
  Future<void> close() {
    _acceptTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
