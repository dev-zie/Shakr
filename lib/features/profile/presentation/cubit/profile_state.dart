import 'package:equatable/equatable.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ProfileError extends ProfileState with EquatableMixin {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState with EquatableMixin {
  final UserEntity user;
  final String editName;
  final int editAge;
  final String editGender;
  final List<String> editVibes;
  final bool isEditing;
  final bool isUploadingPhoto;

  ProfileLoaded({
    required this.user,
    required this.editName,
    required this.editAge,
    required this.editGender,
    required this.editVibes,
    this.isEditing = false,
    this.isUploadingPhoto = false,
  });

  ProfileLoaded copyWith({
    UserEntity? user,
    String? editName,
    int? editAge,
    String? editGender,
    List<String>? editVibes,
    bool? isEditing,
    bool? isUploadingPhoto,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      editName: editName ?? this.editName,
      editAge: editAge ?? this.editAge,
      editGender: editGender ?? this.editGender,
      editVibes: editVibes ?? this.editVibes,
      isEditing: isEditing ?? this.isEditing,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [
    user,
    editName,
    editAge,
    editGender,
    editVibes,
    isEditing,
    isUploadingPhoto,
  ];
}

class ProfilePhotoUploadError extends ProfileState with EquatableMixin {
  final String message;
  ProfilePhotoUploadError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileUpdatedSuccess extends ProfileState with EquatableMixin {
  final UserEntity user;
  ProfileUpdatedSuccess(this.user);
  @override
  List<Object?> get props => [user];
}
