import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/core/services/vibration_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/usecases/delete_shake_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/has_active_match_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/record_shake_usecase.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/common/getit/injection.dart';

class ShakeCubit extends Cubit<ShakeState> {
  final DeleteShakeUsecase deleteShakeUsecase;
  final RecordShakeUsecase recordShakeUsecase;
  final HasActiveMatchUsecase hasActiveMatchUsecase;

  Timer? _matchTimer;

  final ValueNotifier<double> radarProgress = ValueNotifier(0.0);
  Timer? _radarTimer;

  ShakeCubit({
    required this.deleteShakeUsecase,
    required this.recordShakeUsecase,
    required this.hasActiveMatchUsecase,
  }) : super(ShakeInitial());

  void init() {
    reset();
    sl<MatchCubit>().reset();
    _startRadar();
    final uid = sl<AuthCubit>().currentUid;
    sl<ShakeService>().startListening(() async {
      if (uid == null) return;

      // Aktif eşleşme varsa yeni shake kaydedilmez — aynı çift tekrar eşleşemez.
      final hasMatch = await hasActiveMatchUsecase.call(uid);
      if (hasMatch) return;

      final locationResult = await sl<LocationService>().getCurrentLocation();

      recordShake(
        ShakeEntity(
          uid: uid,
          location: locationResult.location,
          status: ShakeStatus.waiting,
          timestamp: DateTime.now(),
        ),
        isFallback: locationResult.isFallback,
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

  Future<void> recordShake(ShakeEntity shake, {bool isFallback = false}) async {
    emit(ShakeDetected());

    final result = await recordShakeUsecase.call(shake);

    result.fold((l) => emit(ShakeError(l.message)), (r) {
      emit(ShakeRecorded(isFallbackLocation: isFallback));
      startMatchTimer();
      sl<VibrationService>().shakeRecordedFeedback();
    });
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
      if (!isClosed) emit(ShakeNoMatch());
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
