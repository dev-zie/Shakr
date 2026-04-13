import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/widgets/save_button.dart';
import 'package:shakr/core/constants/app_strings.dart';
import 'package:shakr/core/constants/app_vibes.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/widgets/vibes_item.dart';

class OnboardingBody extends StatelessWidget {
  const OnboardingBody({super.key, required this.selectedVibes});
  final List<String> selectedVibes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.onboardingTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.onboardingSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        Expanded(
          child: ListView.builder(
            itemCount: AppVibes.categories.length,
            itemBuilder: (context, index) {
              final entry = AppVibes.categories.entries.elementAt(index);
              final category = entry.key;
              final vibes = entry.value;
              return VibesItem(
                category: category,
                vibes: vibes,
                selectedVibes: selectedVibes,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SaveButton(
          onPressed: selectedVibes.length == 3
              ? () => context.read<OnboardingCubit>().saveVibes()
              : null, // null ise buton disabled
          text: AppStrings.continueButton,
        ),
      ],
    );
  }
}
