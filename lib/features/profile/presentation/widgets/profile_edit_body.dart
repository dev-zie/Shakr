import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/widgets/gender_button.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/features/profile/presentation/widgets/age_wheel_picker_dialog.dart';
import 'profile_photo_editor.dart';
import 'profile_vibes_selector.dart';

class ProfileEditBody extends StatelessWidget {
  const ProfileEditBody({super.key, required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              ProfilePhotoEditor(
                photoUrl: state.user?.photoUrl,
                isUploading: state.isUploadingPhoto,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Lütfen isminizi giriniz';
                //   }
                //   return null;
                // },
                initialValue: state.editName,
                decoration: InputDecoration(
                  labelText: AppStrings.nameLabel,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                ),
                onChanged: (value) =>
                    context.read<ProfileCubit>().updateName(value),
              ),
              const SizedBox(height: AppSpacing.l),

              InkWell(
                onTap: () async {
                  final cubit = context.read<ProfileCubit>()..openAgePicker();
                  final selectedAge = await showDialog<int>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const AgeWheelPickerDialog(),
                    ),
                  );
                  if (selectedAge != null && context.mounted) {
                    cubit.updateAge(selectedAge);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: AppStrings.ageLabel,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),
                  child: Text('${state.editAge} ${AppStrings.yearsOld}'),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              Text(
                AppStrings.gender,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: GenderButton(
                      label: AppStrings.male,
                      icon: LucideIcons.mars,
                      isSelected: state.editGender == Gender.male.name,
                      onTap: () => context.read<ProfileCubit>().updateGender(
                        Gender.male.name,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: GenderButton(
                      label: AppStrings.female,
                      icon: LucideIcons.venus,
                      isSelected: state.editGender == Gender.female.name,
                      onTap: () => context.read<ProfileCubit>().updateGender(
                        Gender.female.name,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              ProfileVibesSelector(selectedVibes: state.editVibes),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
        ElevatedButton(
          onPressed:
              state.editVibes.length == 3 &&
                  state.hasChanges &&
                  state.editName.trim().isNotEmpty
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
