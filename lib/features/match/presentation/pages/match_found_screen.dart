import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/match/presentation/widgets/match_found_body.dart';
import 'package:shakr/common/getit/injection.dart';

class MatchFoundScreen extends StatelessWidget {
  final String matchId;

  const MatchFoundScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchAccepted) {
            context.go('/chat/$matchId', extra: state.match.createdAt);
          }
          if (state is MatchDeleted) {
            context.go('/main/shake');
          }
        },
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: sl<MatchCubit>(),
          builder: (context, state) {
            if (state is MatchLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchFound ||
                state is MatchAcceptancePending ||
                state is MatchAccepted) {
              final currentUid = sl<AuthCubit>().currentUid;
              final match = state is MatchFound
                  ? state.match
                  : state is MatchAcceptancePending
                  ? state.match
                  : (state as MatchAccepted).match;

              final otherUserVibes = match.user1Id == currentUid
                  ? match.user2Vibes
                  : match.user1Vibes;

              return MatchFoundBody(
                matchId: matchId,
                otherUserVibes: otherUserVibes,
                createdAt: match.createdAt,
                isPending: state is MatchAcceptancePending,
              );
            }

            if (state is MatchError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
