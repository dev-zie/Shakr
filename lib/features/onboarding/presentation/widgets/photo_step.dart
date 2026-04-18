import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            AppStrings.peopleSee,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final photoUrl =
                  state is OnboardingStepChanged ? state.photoUrl : null;
              return GestureDetector(
                onTap: () => context.read<OnboardingCubit>().pickPhoto(),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: AppDimensions.photoAvatarSize,
                      height: AppDimensions.photoAvatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        image: photoUrl != null
                            ? DecorationImage(
                                image: photoUrl.startsWith('http')
                                    ? NetworkImage(photoUrl) as ImageProvider
                                    : FileImage(File(photoUrl)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl == null
                          ? const Icon(
                              LucideIcons.user,
                              size: AppDimensions.photoAvatarPlaceholderIconSize,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: AppDimensions.cameraIconSize,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: () => context.read<OnboardingCubit>().setPhoto(),
            child: const Text(AppStrings.continueButton),
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton(
            onPressed: () => context.read<OnboardingCubit>().setPhoto(),
            child: Text(
              AppStrings.skipForNow,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
