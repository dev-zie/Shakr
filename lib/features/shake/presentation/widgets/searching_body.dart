import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';

class SearchingBody extends StatelessWidget {
  const SearchingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            width: 250,
            child: Lottie.network(
              'https://assets9.lottiefiles.com/private_files/lf30_j1gztz3q.json', // Radar animation
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 4),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            AppStrings.searchingText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }
}
