import 'package:equatable/equatable.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';

class ChatState {}

class ChatInitial extends ChatState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState with EquatableMixin {
  final List<MessageEntity> messages;

  ChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatTimerTickState extends ChatState with EquatableMixin {
  final int secondsLeft;
  final List<MessageEntity> messages;

  ChatTimerTickState(this.secondsLeft, this.messages);

  @override
  List<Object?> get props => [secondsLeft, messages];
}

class ChatTimeExpiredState extends ChatState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChatConversationsLoaded extends ChatState with EquatableMixin {
  final List<ConversationEntity> conversations;
  ChatConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ChatConversationDeleted extends ChatState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ChatError extends ChatState with EquatableMixin {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
