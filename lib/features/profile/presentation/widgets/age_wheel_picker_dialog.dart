import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';

class AgeWheelPickerDialog extends StatefulWidget {
  final int initialAge;

  const AgeWheelPickerDialog({super.key, required this.initialAge});

  @override
  State<AgeWheelPickerDialog> createState() => _AgeWheelPickerDialogState();
}

class _AgeWheelPickerDialogState extends State<AgeWheelPickerDialog> {
  late int _selectedAge;
  static const int _minAge = 18;
  static const int _maxAge = 99;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.initialAge.clamp(_minAge, _maxAge);
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedAge - _minAge,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      content: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            CupertinoPicker(
              scrollController: _scrollController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedAge = _minAge + index;
                });
              },
              children: List.generate(_maxAge - _minAge + 1, (index) {
                final age = _minAge + index;
                final isSelected = age == _selectedAge;
                return Center(
                  child: Text(
                    age.toString(),
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.grey,
                    ),
                  ),
                );
              }),
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
