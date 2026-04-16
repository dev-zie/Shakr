import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/media_service.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/usecases/save_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final LocalStorageService lsc;
  final SaveProfileUsecase saveProfileUsecase;
  final UploadPhotoUsecase uploadPhotoUsecase;

  final nameController = TextEditingController();

  /// Yaş adımındaki CupertinoPicker için scroll controller (18 → 99, başlangıç: 20)
  final ageScrollController = FixedExtentScrollController(initialItem: 2);

  OnboardingCubit({
    required this.lsc,
    required this.saveProfileUsecase,
    required this.uploadPhotoUsecase,
  }) : super(OnboardingInitial());

  void updateAge(int age) {
    final current = _currentStep();
    emit(current.copyWith(age: age));
  }

  void updateGender(Gender gender) {
    final current = _currentStep();
    emit(current.copyWith(gender: gender.name));
  }

  void start() {
    emit(OnboardingStepChanged(step: 0));
  }

  void setName(String name) {
    final current = _currentStep();
    emit(current.copyWith(name: name, step: 1));
  }

  Future<void> setPhoto() async {
    final current = _currentStep();
    if (current.photoUrl == null || current.photoUrl!.isEmpty) {
      emit(current.copyWith(step: 2));
      return;
    }

    final uid = sl<AuthCubit>().currentUid ?? '';
    final result = await uploadPhotoUsecase.call(uid, current.photoUrl!);
    result.fold(
      (failure) => emit(OnboardingError(message: failure.message)),
      (url) => emit(current.copyWith(photoUrl: url, step: 2)),
    );
  }

  void setAge(int age) {
    final current = _currentStep();
    emit(current.copyWith(age: age, step: 3));
  }

  void setGender(String gender) {
    final current = _currentStep();
    emit(current.copyWith(gender: gender, step: 4));
  }

  void selectVibe(String vibe) {
    final current = _currentStep();
    if (current.vibes.length >= 3) return;
    emit(current.copyWith(vibes: [...current.vibes, vibe]));
  }

  void deselectVibe(String vibe) {
    final current = _currentStep();
    emit(
      current.copyWith(vibes: current.vibes.where((v) => v != vibe).toList()),
    );
  }

  void goBack() {
    final current = _currentStep();
    if (current.step > 0) {
      emit(current.copyWith(step: current.step - 1));
    }
  }

  Future<void> pickPhoto() async {
    final path = await sl<MediaService>().pickPhoto();
    if (path != null) {
      final current = _currentStep();
      emit(current.copyWith(photoUrl: path));
    }
  }

  Future<void> saveProfile() async {
    final current = _currentStep();

    final hasPermission = await sl<LocationService>().requestPermission();
    if (!hasPermission) {
      emit(OnboardingError(message: 'Konum izni gerekli'));
      return;
    }

    final uid = sl<AuthCubit>().currentUid ?? '';

    final user = UserEntity(
      uid: uid,
      name: current.name,
      age: current.age ?? 0,
      gender: current.gender ?? '',
      photoUrl: current.photoUrl,
      vibes: current.vibes,
    );

    final result = await saveProfileUsecase.call(user);
    result.fold((failure) => emit(OnboardingError(message: failure.message)), (
      r,
    ) async {
      await lsc.setOnboardingCompleted();
      emit(OnboardingCompleted());
    });
  }

  OnboardingStepChanged _currentStep() {
    if (state is OnboardingStepChanged) {
      return state as OnboardingStepChanged;
    }
    return OnboardingStepChanged(step: 0);
  }

  @override
  Future<void> close() {
    nameController.dispose();
    ageScrollController.dispose();
    return super.close();
  }
}
