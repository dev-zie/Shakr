import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/injection.dart';

class ChatExpiredBody extends StatelessWidget {
  final MatchEntity match;
  final String matchId;
  final String? currentUid;

  const ChatExpiredBody({
    super.key,
    required this.match,
    required this.matchId,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserVibes = match.user1Id == currentUid
        ? match.user2Vibes
        : match.user1Vibes;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.timesUp,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.otherUsersVibes,
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
              onPressed: () async {
                // 1. Kendi tarafını işaretle
                await sl<MatchCubit>().keepConnection(matchId, currentUid!);

                // 2. Diğer kişinin basıp basmadığını kontrol et
                final bothKept = await sl<MatchCubit>().checkBothKeptConnection(
                  matchId,
                );

                if (context.mounted) {
                  if (bothKept) {
                    // İKİSİ DE KORUDU
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.connectSucces)),
                    );
                    // Biraz bekle ki mesaj okunsun
                    await Future.delayed(const Duration(seconds: 3));
                    sl<MatchCubit>().deleteMatch(matchId); // Temizlik
                  } else {
                    // HENÜZ DİĞERİ BASMADI VEYA VAZGEÇTİ
                    // Burada silmiyoruz, kullanıcıya "Diğer kullanıcı bekleniyor..." diyebilirsin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.waitingOtherDecide),
                      ),
                    );
                  }
                }
              },
              child: const Text(AppStrings.saveConnect),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                sl<MatchCubit>().deleteMatch(matchId);
                context.go('/home');
              },
              child: const Text(AppStrings.deleteConnect),
            ),
          ],
        ),
      ),
    );
  }
}
