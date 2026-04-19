import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

enum ProfileStatus { initial, loading, loaded, error, photoUploadError, updatedSuccess }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final String editName;
  final int editAge;
  final String editGender;
  final List<String> editVibes;
  final bool isEditing;
  final bool isUploadingPhoto;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.editName = '',
    this.editAge = 0,
    this.editGender = '',
    this.editVibes = const [],
    this.isEditing = false,
    this.isUploadingPhoto = false,
    this.errorMessage,
  });

  bool get hasChanges =>
      user != null &&
      (editName.trim() != user!.name ||
          editAge != user!.age ||
          editGender != user!.gender ||
          !listEquals(
            List<String>.from(editVibes)..sort(),
            List<String>.from(user!.vibes)..sort(),
          ));

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? editName,
    int? editAge,
    String? editGender,
    List<String>? editVibes,
    bool? isEditing,
    bool? isUploadingPhoto,
    String? errorMessage,
  }) => ProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    editName: editName ?? this.editName,
    editAge: editAge ?? this.editAge,
    editGender: editGender ?? this.editGender,
    editVibes: editVibes ?? this.editVibes,
    isEditing: isEditing ?? this.isEditing,
    isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    user,
    editName,
    editAge,
    editGender,
    editVibes,
    isEditing,
    isUploadingPhoto,
    errorMessage,
  ];
}
