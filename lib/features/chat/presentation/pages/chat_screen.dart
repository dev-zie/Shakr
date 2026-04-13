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

class ChatScreen extends StatefulWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // DÜZELTME BURADA: Sayfa açılır açılmaz Timer'ı ve dinlemeyi başlatıyoruz!
    final matchState = sl<MatchCubit>().state;
    DateTime matchTime = DateTime.now(); // Güvenlik amacıya varsayılan saat

    if (matchState is MatchFound) {
      matchTime = matchState.match.createdAt;
    }

    sl<ChatCubit>().initChat(widget.matchId, matchTime);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = sl<AuthCubit>().currentUid;

    // PopScope: Fiziksel (Android) geri tuşunu kilitler
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false, // DÜZELTME BURADA: Geri okunu kaldırır!
          title: BlocBuilder<ChatCubit, ChatState>(
            bloc: sl<ChatCubit>(),
            builder: (context, state) {
              int secondsLeft = 300;
              if (state is ChatTimerTickState) secondsLeft = state.secondsLeft;

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
                  sl<ChatCubit>().disposeScreen();
                  context.go('/home');
                }
              },
            ),
            BlocListener<ChatCubit, ChatState>(
              bloc: sl<ChatCubit>(),
              listener: (context, state) {
                if (state is ChatTimeExpiredState) {
                  sl<ChatCubit>().disposeScreen();
                  context.go('/chat-expired/${widget.matchId}');
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  bloc: sl<ChatCubit>(),
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
                onSend: (text) {
                  final message = MessageEntity(
                    id: const Uuid().v4(),
                    senderId: currentUid!,
                    text: text,
                    createdAt: DateTime.now(),
                  );
                  sl<ChatCubit>().sendMessage(widget.matchId, message);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
