import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_state.dart';

class AgeStep extends StatelessWidget {
  const AgeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final currentAge = (state is OnboardingStepChanged)
            ? (state.age ?? 20)
            : 20;

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
              const Expanded(child: SizedBox()),
              SizedBox(
                height: AppDimensions.agePickerHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: AppDimensions.agePickerItemExtent,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusM,
                        ),
                      ),
                    ),
                    CupertinoPicker(
                      scrollController: cubit.ageScrollController,
                      itemExtent: AppDimensions.agePickerItemExtent,
                      onSelectedItemChanged: (index) {
                        cubit.updateAge(AppConstants.minUserAge + index);
                      },
                      children: List.generate(
                        AppConstants.maxUserAge - AppConstants.minUserAge + 1,
                        (index) {
                          final age = AppConstants.minUserAge + index;
                          final isSelected = age == currentAge;
                          return Center(
                            child: Text(
                              age.toString(),
                              style: TextStyle(
                                fontSize: isSelected
                                    ? AppTextSizes.agePickerSelected
                                    : AppTextSizes.agePickerUnselected,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              ElevatedButton(
                onPressed: () => cubit.setAge(currentAge),
                child: const Text(AppStrings.continueButton),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}
