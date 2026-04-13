import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/match/presentation/widgets/match_found_body.dart';
import 'package:shakr/injection.dart';

class MatchFoundScreen extends StatelessWidget {
  final String matchId;
  
  const MatchFoundScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchFound) {
            final currentUid = sl<AuthCubit>().currentUid;
            final otherUserVibes = state.match.user1Id == currentUid
                ? state.match.user2Vibes
                : state.match.user1Vibes;

            return MatchFoundBody(
              matchId: matchId,
              otherUserVibes: otherUserVibes,
              createdAt: state.match.createdAt,
            );
          }

          if (state is MatchError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}