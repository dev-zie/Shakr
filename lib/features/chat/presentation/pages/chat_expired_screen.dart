import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_expired_body.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/injection.dart';

class ChatExpiredScreen extends StatelessWidget {
  final String matchId;
  const ChatExpiredScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final matchCubit = sl<MatchCubit>();
    final currentUid = sl<AuthCubit>().currentUid;

    final currentState = matchCubit.state;
    if (currentState is! MatchExpired && currentState is! MatchFound) {
      matchCubit.getMatch(matchId);
    }

    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: matchCubit,
        listener: (context, state) {
          if (state is MatchDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.matchClosed)),
            );

            context.go('/home');
          }
        },
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: matchCubit,
          builder: (context, state) {
            if (state is MatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchDeleted) {
              context.go('/home');
            }

            MatchEntity? match;
            if (state is MatchFound) match = state.match;
            if (state is MatchExpired) match = state.match;

            if (match != null) {
              return ChatExpiredBody(
                match: match,
                matchId: matchId,
                currentUid: currentUid,
              );
            }

            return const Center(child: Text(AppStrings.StatelessWidget));
          },
        ),
      ),
    );
  }
}
