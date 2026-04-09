import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final LocalStorageService lsc;

  OnboardingCubit({required this.lsc}) : super(OnboardingInitial());

  void selectVibe(String vibe) {
    final currentVibes = state is OnboardingVibeSelected
        ? (state as OnboardingVibeSelected).selectedVibes
        : <String>[];

    if (currentVibes.length >= 3) return;
    emit(OnboardingVibeSelected(selectedVibes: [...currentVibes, vibe]));
  }

  void deselectVibe(String vibe) {
    final currentVibes = state is OnboardingVibeSelected
        ? (state as OnboardingVibeSelected).selectedVibes
        : <String>[];
    emit(
      OnboardingVibeSelected(
        selectedVibes: currentVibes.where((v) => v != vibe).toList(),
      ),
    );
  }

  Future<void> saveVibes() async {
    await lsc.setOnboardingCompleted();
    emit(
      OnboardingCompleted(
        selectedVibes: state is OnboardingVibeSelected
            ? (state as OnboardingVibeSelected).selectedVibes
            : [],
      ),
    );
  }
}
