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
  }) : super(const SettingsState(status: SettingsStatus.loaded));

  void toggleNotifications(bool value) {
    emit(state.copyWith(notificationsEnabled: value));
  }

  void selectVibe(String vibe) {
    if (state.selectedVibes.length >= 3) return;
    emit(state.copyWith(selectedVibes: [...state.selectedVibes, vibe]));
  }

  void deselectVibe(String vibe) {
    emit(
      state.copyWith(
        selectedVibes: state.selectedVibes.where((v) => v != vibe).toList(),
      ),
    );
  }

  Future<void> deleteAccount() async {
    final result = await deleteAccountUsecase.call();
    localStorageService.resetOnboarding();
    result.fold(
      (failure) => emit(state.copyWith(status: SettingsStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: SettingsStatus.accountDeleted)),
    );
  }
}
