import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
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

    String timeStr;
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      leading: GestureDetector(
        onTap: () => _showUserProfile(context),
        child: Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            image: conversation.otherUserPhoto != null
                ? DecorationImage(
                    image: NetworkImage(conversation.otherUserPhoto!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: conversation.otherUserPhoto == null
              ? const Icon(LucideIcons.user, color: AppColors.primary, size: 28)
              : null,
        ),
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
        padding: const EdgeInsets.only(top: 4),
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
          '/chat/${conversation.id}?permanent=true&name=$encodedName${encodedPhoto != null ? '&photo=$encodedPhoto' : ''}',
          extra: conversation.lastMessageAt,
        );
      },
    );
  }

  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 100,
                height: 100,
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
                        size: 44,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                conversation.otherUserName.isEmpty
                    ? AppStrings.unknownUser
                    : conversation.otherUserName,
              ),
              if (conversation.otherUserVibes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.l),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  alignment: WrapAlignment.center,
                  children: conversation.otherUserVibes.map((vibe) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    final vibeColor = AppVibes.colorForVibe(vibe);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: vibeColor.withValues(
                          alpha: isDark ? 0.15 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: vibeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        vibe,
                        style: TextStyle(
                          color: vibeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
