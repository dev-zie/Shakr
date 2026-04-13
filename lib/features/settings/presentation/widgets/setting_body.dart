import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/widgets/save_button.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/constants/app_vibes.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/widgets/vibe_items.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key, required this.selectedVibes});
  final List selectedVibes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectThree,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: AppVibes.categories.entries.length,
              itemBuilder: (context, index) {
                final entry = AppVibes.categories.entries.elementAt(index);
                final category = entry.key;
                final vibes = entry.value;
                return VibeItems(
                  category: category,
                  vibes: vibes,
                  selectedVibes: selectedVibes,
                );
              },
            ),
          ),

          SaveButton(
            text: AppStrings.save,
            onPressed: selectedVibes.length == 3
                ? () => context.read<SettingsCubit>().saveVibes()
                : null, 
          ),
        ],
      ),
    );
  }
}
