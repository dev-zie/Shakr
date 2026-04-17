import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/widgets/vibe_chip.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

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

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  Text(
                    AppStrings.selectVibes,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    AppStrings.onboardingSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ...AppVibes.categories.entries.map((categoryEntry) {
                    final categoryName = categoryEntry.key;
                    final categoryData = categoryEntry.value;
                    final List vibesList = categoryData['vibes'];
                    final Color categoryColor = categoryData['color'] as Color;
                    final IconData categoryIcon =
                        categoryData['icon'] as IconData;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(categoryIcon, size: 18, color: categoryColor),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              categoryName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.xs,
                          children: vibesList.map((vibeData) {
                            final vibeLabel = vibeData['label'] as String;
                            final vibeIcon = vibeData['icon'] as IconData;
                            final isSelected = selectedVibes.contains(
                              vibeLabel,
                            );

                            return VibeChip(
                              label: vibeLabel,
                              icon: vibeIcon,
                              isSelected: isSelected,
                              activeColor: categoryColor,
                              onTap: () {
                                if (isSelected) {
                                  cubit.deselectVibe(vibeLabel);
                                } else {
                                  cubit.selectVibe(vibeLabel);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    );
                  }),
                ],
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
