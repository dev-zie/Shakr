import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/domain/usecases/accept_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/check_connection_usecase.dart';
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
  final CheckConnectionUsecase checkConnectionUsecase;
  final AcceptMatchUsecase acceptMatchUsecase;
  final MoveToPermanentChatUsecase moveToPermanentChatUsecase;

  StreamSubscription? _subscription;

  MatchCubit({
    required this.watchMatchUsecase,
    required this.getMatchUsecase,
    required this.keepConnectionUsecase,
    required this.expireMatchUsecase,
    required this.deleteMatchUsecase,
    required this.checkConnectionUsecase,
    required this.acceptMatchUsecase,
    required this.moveToPermanentChatUsecase,
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
      } else if (match.status == MatchStatus.expired) {
        final isUser1 = match.user1Id == uid;
        final myKeep = isUser1
            ? match.user1KeepConnection
            : match.user2KeepConnection;
        final otherKeep = isUser1
            ? match.user2KeepConnection
            : match.user1KeepConnection;

        if (myKeep && otherKeep) {
          emit(MatchBothKept(match));
          moveToPermanentChat(match.matchId);
        } else if (myKeep) {
          emit(MatchConnectionPending(match));
        } else {
          emit(MatchExpired(match));
        }
      } else if (match.status == MatchStatus.active) {
        final isUser1 = match.user1Id == uid;
        final myAccepted = isUser1 ? match.user1Accepted : match.user2Accepted;

        if (match.user1Accepted && match.user2Accepted) {
          emit(MatchAccepted(match));
        } else if (myAccepted) {
          emit(MatchAcceptancePending(match));
        } else {
          emit(MatchFound(match));
        }
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

  Future<void> acceptMatch(String matchId, String uid) async {
    final result = await acceptMatchUsecase.call(matchId, uid);
    result.fold((l) => emit(MatchError(l.message)), (_) => null);
  }

  Future<void> endMatch(String matchId) async {
    final result = await deleteMatchUsecase.call(matchId);
    result.fold(
      (l) => emit(MatchError(l.message)),
      (_) => emit(MatchDeleted()),
    );
  }

  Future<void> moveToPermanentChat(String matchId) async {
    final result = await moveToPermanentChatUsecase.call(matchId);
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
    await keepConnectionUsecase.call(matchId, uid);
    // watchMatch üzerinden otomatik olarak state güncellenecektir.
  }

  Future<void> cancelKeepConnectionFlow(String matchId, String uid) async {
    // Repository'ye cancel metodu eklenmesi gerekecek, şimdilik manuel update gibi düşünelim
    // Ama repo bazlı gitmek daha doğru.
    final result = await deleteMatchUsecase.call(
      matchId,
    ); // Veya özel vazgeç metodu
    result.fold(
      (l) => emit(MatchError(l.message)),
      (_) => emit(MatchInitial()),
    );
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
