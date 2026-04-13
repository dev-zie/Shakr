import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/injection.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatelessWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final matchCubit = sl<MatchCubit>();
    final matchState = matchCubit.state;
    final currentUid = sl<AuthCubit>().currentUid;

    DateTime matchTime = DateTime.now();

    String _formatTime(int seconds) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }

    if (matchState is MatchFound) {
      matchTime = matchState.match.createdAt;
    }

    final chatCubit = sl<ChatCubit>()..initChat(matchId, matchTime);

    return BlocProvider.value(
      value: chatCubit,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                int secondsLeft = 300;
                if (state is ChatTimerTickState) {
                  secondsLeft = state.secondsLeft;
                }
                return Text(
                  _formatTime(secondsLeft),
                  style: TextStyle(
                    color: secondsLeft < 60
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            centerTitle: true,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<MatchCubit, MatchState>(
                bloc: sl<MatchCubit>(),
                listener: (context, state) {
                  if (state is MatchDeleted) {
                    context.go('/home');
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
                Builder(
                  builder: (chatContext) {
                    return ChatInputBar(
                      onSend: (text) {
                        final message = MessageEntity(
                          id: const Uuid().v4(),
                          senderId: currentUid!,
                          text: text,
                          createdAt: DateTime.now(),
                        );
                        chatContext.read<ChatCubit>().sendMessage(
                          matchId,
                          message,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
