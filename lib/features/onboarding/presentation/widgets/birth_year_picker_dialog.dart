import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';

class BirthYearPickerDialog extends StatelessWidget {
  const BirthYearPickerDialog({
    super.key,
    required this.initialYear,
    required this.minYear,
    required this.maxYear,
  });

  final int initialYear;
  final int minYear;
  final int maxYear;

  @override
  Widget build(BuildContext context) {
    final clampedYear = initialYear.clamp(minYear, maxYear);

    return AlertDialog(
      title: const Text(AppStrings.selectAge),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: 280,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(minYear),
          lastDate: DateTime(maxYear),
          selectedDate: DateTime(clampedYear),
          onChanged: (date) => Navigator.pop(context, date.year),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}
