import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  const ChatScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final matchState = sl<MatchCubit>().state;
    final currentUid = sl<AuthCubit>().currentUid;

    final matchTime =
        matchState is MatchFound ? matchState.match.createdAt : DateTime.now();

    final chatCubit = sl<ChatCubit>()..initChat(matchId, matchTime);

    return BlocProvider.value(
      value: chatCubit,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const ChatTimerTitle(),
            centerTitle: true,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<MatchCubit, MatchState>(
                bloc: sl<MatchCubit>(),
                listener: (context, state) {
                  if (state is MatchDeleted) context.go('/home');
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
                  matchId: matchId,
                  currentUid: currentUid!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
