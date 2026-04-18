import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/match/presentation/widgets/match_timer_display.dart';
import 'package:shakr/features/match/presentation/widgets/match_vibe_chips.dart';

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
    final remaining = (AppConstants.matchAcceptanceWindowSeconds - elapsed)
        .clamp(0, AppConstants.matchAcceptanceWindowSeconds)
        .toDouble();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.zap,
                size: AppDimensions.matchFoundIconSize,
                color: AppColors.primary,
              ),
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
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.l),
            MatchVibeChips(vibes: otherUserVibes),
            const SizedBox(height: AppSpacing.xxl),
            MatchTimerDisplay(
              remainingSeconds: remaining,
              totalSeconds: AppConstants.matchAcceptanceWindowSeconds.toDouble(),
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
                child: const Text(AppStrings.cancel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
