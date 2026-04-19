import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/theme/app_colors.dart';

class ConversationAvatar extends StatelessWidget {
  final String? photoUrl;

  const ConversationAvatar({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.conversationAvatarSize,
      height: AppDimensions.conversationAvatarSize,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: photoUrl == null
          ? const Icon(
              LucideIcons.user,
              color: AppColors.primary,
              size: AppDimensions.conversationIconSize,
            )
          : null,
    );
  }
}
