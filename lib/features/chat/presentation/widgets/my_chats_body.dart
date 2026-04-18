import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:shakr/features/chat/presentation/widgets/empty_chat_state.dart';
import 'package:shakr/common/getit/injection.dart';

class MyChatsBody extends StatelessWidget {
  final String uid;

  const MyChatsBody({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatState>(
      stream: sl<ChatCubit>().watchConversations(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final state = snapshot.data;

        if (state is ChatConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return const EmptyChatState();
          }

          final sortedConversations = List<ConversationEntity>.from(
            state.conversations,
          )..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

          return ListView.separated(
            itemCount: sortedConversations.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.dividerIndent,
              ),
              child: Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
            itemBuilder: (context, index) {
              return ConversationTile(
                conversation: sortedConversations[index],
              );
            },
          );
        }

        if (state is ChatError) {
          return Center(child: Text(state.message));
        }

        return const EmptyChatState();
      },
    );
  }
}
