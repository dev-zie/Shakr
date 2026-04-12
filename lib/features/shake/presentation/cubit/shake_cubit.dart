import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/domain/usecases/delete_shake_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/record_shake_usecase.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';

class ShakeCubit extends Cubit<ShakeState> {
  final DeleteShakeUsecase deleteShakeUsecase;
  final RecordShakeUsecase recordShakeUsecase;
  ShakeCubit({
    required this.deleteShakeUsecase,
    required this.recordShakeUsecase,
  }) : super(ShakeInitial());

  Future<void> recordShake(ShakeEntity shake) async {
    final result = await recordShakeUsecase.call(shake);

    result.fold(
      (l) => emit(ShakeError(l.message)),
      (r) => emit(ShakeRecorded()),
    );
  }

  Future<void> deleteShake(String uid) async {
    emit(ShakeNoMatch());
    final result = await deleteShakeUsecase.call(uid);

    result.fold(
      (l) => emit(ShakeError(l.message)),
      (r) => emit(ShakeInitial()),
    );
  }

  void reset() {
  emit(ShakeInitial());
}
}
