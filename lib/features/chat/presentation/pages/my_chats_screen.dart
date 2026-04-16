import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/common/getit/injection.dart';

import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:shakr/features/chat/presentation/widgets/empty_chat_state.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = sl<AuthCubit>().currentUid;
    if (uid == null) {
      return const Center(child: Text('Giriş yapmanız gerekiyor.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabChats), centerTitle: true),
      body: StreamBuilder<ChatState>(
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

            // Sort conversations locally by lastMessageAt descending
            final sortedConversations = List<ConversationEntity>.from(
              state.conversations,
            )..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

            return ListView.separated(
              itemCount: sortedConversations.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Divider(
                  height: 1,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
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
      ),
    );
  }
}
