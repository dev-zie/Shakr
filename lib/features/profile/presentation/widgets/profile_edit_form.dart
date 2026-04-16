import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_state.dart';
import 'profile_photo_editor.dart';
import 'profile_vibes_selector.dart';

class ProfileEditForm extends StatelessWidget {
  const ProfileEditForm({super.key, required this.state});

  final ProfileLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        ProfilePhotoEditor(
          photoUrl: state.user.photoUrl,
          isUploading: state.isUploadingPhoto,
        ),
        const SizedBox(height: AppSpacing.xl),

        TextFormField(
          initialValue: state.editName,
          decoration: const InputDecoration(labelText: AppStrings.nameLabel),
          onChanged: (value) => context.read<ProfileCubit>().updateName(value),
        ),
        const SizedBox(height: AppSpacing.l),

        ProfileVibesSelector(selectedVibes: state.editVibes),
        const SizedBox(height: AppSpacing.l),

        ElevatedButton(
          onPressed: state.editVibes.length == 3
              ? () => context.read<ProfileCubit>().saveProfile()
              : null,
          child: Text(
            state.editVibes.length == 3
                ? AppStrings.saveChanges
                : '${AppStrings.mustSelectThreeVibes} (${state.editVibes.length}/3)',
          ),
        ),
      ],
    );
  }
}
