import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/theme/app_shadows.dart';
import 'package:shakr/features/shake/presentation/widgets/radar_painter.dart';

class ShakeBody extends StatelessWidget {
  const ShakeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: sl<ShakeCubit>().radarProgress,
                  builder: (context, progress, _) {
                    return CustomPaint(
                      painter: RadarPainter(progress),
                      size: const Size(300, 300),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.primary,
                  ),
                  child: const Icon(
                    LucideIcons.vibrate,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            AppStrings.shakeString,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Eşleşmek için telefonunu salla!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextButton.icon(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              final location =
                  await sl<LocationService>().getCurrentLocation();
              final shake = ShakeEntity(
                uid: uid,
                location: location,
                status: ShakeStatus.waiting,
                timestamp: DateTime.now(),
              );
              sl<ShakeCubit>().recordShake(shake);
            },
            icon: const Icon(LucideIcons.mousePointer2, size: 16),
            label: const Text('Emulator: Sallanmayı Simüle Et'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

