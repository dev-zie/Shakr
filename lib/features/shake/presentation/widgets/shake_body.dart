import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/common/theme/app_colors.dart';

class ShakeBody extends StatefulWidget {
  const ShakeBody({super.key});

  @override
  State<ShakeBody> createState() => _ShakeBodyState();
}

class _ShakeBodyState extends State<ShakeBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                // Radar Animasyonu
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RadarPainter(_controller.value),
                      size: const Size(300, 300),
                    );
                  },
                ),
                // Merkez İkon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.vibration,
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Eşleşmek için telefonunu salla!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.xxl),
          TextButton.icon(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              final location = await sl<LocationService>().getCurrentLocation();
              final shake = ShakeEntity(
                uid: uid,
                location: location,
                status: ShakeStatus.waiting,
                timestamp: DateTime.now(),
              );
              sl<ShakeCubit>().recordShake(shake);
            },
            icon: const Icon(Icons.touch_app, size: 16),
            label: const Text('Emulator: Sallanmayı Simüle Et'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 3 adet halka
    for (int i = 0; i < 3; i++) {
      final currentProgress = (progress + (i / 3)) % 1.0;
      final radius = (size.width / 2) * currentProgress;
      paint.color = AppColors.primary.withOpacity(1.0 - currentProgress);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
