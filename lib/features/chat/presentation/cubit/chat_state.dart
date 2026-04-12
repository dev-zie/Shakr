import 'package:equatable/equatable.dart';
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

class ChatError extends ChatState with EquatableMixin {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
