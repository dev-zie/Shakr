import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';

class VibeItems extends StatelessWidget {
  const VibeItems({
    super.key,
    required this.category,
    required this.vibes,
    required this.selectedVibes,
  });
  final List selectedVibes;
  final String category;
  final List vibes;

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
                  context.read<SettingsCubit>().selectVibe(vibe);
                } else {
                  context.read<SettingsCubit>().deselectVibe(vibe);
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
