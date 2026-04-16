import 'package:flutter/material.dart';
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
    IconData iconData = Icons.star_border_outlined;
    Color vibeColor = AppColors.primary;

    // Map vibe string to icon and color
    for (var category in AppVibes.categories.values) {
      final List vibesList = category['vibes'];
      final match = vibesList.firstWhere(
        (v) => v['label'] == vibe,
        orElse: () => null,
      );
      if (match != null) {
        iconData = match['icon'] as IconData;
        vibeColor = category['color'] as Color;
        break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? vibeColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? vibeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [] : AppShadows.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: vibeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: vibeColor,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              vibe,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? vibeColor : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
