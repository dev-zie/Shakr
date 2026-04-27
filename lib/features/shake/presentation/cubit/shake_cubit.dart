import 'dart:async';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/core/services/vibration_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
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

  ShakeCubit({
    required this.deleteShakeUsecase,
    required this.recordShakeUsecase,
    required this.hasActiveMatchUsecase,
  }) : super(const ShakeState());

  void init() {
    reset();
    sl<MatchCubit>().reset();
    final uid = sl<AuthCubit>().currentUid;
    final threshold = sl<SettingsCubit>().state.shakeSensitivity.threshold;
    sl<ShakeService>().startListening(threshold: threshold, () async {
      if (uid == null) return;

      if (state.status != ShakeCubitStatus.initial) return;

      final hasMatch = await hasActiveMatchUsecase.call(uid);
      if (hasMatch) return;

      final locationResult = await sl<LocationService>().getCurrentLocation();

      final vibes = sl<ProfileCubit>().state.user?.vibes ?? [];
      recordShake(
        ShakeEntity(
          uid: uid,
          location: locationResult.location,
          status: ShakeStatus.waiting,
          timestamp: DateTime.now(),
          vibes: vibes,
        ),
      );
    });
    if (uid != null) {
      sl<MatchCubit>().watchMatch(uid);
    }
  }

  void disposeScreen() {
    sl<ShakeService>().stopListening();
    _matchTimer?.cancel();
    final uid = sl<AuthCubit>().currentUid;
    if (uid != null) deleteShake(uid);
  }

  Future<void> recordShake(ShakeEntity shake) async {
    if (state.status != ShakeCubitStatus.initial) return;
    sl<ShakeService>().stopListening();
    emit(state.copyWith(status: ShakeCubitStatus.detected));

    final result = await recordShakeUsecase.call(shake);

    result.fold(
      (l) => emit(
        state.copyWith(status: ShakeCubitStatus.error, errorMessage: l.message),
      ),
      (r) {
        emit(state.copyWith(status: ShakeCubitStatus.recorded));
        startMatchTimer();
        sl<VibrationService>().shakeRecordedFeedback();
      },
    );
  }

  Future<void> deleteShake(String uid) async {
    final result = await deleteShakeUsecase.call(uid);
    result.fold(
      (l) => emit(
        state.copyWith(status: ShakeCubitStatus.error, errorMessage: l.message),
      ),
      (r) => emit(const ShakeState()),
    );
  }

  void reset() => emit(const ShakeState());

  void startMatchTimer() {
    _matchTimer?.cancel();
    _matchTimer = Timer(
      const Duration(seconds: AppConstants.matchAcceptanceWindowSeconds),
      () {
        if (!isClosed) emit(state.copyWith(status: ShakeCubitStatus.noMatch));
      },
    );
  }

  void cancelMatchTimer() => _matchTimer?.cancel();

  Future<void> cancelSearch() async {
    _matchTimer?.cancel();
    final uid = sl<AuthCubit>().currentUid;
    if (uid != null) await deleteShakeUsecase.call(uid);
    init();
  }

  @override
  Future<void> close() {
    _matchTimer?.cancel();
    return super.close();
  }
}
