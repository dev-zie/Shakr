import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/match/presentation/widgets/match_found_body.dart';
import 'package:shakr/common/getit/injection.dart';

class MatchFoundPage extends StatelessWidget {
  final String matchId;

  const MatchFoundPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state.status == MatchCubitStatus.accepted) {
            context.go('/chat/$matchId', extra: state.match!.createdAt);
          }
          if (state.status == MatchCubitStatus.deleted) {
            context.go('/main/shake');
          }
        },
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: sl<MatchCubit>(),
          builder: (context, state) {
            if (state.status == MatchCubitStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == MatchCubitStatus.found ||
                state.status == MatchCubitStatus.acceptancePending ||
                state.status == MatchCubitStatus.accepted) {
              final currentUid = sl<AuthCubit>().currentUid;
              final match = state.match!;
              final otherUserVibes = match.user1Id == currentUid
                  ? match.user2Vibes
                  : match.user1Vibes;

              return MatchFoundBody(
                matchId: matchId,
                otherUserVibes: otherUserVibes,
                createdAt: match.createdAt,
                isPending: state.status == MatchCubitStatus.acceptancePending,
              );
            }

            if (state.status == MatchCubitStatus.error) {
              return Center(child: Text(state.errorMessage ?? ''));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
