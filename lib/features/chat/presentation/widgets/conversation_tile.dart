import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';

class ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;

  const ConversationTile({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(
      conversation.lastMessageAt.year,
      conversation.lastMessageAt.month,
      conversation.lastMessageAt.day,
    );

    final String timeStr;
    if (msgDate == today) {
      timeStr = DateFormat('HH:mm').format(conversation.lastMessageAt);
    } else if (msgDate == yesterday) {
      timeStr = AppStrings.yesterday;
    } else {
      timeStr = DateFormat('dd/MM/yy').format(conversation.lastMessageAt);
    }

    final isToday = msgDate == today;
    final currentUid = sl<AuthCubit>().currentUid ?? '';
    final isUnread = !conversation.readBy.contains(currentUid);

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        color: AppColors.error,
        child: const Icon(
          LucideIcons.trash2,
          color: Colors.white,
          size: AppDimensions.conversationIconSize,
        ),
      ),
      onDismissed: (_) => sl<ChatCubit>().deleteConversation(conversation.id),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        leading: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => _UserProfileDialog(conversation: conversation),
          ),
          child: _ConversationAvatar(photoUrl: conversation.otherUserPhoto),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                conversation.otherUserName.isEmpty
                    ? AppStrings.unknownUser
                    : conversation.otherUserName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              timeStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isToday ? AppColors.primary : null,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
              color: isUnread
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : null,
            ),
          ),
        ),
        onTap: () {
          if (currentUid.isNotEmpty) {
            sl<ChatCubit>().markAsRead(conversation.id, currentUid);
          }
          final encodedName = Uri.encodeComponent(conversation.otherUserName);
          final encodedPhoto = conversation.otherUserPhoto != null
              ? Uri.encodeComponent(conversation.otherUserPhoto!)
              : null;
          context.push(
            '/chat/${conversation.id}?permanent=true&name=$encodedName'
            '${encodedPhoto != null ? '&photo=$encodedPhoto' : ''}',
            extra: conversation.lastMessageAt,
          );
        },
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  const _ConversationAvatar({required this.photoUrl});

  final String? photoUrl;

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

class _UserProfileDialog extends StatelessWidget {
  const _UserProfileDialog({required this.conversation});

  final ConversationEntity conversation;

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
  const _VibeChipWrap({required this.vibes});

  final List<String> vibes;

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
