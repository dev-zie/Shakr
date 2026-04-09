import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/core/constants/app_strings.dart';
import 'package:shakr/core/constants/app_vibes.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:shakr/injection.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingCubit>(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          final selectedVibes = state is OnboardingVibeSelected
              ? state.selectedVibes
              : <String>[];

          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
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
                          final entry = AppVibes.categories.entries.elementAt(
                            index,
                          );
                          final kategori = entry.key;
                          final vibeler = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kategori,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: vibeler.map((vibe) {
                                  final isSelected = selectedVibes.contains(
                                    vibe,
                                  );
                                  return FilterChip(
                                    label: Text(vibe),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        context
                                            .read<OnboardingCubit>()
                                            .selectVibe(vibe);
                                      } else {
                                        context
                                            .read<OnboardingCubit>()
                                            .deselectVibe(vibe);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selectedVibes.length == 3
                          ? () => context.read<OnboardingCubit>().saveVibes()
                          : null, // null ise buton disabled
                      child: Text(AppStrings.continueButton),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
