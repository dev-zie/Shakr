import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/widgets/confirm_dialog.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/widgets/conversation_avatar.dart';
import 'package:shakr/features/chat/presentation/widgets/user_profile_dialog.dart';

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
      confirmDismiss: (_) => ConfirmDialog.show(
        context,
        title: AppStrings.deleteConversation,
        content: AppStrings.deleteConversationConfirm,
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
            builder: (_) => UserProfileDialog(conversation: conversation),
          ),
          child: ConversationAvatar(photoUrl: conversation.otherUserPhoto),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                conversation.otherUserName.isEmpty
                    ? AppStrings.unknownUser
                    : conversation.otherUserName,
                style: Theme.of(context).textTheme.titleMedium,
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        onTap: () {
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
