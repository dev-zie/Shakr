import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.zap, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              AppStrings.matchFound,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              AppStrings.otherUsersVibes,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              alignment: WrapAlignment.center,
              children: otherUserVibes.map((vibe) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    vibe,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
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
                        color: AppColors.primary,
                        backgroundColor: AppColors.primary100,
                      ),
                    ),
                    Text(
                      '${value.ceil()}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (isPending) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.m),
              Text(
                AppStrings.waitDecision,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () {
                  final uid = sl<AuthCubit>().currentUid;
                  if (uid != null) {
                    sl<MatchCubit>().acceptMatch(matchId, uid);
                  }
                },
                icon: const Icon(LucideIcons.messageCircle, size: 18),
                label: const Text(AppStrings.startChat),
              ),
              const SizedBox(height: AppSpacing.m),
              TextButton(
                onPressed: () => sl<MatchCubit>().deleteMatch(matchId),
                child: Text(
                  AppStrings.cancel,
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

