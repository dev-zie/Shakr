import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_radius.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/media_service.dart';

enum _CameraAction { use, retake }

Future<String?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<String?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => PhotoSourceSheet(parentContext: context),
  );
}

class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key, required this.parentContext});
  final BuildContext parentContext;

  Future<void> _handleCamera(BuildContext sheetContext) async {
    while (true) {
      final path = await sl<MediaService>().pickFromCamera();
      if (path == null) {
        if (sheetContext.mounted) Navigator.pop(sheetContext, null);
        return;
      }
      if (!sheetContext.mounted) return;
      final action = await showModalBottomSheet<_CameraAction>(
        context: sheetContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        builder: (_) => _CameraConfirmSheet(imagePath: path),
      );
      if (action == _CameraAction.use) {
        if (sheetContext.mounted) Navigator.pop(sheetContext, path);
        return;
      } else if (action == _CameraAction.retake) {
        continue;
      } else {
        if (sheetContext.mounted) Navigator.pop(sheetContext, null);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            Text(
              AppStrings.photoSourceTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () async {
                final path = await sl<MediaService>().pickFromGallery();
                if (context.mounted) Navigator.pop(context, path);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text(AppStrings.openCamera),
              onTap: () => _handleCamera(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraConfirmSheet extends StatelessWidget {
  const _CameraConfirmSheet({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.l),
              child: Image.file(
                File(imagePath),
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _CameraAction.use),
                child: const Text(AppStrings.useThisPhoto),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, _CameraAction.retake),
                child: const Text(AppStrings.retakePhoto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
