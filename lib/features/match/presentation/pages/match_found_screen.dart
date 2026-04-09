import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/injection.dart';

class MatchFoundScreen extends StatefulWidget {
  final String matchId;
  const MatchFoundScreen({super.key, required this.matchId});

  @override
  State<MatchFoundScreen> createState() => _MatchFoundScreenState();
}

class _MatchFoundScreenState extends State<MatchFoundScreen> {
  @override
  void initState() {
    super.initState();
    sl<MatchCubit>().getMatch(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchFound) {
            final currentUid = FirebaseAuth.instance.currentUser?.uid;
            final otherUserVibes = state.match.user1Id == currentUid
                ? state.match.user2Vibes
                : state.match.user1Vibes;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Esleme Bulundu!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: otherUserVibes
                        .map((vibe) => Chip(label: Text(vibe)))
                        .toList(),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => context.go('/chat/${widget.matchId}'),
                    child: const Text('Sohbete Basla'),
                  ),
                ],
              ),
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
