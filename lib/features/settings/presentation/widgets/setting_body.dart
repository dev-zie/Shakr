import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsAccountDeleted) {
          context.go('/');
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
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
                title: const Text(
                  AppStrings.deleteAccount,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          AppStrings.deleteAccount,
          style: TextStyle(color: AppColors.error),
        ),
        content: Column(
          mainAxisSize: .min,
          children: [
            Text(AppStrings.deleteAccountConfirm),
            SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondaryDark,
                    ),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<SettingsCubit>().deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text(AppStrings.deleteAccountAction, textAlign: .center,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
