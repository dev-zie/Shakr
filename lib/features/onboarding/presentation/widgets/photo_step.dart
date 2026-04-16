import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class PhotoStep extends StatelessWidget {
  const PhotoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.uploadYourPhoto,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            AppStrings.peopleSee,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final photoUrl = state is OnboardingStepChanged
                  ? state.photoUrl
                  : null;
              return GestureDetector(
                onTap: () => context.read<OnboardingCubit>().pickPhoto(),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: photoUrl != null
                      ? FileImage(File(photoUrl))
                      : null,
                  child: photoUrl == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () => context.read<OnboardingCubit>().setPhoto(),
            child: const Text(AppStrings.continueButton),
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton(
            onPressed: () => context.read<OnboardingCubit>().setPhoto(),
            child: const Text(AppStrings.skipForNow),
          ),
        ],
      ),
    );
  }
}
