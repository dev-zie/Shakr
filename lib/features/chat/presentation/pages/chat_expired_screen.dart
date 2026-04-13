import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/presentation/widgets/chat_expired_body.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
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
  late final MatchCubit _matchCubit;
  @override
  void initState() {
    super.initState();
    _matchCubit = sl<MatchCubit>();

    final currentState = _matchCubit.state;
    if (currentState is! MatchExpired && currentState is! MatchFound) {
      _matchCubit.getMatch(widget.matchId);
    }

    // Match silinince ana ekrana git
    _matchCubit.stream.listen((state) {
      if (!mounted) return;
      if (state is MatchDeleted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = sl<AuthCubit>().currentUid;
    return Scaffold(
      body: BlocConsumer<MatchCubit, MatchState>(
        bloc: _matchCubit,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is MatchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // MatchExpired veya MatchFound — ikisini de handle et
          MatchEntity? match;
          if (state is MatchFound) match = state.match;
          if (state is MatchExpired) match = state.match;

          if (match != null) {
            return ChatExpiredBody(
              match: match,
              matchId: widget.matchId,
              currentUid: currentUid,
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
