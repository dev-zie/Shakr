import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/onboarding/presentation/widgets/gender_button.dart';

class AgeGenderStep extends StatelessWidget {
  const AgeGenderStep({super.key});

  Future<void> _pickBirthYear(BuildContext context, int currentAge) async {
    final currentYear = DateTime.now().year;
    final initialYear = currentYear - currentAge;

    final int? selectedYear = await showDialog<int>(
      context: context,
      builder: (_) => _BirthYearPickerDialog(
        initialYear: initialYear,
        minYear: 1940,
        maxYear: currentYear - 18,
      ),
    );

    if (selectedYear != null && context.mounted) {
      context.read<OnboardingCubit>().updateAge(currentYear - selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final step = state is OnboardingStepChanged ? state : null;
        final age = step?.age ?? 20;
        final gender = step?.gender;
        final currentYear = DateTime.now().year;
        final birthYear = currentYear - age;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.howOldAreYou,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Doğum yılı seçici kart
              GestureDetector(
                onTap: () => _pickBirthYear(context, age),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.l,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$birthYear',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            AppStrings.birthYearLabel,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Icon(
                        Icons.edit_calendar_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '$age ${AppStrings.yearsOld}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text(
                AppStrings.gender,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: GenderButton(
                      label: AppStrings.male,
                      isSelected: gender == Gender.male.name,
                      onTap: () => context.read<OnboardingCubit>().updateGender(
                        Gender.male,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: GenderButton(
                      label: AppStrings.female,
                      isSelected: gender == Gender.female.name,
                      onTap: () => context.read<OnboardingCubit>().updateGender(
                        Gender.female,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: gender == null
                    ? null
                    : () => context.read<OnboardingCubit>().setAgeAndGender(
                        age,
                        gender,
                      ),
                child: const Text(AppStrings.continueButton),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BirthYearPickerDialog extends StatelessWidget {
  const _BirthYearPickerDialog({
    required this.initialYear,
    required this.minYear,
    required this.maxYear,
  });

  final int initialYear;
  final int minYear;
  final int maxYear;

  @override
  Widget build(BuildContext context) {
    final clampedYear = initialYear.clamp(minYear, maxYear);

    return AlertDialog(
      title: const Text(AppStrings.selectBirthYear),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: 280,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(minYear),
          lastDate: DateTime(maxYear),
          selectedDate: DateTime(clampedYear),
          onChanged: (date) => Navigator.pop(context, date.year),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}
