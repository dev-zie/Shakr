import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/theme/app_colors.dart';

class SearchingBody extends StatelessWidget {
  const SearchingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Map covering the entire area (Identical to ShakeBody)
          Positioned.fill(
            child: Opacity(
              opacity: .8,
              child: Image.asset('assets/images/newmap.png', fit: BoxFit.cover),
            ),
          ),
          // Content layer
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppSpacing.l),
              SizedBox(
                height: 250,
                width: 250,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                  child: Lottie.network(
                    'https://lottie.host/07fe1e8a-82b7-43d2-8fb9-97c946a5a34b/2k0o3AGNz7.json',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  AppStrings.searchingText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
