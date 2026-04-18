import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/constants/app_vibes.dart';

class MatchVibeChips extends StatelessWidget {
  final List<String> vibes;

  const MatchVibeChips({
    super.key,
    required this.vibes,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      alignment: WrapAlignment.center,
      children: vibes.map((vibe) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final vibeColor = AppVibes.colorForVibe(vibe);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: vibeColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: vibeColor.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            vibe,
            style: TextStyle(
              color: vibeColor,
              fontWeight: FontWeight.w600,
              fontSize: AppTextSizes.vibeChip,
            ),
          ),
        );
      }).toList(),
    );
  }
}
