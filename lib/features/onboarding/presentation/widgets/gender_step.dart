import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/onboarding/presentation/widgets/gender_button.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class GenderStep extends StatelessWidget {
  const GenderStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final step = state is OnboardingStepChanged ? state : null;
        final gender = step?.gender;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AppStrings.gender,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Seni en iyi tanımlayan seçeneği seç.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: GenderButton(
                      label: AppStrings.male,
                      icon: LucideIcons.mars,
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
                      icon: LucideIcons.venus,
                      isSelected: gender == Gender.female.name,
                      onTap: () => context.read<OnboardingCubit>().updateGender(
                        Gender.female,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: gender == null
                    ? null
                    : () => context.read<OnboardingCubit>().setGender(gender),
                child: const Text(AppStrings.continueButton),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        );
      },
    );
  }
}
