import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_state.dart';

class AgeWheelPickerDialog extends StatelessWidget {
  const AgeWheelPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) => prev.pickerAge != curr.pickerAge,
      builder: (context, state) {
        return AlertDialog(
          title: const Text(AppStrings.howOldAreYou),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          content: SizedBox(
            height: AppDimensions.ageWheelPickerHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: AppDimensions.ageWheelPickerItemExtent,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                ),
                CupertinoPicker(
                  scrollController: cubit.ageScrollController,
                  itemExtent: AppDimensions.ageWheelPickerItemExtent,
                  onSelectedItemChanged: (index) =>
                      cubit.updatePickerAge(AppConstants.minUserAge + index),
                  children: List.generate(
                    AppConstants.maxUserAge - AppConstants.minUserAge + 1,
                    (index) {
                      final age = AppConstants.minUserAge + index;
                      final isSelected = age == state.pickerAge;
                      return Center(
                        child: Text(
                          age.toString(),
                          style: TextStyle(
                            fontSize: isSelected
                                ? AppTextSizes.ageWheelSelected
                                : AppTextSizes.ageWheelUnselected,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).textTheme.bodySmall?.color
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, state.pickerAge),
              child: const Text(AppStrings.okay),
            ),
          ],
        );
      },
    );
  }
}
