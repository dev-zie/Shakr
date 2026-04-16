import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';

class ChatInputBar extends StatelessWidget {
  final String matchId;
  final String currentUid;

  const ChatInputBar({
    super.key,
    required this.matchId,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(90),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cubit.messageController,
              decoration: InputDecoration(
                hintText: AppStrings.writeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => cubit.sendMessageFromInput(matchId, currentUid),
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
