import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/onboarding/presentation/widgets/age_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/gender_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/name_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/photo_step.dart';
import 'package:shakr/features/onboarding/presentation/widgets/vibe_step.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingCubit>()..start(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            context.replace('/main/shake');
          }
          if (state is OnboardingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is! OnboardingStepChanged) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              leading: state.step > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.read<OnboardingCubit>().goBack(),
                    )
                  : null,
            ),
            body: switch (state.step) {
              0 => const NameStep(),
              1 => const PhotoStep(),
              2 => const AgeStep(),
              3 => const GenderStep(),
              4 => const VibeStep(),
              _ => const SizedBox(),
            },
          );
        },
      ),
    );
  }
}
