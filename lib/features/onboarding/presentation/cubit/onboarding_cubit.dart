import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/domain/usecases/save_vibes_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/injection.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final LocalStorageService lsc;
  final SaveVibesUsecase saveVibesUsecase;

  OnboardingCubit({required this.lsc, required this.saveVibesUsecase})
    : super(OnboardingInitial());

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
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      emit(OnboardingError(message: 'Konum izni gerekli'));
      return;
    }

    final vibes = state is OnboardingVibeSelected
        ? (state as OnboardingVibeSelected).selectedVibes
        : <String>[];

    final uid = sl<AuthCubit>().currentUid;
    if (uid != null) {
      await saveVibesUsecase.call(uid, vibes);
    }

    await lsc.setOnboardingCompleted();
    emit(OnboardingCompleted(selectedVibes: vibes));
  }
}
