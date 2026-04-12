import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/injection.dart';

class ChatExpiredScreen extends StatefulWidget {
  final String matchId;
  const ChatExpiredScreen({super.key, required this.matchId});

  @override
  State<ChatExpiredScreen> createState() => _ChatExpiredScreenState();
}

class _ChatExpiredScreenState extends State<ChatExpiredScreen> {
  @override
  void initState() {
    super.initState();
    sl<MatchCubit>().getMatch(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: BlocConsumer<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchFound) {
            final otherUserVibes = state.match.user1Id == currentUid
                ? state.match.user2Vibes
                : state.match.user1Vibes;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sure Doldu!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Karsi tarafin vibe\'lari:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: otherUserVibes
                          .map((vibe) => Chip(label: Text(vibe)))
                          .toList(),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        sl<MatchCubit>().keepConnection(
                          widget.matchId,
                          currentUid,
                        );
                        context.go('/home');
                      },
                      child: const Text('Baglantıyı Koru'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Vazgec'),
                    ),
                  ],
                ),
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
