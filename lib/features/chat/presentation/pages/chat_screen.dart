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
import 'dart:async';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final DateTime createdAt;
  const ChatScreen({super.key, required this.matchId, required this.createdAt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 10;
  late final MatchCubit _matchCubit;
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _matchCubit = sl<MatchCubit>();
    _chatCubit = sl<ChatCubit>();
    _secondsLeft = _calculateSecondsLeft(widget.createdAt);
    _chatCubit.watchMessages(widget.matchId);

    _matchCubit.watchMatch(sl<AuthCubit>().currentUid ?? '');

    _startTimer();
  }

  int _calculateSecondsLeft(DateTime createdAt) {
    final expireTime = createdAt.add(const Duration(seconds: 50));
    final remaining = expireTime.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newSecondsLeft = _calculateSecondsLeft(widget.createdAt);
      if (newSecondsLeft <= 0) {
        timer.cancel();
        if (mounted) context.go('/chat-expired/${widget.matchId}');
      } else {
        setState(() => _secondsLeft = newSecondsLeft);
      }
    });
  }

  String get _timerText {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final uid = sl<AuthCubit>().currentUid;
    final message = MessageEntity(
      id: const Uuid().v4(),
      senderId: uid!,
      text: _controller.text.trim(),
      createdAt: DateTime.now(),
    );
    _chatCubit.sendMessage(widget.matchId, message);
    _controller.clear();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = sl<AuthCubit>().currentUid;
    print('currentUid: $currentUid');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _timerText,
          style: TextStyle(
            color: _secondsLeft < 60
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MatchCubit, MatchState>(
            bloc: _matchCubit,
            listener: (context, state) {
              if (state is MatchDeleted) {
                context.go('/home');
              }
              if (state is MatchExpired) {
                context.go('/chat-expired/${widget.matchId}');
              }
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                bloc: _chatCubit,
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChatLoaded) {
                    return ChatMessageList(
                      messages: state.messages,
                      currentUid: currentUid,
                    );
                  }
                  if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
            ChatInputBar(controller: _controller, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
