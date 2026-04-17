import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final bool notificationsEnabled = state is SettingsLoaded
            ? state.notificationsEnabled
            : true;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            SwitchListTile(
              title: const Text(AppStrings.notifications),
              subtitle: const Text(AppStrings.notificationsDesc),
              value: notificationsEnabled,
              onChanged: (val) {
                context.read<SettingsCubit>().toggleNotifications(val);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.fileText),
              title: const Text(AppStrings.termsofservice),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.shieldCheck),
              title: const Text(AppStrings.privacypolicy),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(LucideIcons.star),
              title: const Text(AppStrings.rateus),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: AppColors.error),
              title: Text(
                AppStrings.deleteAccount,
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => _showDeleteDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppStrings.deleteAccount,
          style: const TextStyle(color: AppColors.error),
        ),
        content: const Text(AppStrings.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await sl<DeleteAccountUsecase>().call();
              sl<LocalStorageService>().resetOnboarding();
              result.fold((_) {}, (_) {
                if (context.mounted) context.go('/');
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.deleteAccountAction),
          ),
        ],
      ),
    );
  }
}
