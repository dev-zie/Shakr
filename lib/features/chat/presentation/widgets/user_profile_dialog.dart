import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';

class UserProfileDialog extends StatelessWidget {
  final ConversationEntity conversation;

  const UserProfileDialog({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimensions.profileDialogAvatarSize,
              height: AppDimensions.profileDialogAvatarSize,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                image: conversation.otherUserPhoto != null
                    ? DecorationImage(
                        image: NetworkImage(conversation.otherUserPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: conversation.otherUserPhoto == null
                  ? const Icon(
                      LucideIcons.user,
                      size: AppDimensions.profileDialogIconSize,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              conversation.otherUserName.isEmpty
                  ? AppStrings.unknownUser
                  : conversation.otherUserName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (conversation.otherUserVibes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _VibeChipWrap(vibes: conversation.otherUserVibes),
            ],
          ],
        ),
      ),
    );
  }
}

class _VibeChipWrap extends StatelessWidget {
  final List<String> vibes;

  const _VibeChipWrap({required this.vibes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      alignment: WrapAlignment.center,
      children: vibes.map((vibe) {
        final vibeColor = AppVibes.colorForVibe(vibe);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: vibeColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: vibeColor.withValues(alpha: 0.4)),
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
