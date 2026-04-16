import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/profile/presentation/widgets/vibe_card.dart';

class VibeStep extends StatelessWidget {
  const VibeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final selectedVibes = state is OnboardingStepChanged
            ? state.vibes
            : <String>[];

        final allVibes = AppVibes.categories.values
            .expand((category) => (category['vibes'] as List))
            .map((vibe) => vibe['label'] as String)
            .toList();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.selectVibes,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Seni en iyi anlatan 3-5 vibe seç.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allVibes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSpacing.m,
                            crossAxisSpacing: AppSpacing.m,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final vibe = allVibes[index];
                        final isSelected = selectedVibes.contains(vibe);
                        return VibeCard(
                          vibe: vibe,
                          isSelected: isSelected,
                          onTap: () {
                            if (isSelected) {
                              cubit.deselectVibe(vibe);
                            } else {
                              cubit.selectVibe(vibe);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: ElevatedButton(
                onPressed: selectedVibes.length >= 3
                    ? () => cubit.saveProfile()
                    : null,
                child: const Text(AppStrings.continueButton),
              ),
            ),
          ],
        );
      },
    );
  }
}
