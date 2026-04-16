import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/media_service.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/save_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final SaveProfileUsecase saveProfileUsecase;
  final UploadPhotoUsecase uploadPhotoUsecase;

  String? _uid;

  ProfileCubit({
    required this.getProfileUsecase,
    required this.saveProfileUsecase,
    required this.uploadPhotoUsecase,
  }) : super(ProfileInitial());

  Future<void> loadProfile(String uid) async {
    _uid = uid;
    emit(ProfileLoading());
    final result = await getProfileUsecase.call(uid);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(
        ProfileLoaded(
          user: user,
          editName: user.name,
          editAge: user.age,
          editGender: user.gender,
          editVibes: List<String>.from(user.vibes),
        ),
      ),
    );
  }

  // --- FORM DÜZENLEME METODLARI ---

  void updateName(String name) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(editName: name));
    }
  }

  void updateAge(int age) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(editAge: age));
    }
  }

  void updateGender(String gender) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(editGender: gender));
    }
  }

  void toggleVibe(String vibe) {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;
    final currentVibes = List<String>.from(currentState.editVibes);

    if (currentVibes.contains(vibe)) {
      currentVibes.remove(vibe);
    } else {
      if (currentVibes.length < 3) {
        currentVibes.add(vibe);
      } else {
        return;
      }
    }
    emit(currentState.copyWith(editVibes: currentVibes));
  }

  Future<void> pickAndUploadPhoto() async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    final path = await sl<MediaService>().pickPhoto();
    if (path == null) return;

    emit(currentState.copyWith(isUploadingPhoto: true));

    final result = await uploadPhotoUsecase.call(_uid ?? '', path);
    result.fold(
      (failure) {
        emit(ProfilePhotoUploadError(failure.message));
        emit(currentState.copyWith(isUploadingPhoto: false));
      },
      (url) => emit(
        currentState.copyWith(
          user: currentState.user.copyWith(photoUrl: url),
          isUploadingPhoto: false,
        ),
      ),
    );
  }

  void toggleEditMode() {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEditing: !currentState.isEditing));
    }
  }

  // --- KAYDETME ---

  Future<void> saveProfile() async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;
    emit(ProfileLoading());

    final updatedUser = UserEntity(
      uid: currentState.user.uid,
      name: currentState.editName.trim(),
      age: currentState.editAge,
      gender: currentState.editGender,
      photoUrl: currentState.user.photoUrl,
      vibes: currentState.editVibes,
    );

    final result = await saveProfileUsecase.call(updatedUser);
    result.fold((failure) => emit(ProfileError(failure.message)), (_) {
      emit(ProfileUpdatedSuccess(updatedUser));
      emit(
        ProfileLoaded(
          user: updatedUser,
          editName: updatedUser.name,
          editAge: updatedUser.age,
          editGender: updatedUser.gender,
          editVibes: List<String>.from(updatedUser.vibes),
          isEditing: false,
        ),
      );
    });
  }
}
