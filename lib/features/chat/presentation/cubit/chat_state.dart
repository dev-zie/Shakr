import 'package:equatable/equatable.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

enum ChatStatus {
  initial,
  loading,
  timerTick,
  timeExpired,
  conversationsLoaded,
  conversationDeleted,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageEntity> messages;
  final List<ConversationEntity> conversations;
  final int secondsLeft;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.conversations = const [],
    this.secondsLeft = 0,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageEntity>? messages,
    List<ConversationEntity>? conversations,
    int? secondsLeft,
    String? errorMessage,
  }) => ChatState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    conversations: conversations ?? this.conversations,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, messages, conversations, secondsLeft, errorMessage];
}
