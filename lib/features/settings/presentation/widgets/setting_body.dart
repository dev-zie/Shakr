import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final bool notificationsEnabled =
            state is SettingsLoaded ? state.notificationsEnabled : true;

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
          ],
        );
      },
    );
  }
}
