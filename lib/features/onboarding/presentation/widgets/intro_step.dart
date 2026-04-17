import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class IntroStep extends StatefulWidget {
  const IntroStep({super.key});

  @override
  State<IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<IntroStep> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPageSeen = false;

  final List<Map<String, String>> _slides = [
    {
      'title': AppStrings.introSlide1Title,
      'description': AppStrings.introSlide1Desc,
      'image': 'assets/images/newmap.png',
    },
    {
      'title': AppStrings.introSlide2Title,
      'description': AppStrings.introSlide2Desc,
      'image': 'assets/images/shake_review.png',
    },
    {
      'title': AppStrings.introSlide3Title,
      'description': AppStrings.introSlide3Desc,
      'image': 'assets/images/profile_review.png',
    },
    {
      'title': AppStrings.introSlide4Title,
      'description': AppStrings.introSlide4Desc,
      'image': 'assets/images/chat_review.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                if (index == _slides.length - 1) {
                  _isLastPageSeen = true;
                }
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 0) ...[
                      Text(
                        slide['title']!,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 48,
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
                        child: Image.asset(slide['image']!, fit: BoxFit.fill),
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
        _buildIndicator(),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: ElevatedButton(
            onPressed: _isLastPageSeen
                ? () => context.read<OnboardingCubit>().finishIntro()
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
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
