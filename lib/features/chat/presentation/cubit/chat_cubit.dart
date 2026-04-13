import 'dart:async';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/injection.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  final WatchMessagesUsecase watchMessagesUsecase;

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
      final expireTime = createdAt.add(
        const Duration(seconds: 300),
      ); // 5 dk = 300 saniye
      final remaining = expireTime.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        sl<MatchCubit>().expireMatch(matchId);
        emit(ChatTimeExpiredState());
      } else {
        // DÜZELTME BURADA: Mesajları ChatTimerTickState'ten almalıyız
        List<MessageEntity> currentMessages = [];
        if (state is ChatTimerTickState) {
          currentMessages = (state as ChatTimerTickState).messages;
        } else if (state is ChatLoaded) {
          currentMessages = (state as ChatLoaded).messages;
        }

        emit(ChatTimerTickState(remaining, currentMessages));
      }
    });
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
