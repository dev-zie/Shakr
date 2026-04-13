import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/usecases/delete_shake_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/record_shake_usecase.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/injection.dart';

class ShakeCubit extends Cubit<ShakeState> {
  final DeleteShakeUsecase deleteShakeUsecase;
  final RecordShakeUsecase recordShakeUsecase;
  Timer? _matchTimer;

  ShakeCubit({
    required this.deleteShakeUsecase,
    required this.recordShakeUsecase,
  }) : super(ShakeInitial());

  void init() {
    reset();
    sl<MatchCubit>().reset();
    final uid = sl<AuthCubit>().currentUid;
    print('ShakeCubit init uid: $uid');
    sl<ShakeService>().startListening(() async {
      final uid = sl<AuthCubit>().currentUid;
      if (uid == null) return;
      final location = await sl<LocationService>().getCurrentLocation();
      recordShake(
        ShakeEntity(
          uid: uid,
          location: location,
          status: 'waiting',
          timestamp: DateTime.now(),
        ),
      );
    });
    if (uid != null) {
      print('watchMatch basliyor');
      sl<MatchCubit>().watchMatch(uid);
    }
  }

  void disposeScreen() {
    sl<ShakeService>().stopListening();
    final uid = sl<AuthCubit>().currentUid;
    if (uid != null) deleteShake(uid);
  }

  Future<void> recordShake(ShakeEntity shake) async {
    emit(ShakeDetected());
    final result = await recordShakeUsecase.call(shake);
    result.fold(
      (l) => emit(ShakeError(l.message)),
      (r) => emit(ShakeRecorded()),
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

  void startMatchTimer(VoidCallback onTimeout) {
    _matchTimer?.cancel();
    _matchTimer = Timer(const Duration(seconds: 15), onTimeout);
  }

  void cancelMatchTimer() => _matchTimer?.cancel();

  @override
  Future<void> close() {
    _matchTimer?.cancel();
    return super.close();
  }
}
