import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_expired_body.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/common/getit/injection.dart';

class ChatExpiredPage extends StatelessWidget {
  const ChatExpiredPage({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context) {
    final matchCubit = sl<MatchCubit>();
    matchCubit.ensureLoaded(matchId);

    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: matchCubit,
        listener: (context, state) async {
          final messenger = ScaffoldMessenger.of(context);
          final router = GoRouter.of(context);

          if (state.status == MatchCubitStatus.deleted) {
            messenger.showSnackBar(
              const SnackBar(content: Text(AppStrings.matchClosed)),
            );
            router.go('/main/shake');
          } else if (state.status == MatchCubitStatus.bothKept) {
            messenger.showSnackBar(
              const SnackBar(content: Text(AppStrings.connectionSaved)),
            );
            context.go('/main/chats');
          } else if (state.status == MatchCubitStatus.connectionPending) {
            messenger.showSnackBar(
              const SnackBar(content: Text(AppStrings.waitingOtherDecide)),
            );
          }
        },
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: matchCubit,
          builder: (context, state) {
            if (state.status == MatchCubitStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final match = state.match;
            if (match != null) {
              return ChatExpiredBody(
                match: match,
                matchId: matchId,
                currentUid: sl<AuthCubit>().currentUid,
              );
            }

            return const Center(child: Text(''));
          },
        ),
      ),
    );
  }
}
