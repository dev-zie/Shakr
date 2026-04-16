import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';

class ChatExpiredBody extends StatelessWidget {
  const ChatExpiredBody({
    super.key,
    required this.match,
    required this.matchId,
    required this.currentUid,
  });

  final MatchEntity match;
  final String matchId;
  final String? currentUid;

  @override
  Widget build(BuildContext context) {
    final otherUserVibes = match.user1Id == currentUid
        ? match.user2Vibes
        : match.user1Vibes;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: sl<MatchCubit>(),
          builder: (context, state) {
            final isPending = state is MatchConnectionPending;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPending ? 'Bekleniyor...' : AppStrings.timesUp,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  isPending
                      ? 'Karşı tarafın kararını bekliyoruz.'
                      : AppStrings.otherUsersVibes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                if (!isPending) ...[
                  Wrap(
                    spacing: AppSpacing.s,
                    children: otherUserVibes
                        .map((vibe) => Chip(label: Text(vibe)))
                        .toList(),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                ],
                const SizedBox(height: AppSpacing.xxl),
                if (!isPending) ...[
                  ElevatedButton(
                    onPressed: currentUid == null
                        ? null
                        : () => sl<MatchCubit>().keepConnectionFlow(
                            matchId,
                            currentUid!,
                          ),
                    child: const Text(AppStrings.saveConnect),
                  ),
                ] else ...[
                  const Text('Bağlantı isteği gönderildi.'),
                ],
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () => sl<MatchCubit>().deleteMatch(matchId),
                  child: Text(
                    isPending ? 'Vazgeç' : AppStrings.deleteConnect,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
