import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/usecases/delete_shake_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/record_shake_usecase.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/common/getit/injection.dart';

class ShakeCubit extends Cubit<ShakeState> {
  final DeleteShakeUsecase deleteShakeUsecase;
  final RecordShakeUsecase recordShakeUsecase;
  Timer? _matchTimer;

  /// Radar animasyonu için (ShakeBody StatelessWidget — vsync yerine ValueNotifier kullanır)
  final ValueNotifier<double> radarProgress = ValueNotifier(0.0);
  Timer? _radarTimer;

  ShakeCubit({
    required this.deleteShakeUsecase,
    required this.recordShakeUsecase,
  }) : super(ShakeInitial());

  void init() {
    reset();
    sl<MatchCubit>().reset();
    _startRadar();
    final uid = sl<AuthCubit>().currentUid;
    sl<ShakeService>().startListening(() async {
      if (uid == null) return;
      final location = await sl<LocationService>().getCurrentLocation();
      recordShake(
        ShakeEntity(
          uid: uid,
          location: location,
          status: ShakeStatus.waiting,
          timestamp: DateTime.now(),
        ),
      );
    });
    if (uid != null) {
      sl<MatchCubit>().watchMatch(uid);
    }
  }

  void disposeScreen() {
    _stopRadar();
    sl<ShakeService>().stopListening();
    _matchTimer?.cancel();
    final uid = sl<AuthCubit>().currentUid;
    if (uid != null) deleteShake(uid);
  }

  void _startRadar() {
    _radarTimer?.cancel();
    _radarTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      radarProgress.value = (radarProgress.value + 16 / 3000) % 1.0;
    });
  }

  void _stopRadar() {
    _radarTimer?.cancel();
    _radarTimer = null;
    radarProgress.value = 0.0;
  }

  Future<void> recordShake(ShakeEntity shake) async {
    emit(ShakeDetected());
    final result = await recordShakeUsecase.call(shake);
    result.fold(
      (l) => emit(ShakeError(l.message)),
      (r) {
        emit(ShakeRecorded());
        startMatchTimer();
      },
    );
  }

  Future<void> deleteShake(String uid) async {
    final result = await deleteShakeUsecase.call(uid);
    result.fold(
      (l) => emit(ShakeError(l.message)),
      (r) => emit(ShakeInitial()),
    );
  }

  void reset() => emit(ShakeInitial());

  void startMatchTimer() {
    _matchTimer?.cancel();
    _matchTimer = Timer(const Duration(seconds: 15), () {
      emit(ShakeNoMatch());
    });
  }

  void cancelMatchTimer() => _matchTimer?.cancel();

  @override
  Future<void> close() {
    _matchTimer?.cancel();
    _radarTimer?.cancel();
    radarProgress.dispose();
    return super.close();
  }
}
