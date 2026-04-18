import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';

class VibeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const VibeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: AppDimensions.vibeChipAvatarIconSize,
        color: isSelected ? Colors.white : activeColor,
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: activeColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : activeColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: AppTextSizes.vibeChipLabel,
      ),
      backgroundColor: activeColor.withValues(alpha: 0.05),
      side: BorderSide(
        color: isSelected ? activeColor : activeColor.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      showCheckmark: false,
    );
  }
}
