import 'package:flutter/material.dart';
import 'package:shakr/common/theme/app_colors.dart';

class RadarPainter extends CustomPainter {
  final double progress;

  const RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final currentProgress = (progress + (i / 3)) % 1.0;
      final radius = (size.width / 2) * currentProgress;
      paint.color = AppColors.primary.withValues(alpha: 1.0 - currentProgress);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
