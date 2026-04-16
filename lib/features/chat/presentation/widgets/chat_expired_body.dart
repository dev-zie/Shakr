import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.timesUp,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              AppStrings.otherUsersVibes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              children: otherUserVibes
                  .map((vibe) => Chip(label: Text(vibe)))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: currentUid == null
                  ? null
                  : () => sl<MatchCubit>().keepConnectionFlow(matchId, currentUid!),
              child: const Text(AppStrings.saveConnect),
            ),
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(
              onPressed: () => sl<MatchCubit>().deleteMatch(matchId),
              child: const Text(AppStrings.deleteConnect),
            ),
          ],
        ),
      ),
    );
  }
}
