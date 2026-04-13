import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';
import 'package:shakr/features/settings/presentation/widgets/setting_body.dart';
import 'package:shakr/injection.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsCubit>()..loadVibes(),
      child: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSaved) {
            context.go('/home');
          }
          if (state is SettingsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final selectedVibes = state is SettingsLoaded
              ? state.selectedVibes
              : <String>[];

          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.changeVibe)),
            body: SettingsBody(selectedVibes: selectedVibes),
          );
        },
      ),
    );
  }
}
