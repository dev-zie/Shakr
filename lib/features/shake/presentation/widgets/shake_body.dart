import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShakeBody extends StatelessWidget {
  const ShakeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Map covering the entire area
          Positioned.fill(
            child: Opacity(
              opacity: .8, // lowered opacity for better text contrast
              child: Image.asset('assets/images/newmap.png', fit: BoxFit.cover),
            ),
          ),
          // Content layer
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/91e88218-dc91-494b-9bcf-86b843d1103c/KSGJz5mHcS.json',
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
                'Eşleşmek için telefonunu salla!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Emulator simulation button
              TextButton.icon(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;
                  final location = await sl<LocationService>()
                      .getCurrentLocation();
                  final shake = ShakeEntity(
                    uid: uid,
                    location: location,
                    status: ShakeStatus.waiting,
                    timestamp: DateTime.now(),
                  );
                  sl<ShakeCubit>().recordShake(shake);
                },
                icon: const Icon(LucideIcons.mousePointer2, size: 16),
                label: const Text('Emülatör: Sallanmayı Simüle Et'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
