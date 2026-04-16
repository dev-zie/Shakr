import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_timer_title.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/common/getit/injection.dart';

class ChatScreen extends StatelessWidget {
  final String matchId;
  final DateTime chatStartTime;
  final bool isPermanent;
  final String? otherUserName;
  final String? otherUserPhoto;

  const ChatScreen({
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
          title: isPermanent
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      backgroundImage: otherUserPhoto != null
                          ? NetworkImage(otherUserPhoto!)
                          : null,
                      child: otherUserPhoto == null
                          ? Icon(
                              Icons.person,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        otherUserName ?? 'Sohbet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const ChatTimerTitle(),
          centerTitle: !isPermanent,
          actions: [
            if (!isPermanent)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: AppStrings.endMatch,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(AppStrings.endMatch),
                      content: const Text(
                        'Eşleşmeyi sonlandırmak istediğinize emin misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(AppStrings.okay),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    sl<MatchCubit>().endMatch(matchId);
                  }
                },
              ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<MatchCubit, MatchState>(
              bloc: sl<MatchCubit>(),
              listener: (context, state) {
                if (state is MatchDeleted && !isPermanent) {
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
                if (state is ChatTimeExpiredState) {
                  context.go('/chat-expired/$matchId');
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatTimerTickState) {
                      return ChatMessageList(
                        messages: state.messages,
                        currentUid: currentUid,
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              ChatInputBar(
                id: matchId,
                currentUid: currentUid!,
                isPermanent: isPermanent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
