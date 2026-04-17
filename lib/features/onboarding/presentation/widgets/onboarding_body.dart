import 'package:flutter/material.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/onboarding/presentation/widgets/age_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/gender_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/name_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/photo_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/vibe_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/intro_step.dart';

class OnboardingBody extends StatelessWidget {
  final OnboardingStepChanged state;

  const OnboardingBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.step) {
      0 => const IntroStep(),
      1 => const NameStep(),
      2 => const PhotoStep(),
      3 => const AgeStep(),
      4 => const GenderStep(),
      5 => const VibeStep(),
      _ => const SizedBox(),
    };
  }
}
