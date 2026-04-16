import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/widgets/gender_button.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/features/profile/presentation/widgets/age_wheel_picker_dialog.dart';
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
          decoration: InputDecoration(
            labelText: AppStrings.nameLabel,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => context.read<ProfileCubit>().updateName(value),
        ),
        const SizedBox(height: AppSpacing.l),

        // Yaş Düzenleme
        InkWell(
          onTap: () async {
            final selectedAge = await showDialog<int>(
              context: context,
              builder: (context) =>
                  AgeWheelPickerDialog(initialAge: state.editAge),
            );

            if (selectedAge != null) {
              context.read<ProfileCubit>().updateAge(selectedAge);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppStrings.ageLabel,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
            ),
            child: Text('${state.editAge} ${AppStrings.yearsOld}'),
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Cinsiyet Düzenleme
        Text(
          AppStrings.gender,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: GenderButton(
                label: AppStrings.male,
                icon: LucideIcons.mars,
                isSelected: state.editGender == 'male',
                onTap: () => context.read<ProfileCubit>().updateGender('male'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: GenderButton(
                label: AppStrings.female,
                icon: LucideIcons.venus,
                isSelected: state.editGender == 'female',
                onTap: () =>
                    context.read<ProfileCubit>().updateGender('female'),
              ),
            ),
          ],
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
