import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/match/presentation/widgets/match_vibe_chips.dart';
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
        child: BlocBuilder<MatchCubit, MatchState>(
          bloc: sl<MatchCubit>(),
          builder: (context, state) {
            final isPending =
                state.status == MatchCubitStatus.connectionPending;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? LucideIcons.clock : LucideIcons.heartHandshake,
                    size: AppDimensions.emptyChatIconSize,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  isPending
                      ? AppStrings.waitingOtherDecide
                      : AppStrings.timesUp,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  isPending
                      ? AppStrings.waitingConnectionRequest
                      : AppStrings.otherUsersVibes,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m),
                if (!isPending)
                  MatchVibeChips(vibes: otherUserVibes)
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.xxl),
                if (!isPending) ...[
                  ElevatedButton.icon(
                    onPressed: currentUid == null
                        ? null
                        : () => sl<MatchCubit>().keepConnectionFlow(
                            matchId,
                            currentUid!,
                          ),
                    icon: const Icon(LucideIcons.heart, size: 18),
                    label: const Text(AppStrings.saveConnect),
                  ),
                ] else ...[
                  Text(
                    AppStrings.connectionRequestSent,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                  ),
                ],
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () => sl<MatchCubit>().deleteMatch(matchId),
                  child: Text(
                    isPending ? AppStrings.cancel : AppStrings.deleteConnect,
                    style: const TextStyle(
                      fontSize: AppTextSizes.connectButton,
                      fontWeight: FontWeight.w500,
                    ),
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
