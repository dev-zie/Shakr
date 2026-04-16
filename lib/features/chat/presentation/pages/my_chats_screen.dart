import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/common/getit/injection.dart';

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
              return _buildEmptyState(context);
            }

            // Sort conversations locally by lastMessageAt descending
            final sortedConversations = List.from(state.conversations)
              ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

            return ListView.separated(
              itemCount: sortedConversations.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              ),
              itemBuilder: (context, index) {
                final conv = sortedConversations[index];

                // Smarter date formatting
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final yesterday = today.subtract(const Duration(days: 1));
                final msgDate = DateTime(
                  conv.lastMessageAt.year,
                  conv.lastMessageAt.month,
                  conv.lastMessageAt.day,
                );

                String timeStr;
                if (msgDate == today) {
                  timeStr = DateFormat('HH:mm').format(conv.lastMessageAt);
                } else if (msgDate == yesterday) {
                  timeStr = 'Dün';
                } else {
                  timeStr = DateFormat('dd/MM/yy').format(conv.lastMessageAt);
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    backgroundImage: conv.otherUserPhoto != null
                        ? NetworkImage(conv.otherUserPhoto!)
                        : null,
                    child: conv.otherUserPhoto == null
                        ? Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          )
                        : null,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conv.otherUserName.isEmpty
                                  ? 'Kullanıcı'
                                  : conv.otherUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: msgDate == today
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                  fontWeight: msgDate == today
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ],
                      ),
                      if (conv.otherUserVibes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: conv.otherUserVibes
                              .take(3)
                              .map(
                                (v) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    v,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  onTap: () {
                    final encodedName = Uri.encodeComponent(conv.otherUserName);
                    final encodedPhoto = conv.otherUserPhoto != null 
                        ? Uri.encodeComponent(conv.otherUserPhoto!) 
                        : null;
                    
                    context.go(
                      '/chat/${conv.id}?permanent=true&name=$encodedName${encodedPhoto != null ? '&photo=$encodedPhoto' : ''}',
                      extra: conv.lastMessageAt,
                    );
                  },
                );
              },
            );
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: AppSpacing.m),
          Text(
            AppStrings.chatsPlaceholder,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
