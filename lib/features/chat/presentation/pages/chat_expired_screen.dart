import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

    // Sayfa açıldığında eğer Match bilgisi yoksa çek (initState yerine build başında kontrol)
    final currentState = matchCubit.state;
    if (currentState is! MatchExpired && currentState is! MatchFound) {
      matchCubit.getMatch(matchId);
    }

    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: matchCubit,
        // Navigasyon işlemlerini (ekran değiştirme) listener içinde yapıyoruz
        listener: (context, state) {
          if (state is MatchDeleted) {
            context.go('/home');
          }
        },
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: matchCubit,
          builder: (context, state) {
            if (state is MatchLoading) {
              return const Center(child: CircularProgressIndicator());
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