import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:uuid/uuid.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  final WatchMessagesUsecase watchMessagesUsecase;

  final messageController = TextEditingController();

  StreamSubscription? _subscription;
  Timer? _timer;

  ChatCubit({
    required this.sendMessageUsecase,
    required this.watchMessagesUsecase,
  }) : super(ChatInitial());

  void initChat(String matchId, DateTime createdAt) {
    watchMessages(matchId);
    _startTimer(matchId, createdAt);
  }

  void _startTimer(String matchId, DateTime createdAt) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final expireTime = createdAt.add(const Duration(seconds: 30));
      final remaining = expireTime.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        sl<MatchCubit>().expireMatch(matchId);
        if (!isClosed) emit(ChatTimeExpiredState());
      } else {
        List<MessageEntity> currentMessages = [];
        if (state is ChatTimerTickState) {
          currentMessages = (state as ChatTimerTickState).messages;
        }

        if (!isClosed) emit(ChatTimerTickState(remaining, currentMessages));
      }
    });
  }

  Future<void> sendMessageFromInput(String matchId, String uid) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    final message = MessageEntity(
      id: const Uuid().v4(),
      senderId: uid,
      text: text,
      createdAt: DateTime.now(),
    );
    await sendMessage(matchId, message);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _subscription?.cancel();
    messageController.dispose();
    return super.close();
  }

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
            final currentSeconds = (state is ChatTimerTickState)
                ? (state as ChatTimerTickState).secondsLeft
                : 300;
            emit(ChatTimerTickState(currentSeconds, messages));
          },
          onError: (error) {
            emit(ChatError(error.toString()));
          },
        );
  }

  void disposeScreen() {
    _timer?.cancel();
    _subscription?.cancel();
    emit(ChatInitial());
  }
}
