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
          decoration: InputDecoration(
            labelText: AppStrings.nameLabel,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => context.read<ProfileCubit>().updateName(value),
        ),
        const SizedBox(height: AppSpacing.l),

        // Yaş (Doğum Yılı) Düzenleme
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final currentYear = now.year;
            final initialYear = currentYear - state.editAge;
            final selectedDate = await showDialog<DateTime>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(AppStrings.selectBirthYear),
                content: SizedBox(
                  width: 300,
                  height: 300,
                  child: YearPicker(
                    firstDate: DateTime(1940),
                    lastDate: DateTime(currentYear - 18),
                    selectedDate: DateTime(initialYear),
                    onChanged: (date) => Navigator.pop(context, date),
                  ),
                ),
              ),
            );
            if (selectedDate != null) {
              context.read<ProfileCubit>().updateAge(
                currentYear - selectedDate.year,
              );
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: AppStrings.birthYearLabel,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '${DateTime.now().year - state.editAge} (${state.editAge} ${AppStrings.yearsOld})',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Cinsiyet Düzenleme
        DropdownButtonFormField<String>(
          value: state.editGender,
          decoration: InputDecoration(
            labelText: AppStrings.gender,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Erkek')),
            DropdownMenuItem(value: 'female', child: Text('Kadın')),
          ],
          onChanged: (value) {
            if (value != null) context.read<ProfileCubit>().updateGender(value);
          },
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
