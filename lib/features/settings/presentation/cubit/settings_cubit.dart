import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';
import 'package:shakr/common/getit/injection.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  // Future<void> loadVibes() async {
  //   emit(SettingsLoading());

  //   final uid = sl<AuthCubit>().currentUid;
  //   final result = await getUserVibesUsecase.call(uid ?? '');
  //   result.fold(
  //     (failure) => emit(SettingsError(failure.message)),
  //     (vibes) => emit(SettingsLoaded(vibes)),
  //   );
  // }

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

  // Future<void> saveVibes() async {
  //   final uid = sl<AuthCubit>().currentUid;
  //   final vibes = state is SettingsLoaded
  //       ? (state as SettingsLoaded).selectedVibes
  //       : <String>[];
  //   final result = await saveVibesUsecase.call(uid ?? '', vibes);
  //   result.fold(
  //     (failure) => emit(SettingsError(failure.message)),
  //     (r) => emit(SettingsSaved()),
  //   );
  // }
}
