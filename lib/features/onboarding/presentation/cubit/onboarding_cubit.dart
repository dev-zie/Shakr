import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/core/services/location_service.dart';
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
  final pageController = PageController();

  /// Yaş adımındaki CupertinoPicker için scroll controller (18 → 99, başlangıç: 20)
  final ageScrollController = FixedExtentScrollController(initialItem: 2);

  OnboardingCubit({
    required this.lsc,
    required this.saveProfileUsecase,
    required this.uploadPhotoUsecase,
  }) : super(const OnboardingState());

  void updateAge(int age) => emit(state.copyWith(age: age));

  void updateGender(Gender gender) => emit(state.copyWith(gender: gender.name));

  void onIntroPageChanged(int index, int slideCount) {
    emit(state.copyWith(
      introPage: index,
      introLastPageSeen: state.introLastPageSeen || index == slideCount - 1,
    ));
  }

  void start() => emit(state.copyWith(status: OnboardingStatus.stepChanged, step: 0));

  void finishIntro() => emit(state.copyWith(step: 1));

  void setName(String name) => emit(state.copyWith(name: name, step: 2));

  Future<void> setPhoto() async {
    if (state.photoUrl == null || state.photoUrl!.isEmpty) {
      emit(state.copyWith(step: 3));
      return;
    }

    final uid = sl<AuthCubit>().currentUid ?? '';
    final result = await uploadPhotoUsecase.call(uid, state.photoUrl!);
    result.fold(
      (failure) => emit(state.copyWith(status: OnboardingStatus.error, errorMessage: failure.message)),
      (url) => emit(state.copyWith(photoUrl: url, step: 3)),
    );
  }

  void setAge(int age) => emit(state.copyWith(age: age, step: 4));

  void setGender(String gender) => emit(state.copyWith(gender: gender, step: 5));

  void selectVibe(String vibe) {
    if (state.vibes.length >= 3) return;
    emit(state.copyWith(vibes: [...state.vibes, vibe]));
  }

  void deselectVibe(String vibe) {
    emit(state.copyWith(vibes: state.vibes.where((v) => v != vibe).toList()));
  }

  void goBack() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1));
  }

  void setPhotoPath(String path) => emit(state.copyWith(photoUrl: path));

  Future<void> saveProfile() async {
    await sl<LocationService>().requestPermission();

    final uid = sl<AuthCubit>().currentUid ?? '';

    final user = UserEntity(
      uid: uid,
      name: state.name,
      age: state.age ?? 0,
      gender: state.gender ?? '',
      photoUrl: state.photoUrl,
      vibes: state.vibes,
    );

    final result = await saveProfileUsecase.call(user);
    result.fold(
      (failure) => emit(state.copyWith(status: OnboardingStatus.error, errorMessage: failure.message)),
      (r) async {
        await lsc.setOnboardingCompleted();
        emit(state.copyWith(status: OnboardingStatus.completed));
      },
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    pageController.dispose();
    ageScrollController.dispose();
    return super.close();
  }
}
