import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_assets.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class IntroStep extends StatelessWidget {
  const IntroStep({super.key});

  static const List<Map<String, String>> _slides = [
    {
      'title': AppStrings.introSlide1Title,
      'description': AppStrings.introSlide1Desc,
      'image': AppAssets.mapBackground,
    },
    {
      'title': AppStrings.introSlide2Title,
      'description': AppStrings.introSlide2Desc,
      'image': AppAssets.shakeReview,
    },
    {
      'title': AppStrings.introSlide3Title,
      'description': AppStrings.introSlide3Desc,
      'image': AppAssets.profileReview,
    },
    {
      'title': AppStrings.introSlide4Title,
      'description': AppStrings.introSlide4Desc,
      'image': AppAssets.chatReview,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (prev, curr) =>
          prev.introPage != curr.introPage ||
          prev.introLastPageSeen != curr.introLastPageSeen,
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: cubit.pageController,
                onPageChanged: (index) =>
                    cubit.onIntroPageChanged(index, _slides.length),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (index == 0) ...[
                          Text(
                            slide['title']!,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: AppTextSizes.introTitle,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                        ],
                        Expanded(
                          flex: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusXL,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              slide['image']!,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          index == 0 ? '' : slide['title']!,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          slide['description']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildIndicator(context, state.introPage),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: ElevatedButton(
                onPressed: state.introLastPageSeen
                    ? () => cubit.finishIntro()
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
                child: const Text(AppStrings.introLetCreateAccount),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(
            milliseconds: AppConstants.animationDurationMedium,
          ),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
          height: AppDimensions.indicatorHeight,
          width: currentPage == index
              ? AppDimensions.indicatorActiveWidth
              : AppDimensions.indicatorInactiveWidth,
          decoration: BoxDecoration(
            color: currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.indicatorHeight),
          ),
        ),
      ),
    );
  }
}
