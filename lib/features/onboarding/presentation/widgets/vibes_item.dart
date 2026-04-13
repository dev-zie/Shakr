import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class VibesItem extends StatelessWidget {
  const VibesItem({
    super.key,
    required this.category,
    required this.vibes,
    required this.selectedVibes,
  });
  final String category;
  final List vibes;
  final List selectedVibes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vibes.map((vibe) {
            final isSelected = selectedVibes.contains(vibe);
            return FilterChip(
              label: Text(vibe),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<OnboardingCubit>().selectVibe(vibe);
                } else {
                  context.read<OnboardingCubit>().deselectVibe(vibe);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
