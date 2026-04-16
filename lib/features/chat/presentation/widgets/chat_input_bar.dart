import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/common/constants/app_spacing.dart';

class ChatInputBar extends StatelessWidget {
  final String id;
  final String currentUid;
  final bool isPermanent;

  const ChatInputBar({
    super.key,
    required this.id,
    required this.currentUid,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.xl, // Alt padding artırıldı
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cubit.messageController,
              decoration: InputDecoration(
                hintText: AppStrings.writeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            onPressed: () => cubit.sendMessageFromInput(
              id,
              currentUid,
              isPermanent: isPermanent,
            ),
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
