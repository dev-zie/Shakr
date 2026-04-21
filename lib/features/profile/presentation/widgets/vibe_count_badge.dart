import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';

class VibeCountBadge extends StatelessWidget {
  const VibeCountBadge({super.key, required this.count});

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
