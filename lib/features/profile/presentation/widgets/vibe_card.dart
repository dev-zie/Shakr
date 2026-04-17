import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/theme/app_shadows.dart';

class VibeCard extends StatelessWidget {
  final String vibe;
  final bool isSelected;
  final VoidCallback? onTap;

  const VibeCard({
    super.key,
    required this.vibe,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData = LucideIcons.star;
    Color vibeColor = AppColors.primary;

    // Map vibe string to icon and color
    loop:
    for (var category in AppVibes.categories.values) {
      final List vibesList = category['vibes'];
      for (var v in vibesList) {
        if (v['label'] == vibe) {
          iconData = v['icon'] as IconData;
          vibeColor = category['color'] as Color;
          break loop;
        }
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? vibeColor.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? vibeColor.withValues(alpha: 0.5)
              : vibeColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: isSelected ? [] : AppShadows.soft,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: vibeColor, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            vibe,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: vibeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
