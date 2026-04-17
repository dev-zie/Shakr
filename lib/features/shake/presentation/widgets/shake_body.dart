import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_assets.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShakeBody extends StatelessWidget {
  const ShakeBody({super.key});

  static const String _lottieUrl =
      'https://lottie.host/91e88218-dc91-494b-9bcf-86b843d1103c/KSGJz5mHcS.json';
  static const String _emulatorButtonLabel = 'Emülätör: Sallanmayı Simüle Et';

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .8,
              child: Image.asset(AppAssets.mapBackground, fit: BoxFit.cover),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                _lottieUrl,
                width: 300,
                height: 300,
                frameRate: FrameRate(120),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                AppStrings.shakeString,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                AppStrings.shakeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextButton.icon(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                  final locationResult =
                      await sl<LocationService>().getCurrentLocation();
                  final shake = ShakeEntity(
                    uid: uid,
                    location: locationResult.location,
                    status: ShakeStatus.waiting,
                    timestamp: DateTime.now(),
                  );
                  sl<ShakeCubit>().recordShake(
                    shake,
                    isFallback: locationResult.isFallback,
                  );
                },
                icon: const Icon(LucideIcons.mousePointer2, size: 16),
                label: const Text(_emulatorButtonLabel),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
