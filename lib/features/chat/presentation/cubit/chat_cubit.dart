import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/usecases/delete_conversation_usecase.dart';
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
  final DeleteConversationUsecase deleteConversationUsecase;

  final messageController = TextEditingController();

  StreamSubscription? _subscription;
  Timer? _timer;

  ChatCubit({
    required this.sendMessageUsecase,
    required this.watchMessagesUsecase,
    required this.watchConversationsUsecase,
    required this.deleteConversationUsecase,
  }) : super(const ChatState());

  void initChat(
    String id,
    DateTime fallbackCreatedAt, {
    bool isPermanent = false,
  }) {
    watchMessages(id, isPermanent: isPermanent);
    if (!isPermanent) {
      _startTimer(id, fallbackCreatedAt);
    } else {
      emit(state.copyWith(status: ChatStatus.timerTick, secondsLeft: -1));
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

        final expireTime = startTime.add(
          const Duration(seconds: AppConstants.chatExpirationSeconds),
        );
        final remaining = expireTime.difference(DateTime.now()).inSeconds;

        if (remaining <= 0) {
          timer.cancel();
          sl<MatchCubit>().expireMatch(matchId);
          if (!isClosed) emit(state.copyWith(status: ChatStatus.timeExpired));
        } else {
          // chatStartedAt null olduğu sürece süre beklemede görünür
          final displayRemaining = isWaiting
              ? AppConstants.chatWaitingDisplaySeconds
              : remaining;

          if (!isClosed) {
            emit(state.copyWith(
              status: ChatStatus.timerTick,
              secondsLeft: displayRemaining,
            ));
          }
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
    result.fold(
      (l) => emit(state.copyWith(status: ChatStatus.error, errorMessage: l.message)),
      (r) => null,
    );
  }

  void watchMessages(String id, {bool isPermanent = false}) {
    emit(state.copyWith(status: ChatStatus.loading));
    _subscription = watchMessagesUsecase
        .call(id, isPermanent: isPermanent)
        .listen(
          (messages) {
            final currentSeconds = state.status == ChatStatus.timerTick
                ? state.secondsLeft
                : (isPermanent ? -1 : AppConstants.chatWaitingDisplaySeconds);

            if (!isClosed) {
              emit(state.copyWith(
                status: ChatStatus.timerTick,
                secondsLeft: currentSeconds,
                messages: messages,
              ));
            }
          },
          onError: (error) {
            if (!isClosed) emit(state.copyWith(status: ChatStatus.error, errorMessage: error.toString()));
          },
        );
  }

  Stream<ChatState> watchConversations(String uid) {
    return watchConversationsUsecase.call(uid).map((result) {
      return result.fold(
        (failure) => ChatState(status: ChatStatus.error, errorMessage: failure.message),
        (conversations) => ChatState(status: ChatStatus.conversationsLoaded, conversations: conversations),
      );
    });
  }

  Future<void> markAsRead(String conversationId, String uid) async {
    try {
      await watchConversationsUsecase.repo
          .markConversationRead(conversationId, uid);
    } catch (_) {}
  }

  Future<void> deleteConversation(String conversationId) async {
    final result = await deleteConversationUsecase.call(conversationId);
    result.fold(
      (l) => emit(state.copyWith(status: ChatStatus.error, errorMessage: l.message)),
      (l) => emit(state.copyWith(status: ChatStatus.conversationDeleted)),
    );
  }
}
