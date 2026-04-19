import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_message_list.dart';

class ChatBody extends StatelessWidget {
  final String matchId;
  final String currentUid;
  final bool isPermanent;

  const ChatBody({
    super.key,
    required this.matchId,
    required this.currentUid,
    required this.isPermanent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state.status == ChatStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ChatStatus.timerTick) {
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
          currentUid: currentUid,
          isPermanent: isPermanent,
        ),
      ],
    );
  }
}
