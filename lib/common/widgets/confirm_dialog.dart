import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(title: title, content: content),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(AppStrings.okay),
        ),
      ],
    );
  }
}
