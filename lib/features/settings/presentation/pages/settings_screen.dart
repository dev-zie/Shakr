import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/widgets/setting_body.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const SettingsBody(),
      ),
    );
  }
}
