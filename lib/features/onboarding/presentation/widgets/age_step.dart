import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class AgeStep extends StatefulWidget {
  const AgeStep({super.key});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  late FixedExtentScrollController _controller;
  final int minAge = 18;
  final int maxAge = 99;
  late int selectedAge;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingCubit>().state;
    selectedAge = (state is OnboardingStepChanged) ? (state.age ?? 20) : 20;
    _controller = FixedExtentScrollController(initialItem: selectedAge - minAge);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.howOldAreYou,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Doğum yılın otomatik hesaplanacaktır.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan çizgileri veya vurgu
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                CupertinoPicker(
                  scrollController: _controller,
                  itemExtent: 50,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedAge = minAge + index;
                    });
                  },
                  children: List.generate(maxAge - minAge + 1, (index) {
                    final age = minAge + index;
                    final isSelected = age == selectedAge;
                    return Center(
                      child: Text(
                        age.toString(),
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 24,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OnboardingCubit>().setAge(selectedAge);
            },
            child: const Text(AppStrings.continueButton),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
