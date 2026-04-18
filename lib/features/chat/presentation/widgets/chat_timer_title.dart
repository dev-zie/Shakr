import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_state.dart';

String _formatTime(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class ChatTimerTitle extends StatelessWidget {
  const ChatTimerTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final secondsLeft = state is ChatTimerTickState
            ? state.secondsLeft
            : AppConstants.chatWaitingDisplaySeconds;
        return Text(
          _formatTime(secondsLeft),
          style: TextStyle(
            color: secondsLeft < AppConstants.chatTimerUrgentThresholdSeconds
                ? AppColors.error
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
