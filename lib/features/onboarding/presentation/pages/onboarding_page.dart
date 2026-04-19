import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/features/onboarding/presentation/widgets/onboarding_body.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingCubit>()..start(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.completed) {
            context.replace('/main/shake');
          }
          if (state.status == OnboardingStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? '')));
          }
        },
        builder: (context, state) {
          if (state.status != OnboardingStatus.stepChanged) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              leading: state.step > 0
                  ? IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      onPressed: () => context.read<OnboardingCubit>().goBack(),
                    )
                  : null,
            ),
            body: OnboardingBody(state: state),
          );
        },
      ),
    );
  }
}
