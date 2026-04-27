import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_enums.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/common/theme/theme_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';
import 'package:shakr/features/settings/presentation/widgets/settings_body_actions_mixin.dart';

class SettingsBody extends StatelessWidget with SettingsBodyActions {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.accountDeleted) {
          context.go('/');
        } else if (state.status == SettingsStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? '')));
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) => SwitchListTile(
                  title: const Text(AppStrings.darkMode),
                  subtitle: const Text(AppStrings.darkModeDesc),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) => context.read<ThemeCubit>().toggle(val),
                ),
              ),
              SwitchListTile(
                title: const Text(AppStrings.notifications),
                subtitle: const Text(AppStrings.notificationsDesc),
                value: state.notificationsEnabled,
                onChanged: (val) {
                  context.read<SettingsCubit>().toggleNotifications(val);
                },
              ),
              ListTile(
                title: const Text(AppStrings.shakeSensitivity),
                subtitle: const Text(AppStrings.shakeSensitivityDesc),
                trailing: DropdownButton<ShakeSensitivity>(
                  value: state.shakeSensitivity,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: ShakeSensitivity.hassas,
                      child: Text(AppStrings.sensitivityHassas),
                    ),
                    DropdownMenuItem(
                      value: ShakeSensitivity.normal,
                      child: Text(AppStrings.sensitivityNormal),
                    ),
                    DropdownMenuItem(
                      value: ShakeSensitivity.sert,
                      child: Text(AppStrings.sensitivitySert),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      context.read<SettingsCubit>().setSensitivity(val);
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(LucideIcons.fileText),
                title: const Text(AppStrings.termsofservice),
                onTap: () => showTermsDialog(context),
              ),
              ListTile(
                leading: const Icon(LucideIcons.shieldCheck),
                title: const Text(AppStrings.privacypolicy),
                onTap: () => showPrivacyDialog(context),
              ),
              ListTile(
                leading: const Icon(LucideIcons.star),
                title: const Text(AppStrings.rateus),
                onTap: openAppStore,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppColors.error),
                title: const Text(
                  AppStrings.deleteAccount,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => showDeleteDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
