import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: AppSpacing.s),
            Text(
              'İlk mesajı sen gönder!',
              style: TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
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
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.m),
                  topRight: const Radius.circular(AppSpacing.m),
                  bottomLeft: Radius.circular(isMe ? AppSpacing.m : 0),
                  bottomRight: Radius.circular(isMe ? 0 : AppSpacing.m),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
