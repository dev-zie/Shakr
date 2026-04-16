import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';

class SplashBody extends StatelessWidget {
  const SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.m),
          // Lottie Animation for a modern look
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_x62chJ.json',
            width: 150,
            height: 150,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator(); // Fallback
            },
          ),
        ],
      ),
    );
  }
}
