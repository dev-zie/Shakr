import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/theme/app_shadows.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

class ChatMessageList extends StatelessWidget {
  final List<MessageEntity> messages;
  final String? currentUid;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.messageSquare,
                size: AppDimensions.emptyChatIconSize,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              AppStrings.sendFirstMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.l,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUid;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s + 2,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.chip),
                  topRight: const Radius.circular(AppRadius.chip),
                  bottomLeft: Radius.circular(isMe ? AppRadius.chip : AppRadius.xs),
                  bottomRight: Radius.circular(isMe ? AppRadius.xs : AppRadius.chip),
                ),
                boxShadow: AppShadows.soft,
                border: isMe
                    ? null
                    : Border.all(
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isMe ? Colors.white : null,
                      fontSize: AppTextSizes.chatMessage,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
