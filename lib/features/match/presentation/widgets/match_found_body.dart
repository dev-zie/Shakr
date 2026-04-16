import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

class MatchFoundBody extends StatelessWidget {
  const MatchFoundBody({
    super.key,
    required this.otherUserVibes,
    required this.matchId,
    required this.createdAt,
    this.isPending = false,
  });

  final List<String> otherUserVibes;
  final String matchId;
  final DateTime createdAt;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    final remaining = (15 - elapsed).clamp(0, 15).toDouble();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.matchFound,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              AppStrings.otherUsersVibes,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              alignment: WrapAlignment.center,
              children: otherUserVibes
                  .map(
                    (vibe) => Chip(
                      label: Text(vibe),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: remaining, end: 0.0),
              duration: Duration(seconds: remaining.toInt()),
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: value / 15.0,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    Text(
                      '${value.ceil()}',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (isPending) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.m),
              const Text(
                AppStrings.waitDecision,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  final uid = sl<AuthCubit>().currentUid;
                  if (uid != null) {
                    sl<MatchCubit>().acceptMatch(matchId, uid);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.m),
                  ),
                ),
                child: const Text(AppStrings.startChat),
              ),
              const SizedBox(height: AppSpacing.m),
              TextButton(
                onPressed: () => sl<MatchCubit>().deleteMatch(matchId),
                child: Text(
                  AppStrings.cancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
