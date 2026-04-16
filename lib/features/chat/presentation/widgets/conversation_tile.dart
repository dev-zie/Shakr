import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;

  const ConversationTile({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    // Date formatting
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
      timeStr = 'Dün';
    } else {
      timeStr = DateFormat('dd/MM/yy').format(conversation.lastMessageAt);
    }

    final isToday = msgDate == today;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  conversation.otherUserName.isEmpty ? 'Kullanıcı' : conversation.otherUserName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timeStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textSecondaryLight,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                    ),
              ),
            ],
          ),
          if (conversation.otherUserVibes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 4,
              children: conversation.otherUserVibes.take(3).map((vibe) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vibe,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      ),
      onTap: () {
        final encodedName = Uri.encodeComponent(conversation.otherUserName);
        final encodedPhoto = conversation.otherUserPhoto != null ? Uri.encodeComponent(conversation.otherUserPhoto!) : null;

        context.go(
          '/chat/${conversation.id}?permanent=true&name=$encodedName${encodedPhoto != null ? '&photo=$encodedPhoto' : ''}',
          extra: conversation.lastMessageAt,
        );
      },
    );
  }
}
