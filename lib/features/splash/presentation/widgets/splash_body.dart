import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_assets.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
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
          Lottie.network(
            AppAssets.splashLottieUrl,
            width: AppDimensions.splashLottieSize,
            height: AppDimensions.splashLottieSize,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
