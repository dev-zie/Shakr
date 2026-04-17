import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final DeleteAccountUsecase deleteAccountUsecase;
  final LocalStorageService localStorageService;

  SettingsCubit({
    required this.deleteAccountUsecase,
    required this.localStorageService,
  }) : super(SettingsLoaded(selectedVibes: [], notificationsEnabled: true));

  void toggleNotifications(bool value) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(notificationsEnabled: value));
    }
  }

  void selectVibe(String vibe) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      if (currentState.selectedVibes.length >= 3) return;
      emit(
        currentState.copyWith(
          selectedVibes: [...currentState.selectedVibes, vibe],
        ),
      );
    }
  }

  void deselectVibe(String vibe) {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(
        currentState.copyWith(
          selectedVibes: currentState.selectedVibes
              .where((v) => v != vibe)
              .toList(),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    final result = await deleteAccountUsecase.call();
    localStorageService.resetOnboarding();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => emit(SettingsAccountDeleted()),
    );
  }
}
