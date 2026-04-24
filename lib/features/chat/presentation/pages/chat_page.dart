import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/widgets/confirm_dialog.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_body.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_timer_title.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/shake/presentation/widgets/go_back_button.dart';

class ChatPage extends StatelessWidget {
  final String matchId;
  final DateTime chatStartTime;
  final bool isPermanent;
  final String? otherUserName;
  final String? otherUserPhoto;

  const ChatPage({
    super.key,
    required this.matchId,
    required this.chatStartTime,
    this.isPermanent = false,
    this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = sl<AuthCubit>().currentUid;

    final chatCubit = sl<ChatCubit>()
      ..initChat(matchId, chatStartTime, isPermanent: isPermanent);

    return BlocProvider.value(
      value: chatCubit,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isPermanent
              ? GoBackButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/main/chats');
                    }
                  },
                )
              : null,
          title: _buildAppBarTitle(context),
          centerTitle: !isPermanent,
          actions: _buildAppBarActions(context),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<MatchCubit, MatchState>(
              bloc: sl<MatchCubit>(),
              listener: (context, state) {
                if (state.status == MatchCubitStatus.deleted && !isPermanent) {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/main/shake');
                  }
                }
              },
            ),
            BlocListener<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.status == ChatStatus.timeExpired) {
                  context.go('/chat-expired/$matchId');
                } else if (state.status == ChatStatus.conversationDeleted) {
                  context.go('/main/chats');
                }
              },
            ),
          ],
          child: ChatBody(
            matchId: matchId,
            currentUid: currentUid!,
            isPermanent: isPermanent,
          ),
        ),
      ),
    );
  }

  // bolunecek

  Widget _buildAppBarTitle(BuildContext context) {
    if (!isPermanent) {
      return const ChatTimerTitle();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            image: otherUserPhoto != null
                ? DecorationImage(
                    image: NetworkImage(otherUserPhoto!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: otherUserPhoto == null
              ? const Icon(LucideIcons.user, size: 18, color: AppColors.primary)
              : null,
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Text(
            otherUserName ?? AppStrings.chatDefaultTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () => _showDeleteDialog(context),
          icon: const Icon(LucideIcons.trash2),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    if (isPermanent) return [];

    return [
      IconButton(
        icon: const Icon(LucideIcons.x),
        tooltip: AppStrings.endMatch,
        onPressed: () => _showEndMatchDialog(context),
      ),
    ];
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: AppStrings.deleteConversation,
      content: AppStrings.deleteConversationConfirm,
    );
    if (confirm) sl<ChatCubit>().deleteConversation(matchId);
  }

  Future<void> _showEndMatchDialog(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: AppStrings.endMatch,
      content: AppStrings.endMatchConfirm,
    );
    if (confirm) sl<MatchCubit>().endMatch(matchId);
  }
}
