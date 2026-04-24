import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/save_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/delete_account_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final SaveProfileUsecase saveProfileUsecase;
  final UploadPhotoUsecase uploadPhotoUsecase;
  final DeleteAccountUsecase deleteAccountUsecase;
  final LocalStorageService lsc;

  String? _uid;
  FixedExtentScrollController? ageScrollController;

  ProfileCubit({
    required this.getProfileUsecase,
    required this.saveProfileUsecase,
    required this.uploadPhotoUsecase,
    required this.deleteAccountUsecase,
    required this.lsc,
  }) : super(const ProfileState());

  Future<void> loadProfile(String uid) async {
    _uid = uid;
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await getProfileUsecase.call(uid);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        ProfileState(
          status: ProfileStatus.loaded,
          user: user,
          editName: user.name,
          editAge: user.age,
          editGender: user.gender,
          editVibes: List<String>.from(user.vibes),
        ),
      ),
    );
  }

  void updateName(String name) {
    emit(state.copyWith(editName: name));
  }

  void openAgePicker() {
    final initial = (state.editAge - AppConstants.minUserAge)
        .clamp(0, AppConstants.maxUserAge - AppConstants.minUserAge);
    ageScrollController?.dispose();
    ageScrollController = FixedExtentScrollController(initialItem: initial);
    emit(state.copyWith(pickerAge: state.editAge));
  }

  void updatePickerAge(int age) => emit(state.copyWith(pickerAge: age));

  void updateAge(int age) {
    emit(state.copyWith(editAge: age));
  }

  void updateGender(String gender) {
    emit(state.copyWith(editGender: gender));
  }

  void toggleVibe(String vibe) {
    if (state.status != ProfileStatus.loaded) return;
    final currentVibes = List<String>.from(state.editVibes);
    if (currentVibes.contains(vibe)) {
      currentVibes.remove(vibe);
    } else {
      if (currentVibes.length < 3) {
        currentVibes.add(vibe);
      } else {
        return;
      }
    }
    emit(state.copyWith(editVibes: currentVibes));
  }

  Future<void> uploadPhoto(String path) async {
    if (state.status != ProfileStatus.loaded) return;
    emit(state.copyWith(isUploadingPhoto: true));

    final result = await uploadPhotoUsecase.call(_uid ?? '', path);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProfileStatus.photoUploadError,
            errorMessage: failure.message,
            isUploadingPhoto: false,
          ),
        );
        emit(state.copyWith(status: ProfileStatus.loaded));
      },
      (url) => emit(
        state.copyWith(
          user: state.user!.copyWith(photoUrl: url),
          isUploadingPhoto: false,
        ),
      ),
    );
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future<void> saveProfile() async {
    if (state.status != ProfileStatus.loaded) return;
    emit(state.copyWith(status: ProfileStatus.loading));

    final updatedUser = UserEntity(
      uid: state.user!.uid,
      name: state.editName.trim(),
      age: state.editAge,
      gender: state.editGender,
      photoUrl: state.user!.photoUrl,
      vibes: state.editVibes,
    );

    final result = await saveProfileUsecase.call(updatedUser);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            status: ProfileStatus.updatedSuccess,
            user: updatedUser,
          ),
        );
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            user: updatedUser,
            editName: updatedUser.name,
            editAge: updatedUser.age,
            editGender: updatedUser.gender,
            editVibes: List<String>.from(updatedUser.vibes),
            isEditing: false,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    ageScrollController?.dispose();
    return super.close();
  }

  Future<void> deleteAccount() async {
    if (state.status != ProfileStatus.loaded) return;
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await deleteAccountUsecase.call();
    lsc.resetOnboarding();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(const ProfileState()),
    );
  }
}
