import 'package:flutter/material.dart';
import 'package:shakr/common/theme/app_colors.dart';

class MatchTimerDisplay extends StatelessWidget {
  final double remainingSeconds;
  final double totalSeconds;

  const MatchTimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: remainingSeconds, end: 0.0),
      duration: Duration(seconds: remainingSeconds.toInt()),
      builder: (context, value, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: value / totalSeconds,
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
    );
  }
}
