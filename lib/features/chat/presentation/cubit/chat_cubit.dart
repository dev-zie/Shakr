import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shakr/features/chat/domain/usecases/watch_conversations_usecase.dart';
import 'package:shakr/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:uuid/uuid.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  final WatchMessagesUsecase watchMessagesUsecase;
  final WatchConversationsUsecase watchConversationsUsecase;

  final messageController = TextEditingController();

  StreamSubscription? _subscription;
  Timer? _timer;

  ChatCubit({
    required this.sendMessageUsecase,
    required this.watchMessagesUsecase,
    required this.watchConversationsUsecase,
  }) : super(ChatInitial());

  void initChat(
    String id,
    DateTime fallbackCreatedAt, {
    bool isPermanent = false,
  }) {
    watchMessages(id, isPermanent: isPermanent);
    if (!isPermanent) {
      _startTimer(id, fallbackCreatedAt);
    } else {
      emit(ChatTimerTickState(-1, []));
    }
  }

  void _startTimer(String matchId, DateTime fallbackCreatedAt) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isClosed) {
        timer.cancel();
        return;
      }

      final matchResult = await sl<MatchCubit>().getMatchUsecase.call(matchId);
      matchResult.fold((l) => null, (match) {
        if (match == null) {
          timer.cancel();
          return;
        }

        final startTime = match.chatStartedAt ?? fallbackCreatedAt;
        final isWaiting = match.chatStartedAt == null;

        final expireTime = startTime.add(const Duration(seconds: 30));
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

          // Eğer henüz her iki taraf da girmemişse (waiting), timer'ı donduralım veya bekleme durumunu gösterelim.
          // Ama kullanıcı "sohbete git dediginde sure baslayacak" dediği için
          // chatStartedAt null olduğu sürece süre 300 (veya tam süre) olarak kalmalı.
          final displayRemaining = isWaiting ? 300 : remaining;

          if (!isClosed)
            emit(ChatTimerTickState(displayRemaining, currentMessages));
        }
      });
    });
  }

  Future<void> sendMessageFromInput(
    String id,
    String uid, {
    bool isPermanent = false,
  }) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    final message = MessageEntity(
      id: const Uuid().v4(),
      senderId: uid,
      text: text,
      createdAt: DateTime.now(),
    );
    await sendMessage(id, message, isPermanent: isPermanent);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _subscription?.cancel();
    messageController.dispose();
    return super.close();
  }

  Future<void> sendMessage(
    String id,
    MessageEntity message, {
    bool isPermanent = false,
  }) async {
    final result = await sendMessageUsecase.call(
      id,
      message,
      isPermanent: isPermanent,
    );
    result.fold((l) => emit(ChatError(l.message)), (r) => null);
  }

  void watchMessages(String id, {bool isPermanent = false}) {
    emit(ChatLoading());
    _subscription = watchMessagesUsecase
        .call(id, isPermanent: isPermanent)
        .listen(
          (messages) {
            final currentSeconds = (state is ChatTimerTickState)
                ? (state as ChatTimerTickState).secondsLeft
                : (isPermanent ? -1 : 300);

            if (!isClosed) emit(ChatTimerTickState(currentSeconds, messages));
          },
          onError: (error) {
            if (!isClosed) emit(ChatError(error.toString()));
          },
        );
  }

  Stream<ChatState> watchConversations(String uid) {
    return watchConversationsUsecase.call(uid).map((result) {
      return result.fold(
        (failure) => ChatError(failure.message),
        (conversations) => ChatConversationsLoaded(conversations),
      );
    });
  }

  void disposeScreen() {
    _timer?.cancel();
    _subscription?.cancel();
    emit(ChatInitial());
  }
}
