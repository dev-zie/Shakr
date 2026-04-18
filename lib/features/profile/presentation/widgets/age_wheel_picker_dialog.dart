import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/constants/app_dimensions.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_text_sizes.dart';
import 'package:shakr/common/theme/app_colors.dart';

class AgeWheelPickerDialog extends StatefulWidget {
  final int initialAge;

  const AgeWheelPickerDialog({super.key, required this.initialAge});

  @override
  State<AgeWheelPickerDialog> createState() => _AgeWheelPickerDialogState();
}

class _AgeWheelPickerDialogState extends State<AgeWheelPickerDialog> {
  late int _selectedAge;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.initialAge.clamp(
      AppConstants.minUserAge,
      AppConstants.maxUserAge,
    );
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedAge - AppConstants.minUserAge,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              scrollController: _scrollController,
              itemExtent: AppDimensions.ageWheelPickerItemExtent,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedAge = AppConstants.minUserAge + index;
                });
              },
              children: List.generate(
                AppConstants.maxUserAge - AppConstants.minUserAge + 1,
                (index) {
                  final age = AppConstants.minUserAge + index;
                  final isSelected = age == _selectedAge;
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedAge),
          child: const Text(AppStrings.okay),
        ),
      ],
    );
  }
}
