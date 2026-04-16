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
  final List<String> editVibes;
  final bool isEditing;
  final bool isUploadingPhoto;

  ProfileLoaded({
    required this.user,
    required this.editName,
    required this.editVibes,
    this.isEditing = false,
    this.isUploadingPhoto = false,
  });

  ProfileLoaded copyWith({
    UserEntity? user,
    String? editName,
    List<String>? editVibes,
    bool? isEditing,
    bool? isUploadingPhoto,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      editName: editName ?? this.editName,
      editVibes: editVibes ?? this.editVibes,
      isEditing: isEditing ?? this.isEditing,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [user, editName, editVibes, isEditing, isUploadingPhoto];
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
