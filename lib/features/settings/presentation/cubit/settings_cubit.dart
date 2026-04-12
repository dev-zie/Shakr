import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/auth/domain/usecases/get_user_vibes_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/save_vibes_usecase.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetUserVibesUsecase getUserVibesUsecase;
  final SaveVibesUsecase saveVibesUsecase;

  SettingsCubit({
    required this.getUserVibesUsecase,
    required this.saveVibesUsecase,
  }) : super(SettingsInitial());

  Future<void> loadVibes() async {
    emit(SettingsLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final result = await getUserVibesUsecase.call(uid);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (vibes) => emit(SettingsLoaded(vibes)),
    );
  }

  void selectVibe(String vibe) {
    final currentVibes = state is SettingsLoaded
        ? (state as SettingsLoaded).selectedVibes
        : <String>[];
    if (currentVibes.length >= 3) return;
    emit(SettingsLoaded([...currentVibes, vibe]));
  }

  void deselectVibe(String vibe) {
    final currentVibes = state is SettingsLoaded
        ? (state as SettingsLoaded).selectedVibes
        : <String>[];
    emit(SettingsLoaded(currentVibes.where((v) => v != vibe).toList()));
  }

  Future<void> saveVibes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final vibes = state is SettingsLoaded
        ? (state as SettingsLoaded).selectedVibes
        : <String>[];
    final result = await saveVibesUsecase.call(uid, vibes);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (r) => emit(SettingsSaved()),
    );
  }
}
