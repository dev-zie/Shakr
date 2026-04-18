import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/widgets/vibe_chip.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';

class ProfileVibesSelector extends StatelessWidget {
  const ProfileVibesSelector({super.key, required this.selectedVibes});

  final List<String> selectedVibes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.vibes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            _VibeCountBadge(count: selectedVibes.length),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        ...AppVibes.categories.entries.map(
          (entry) => _VibeCategorySection(
            categoryName: entry.key,
            categoryData: entry.value,
            selectedVibes: selectedVibes,
          ),
        ),
      ],
    );
  }
}

class _VibeCountBadge extends StatelessWidget {
  const _VibeCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isComplete = count == 3;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.primary.withValues(alpha: .12)
            : AppColors.warning.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        '$count/3',
        style: TextStyle(
          fontSize: AppTextSizes.vibeChip,
          fontWeight: FontWeight.w600,
          color: isComplete ? AppColors.primary : AppColors.warning,
        ),
      ),
    );
  }
}

class _VibeCategorySection extends StatelessWidget {
  const _VibeCategorySection({
    required this.categoryName,
    required this.categoryData,
    required this.selectedVibes,
  });

  final String categoryName;
  final Map<String, dynamic> categoryData;
  final List<String> selectedVibes;

  @override
  Widget build(BuildContext context) {
    final vibes = categoryData['vibes'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              categoryData['icon'] as IconData,
              size: AppDimensions.vibeCardIconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(categoryName, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          children: vibes.map((vibe) {
            final label = vibe['label'] as String;
            final icon = vibe['icon'] as IconData;
            final isSelected = selectedVibes.contains(label);
            final categoryColor = categoryData['color'] as Color;

            return VibeChip(
              label: label,
              icon: icon,
              isSelected: isSelected,
              activeColor: categoryColor,
              onTap: () {
                if (!isSelected && selectedVibes.length >= 3) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.maxThreeVibes),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  context.read<ProfileCubit>().toggleVibe(label);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}
