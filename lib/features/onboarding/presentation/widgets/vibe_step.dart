import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class VibeStep extends StatelessWidget {
  const VibeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final selectedVibes = state is OnboardingStepChanged
            ? state.vibes
            : <String>[];

        Color buttonColor = Theme.of(context).colorScheme.primary;
        if (selectedVibes.isNotEmpty) {
          final lastVibe = selectedVibes.last;
          for (final entry in AppVibes.categories.entries) {
            final vibesList = entry.value['vibes'] as List;
            if (vibesList.any((v) => v['label'] == lastVibe)) {
              buttonColor = entry.value['color'] as Color;
              break;
            }
          }
        }

        return Padding(
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
                AppStrings.selectThreeVibes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: ListView.builder(
                  itemCount: AppVibes.categories.entries.length,
                  itemBuilder: (context, index) {
                    final entry = AppVibes.categories.entries.elementAt(index);
                    final kategoriAdi = entry.key;
                    final kategoriData = entry.value;
                    final vibes = kategoriData['vibes'] as List;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              kategoriData['icon'] as IconData,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.s),
                            Text(
                              kategoriAdi,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: vibes.map((vibe) {
                            final label = vibe['label'] as String;
                            final icon = vibe['icon'] as IconData;
                            final isSelected = selectedVibes.contains(label);

                            return FilterChip(
                              avatar: Icon(
                                icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              selected: isSelected,

                              onSelected: (selected) {
                                if (selected) {
                                  context.read<OnboardingCubit>().selectVibe(
                                    label,
                                  );
                                } else {
                                  context.read<OnboardingCubit>().deselectVibe(
                                    label,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.l),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedVibes.length == 3 ? buttonColor : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: selectedVibes.length == 3
                    ? () => context.read<OnboardingCubit>().saveProfile()
                    : null,
                child: const Text(AppStrings.continueButton),
              ),
            ],
          ),
        );
      },
    );
  }
}
