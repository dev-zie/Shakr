import 'dart:async';

import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/domain/usecases/watch_messages_usecase.dart';

import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  final WatchMessagesUsecase watchMessagesUsecase;
  StreamSubscription? _subscription;

  ChatCubit({
    required this.sendMessageUsecase,
    required this.watchMessagesUsecase,
  }) : super(ChatInitial());

  Future<void> sendMessage(String matchId, MessageEntity message) async {
    final result = await sendMessageUsecase.call(matchId, message);
    result.fold((l) => emit(ChatError(l.message)), (r) => null);
  }

  void watchMessages(String matchId) {
    emit(ChatLoading());
    _subscription = watchMessagesUsecase
        .call(matchId)
        .listen(
          (messages) {
            emit(ChatLoaded(messages));
          },
          onError: (error) {
            emit(ChatError(error.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
