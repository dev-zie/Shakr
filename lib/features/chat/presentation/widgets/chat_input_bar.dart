import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';

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
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => cubit.sendMessageFromInput(
                id,
                currentUid,
                isPermanent: isPermanent,
              ),
              icon: const Icon(LucideIcons.sendHorizontal, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
