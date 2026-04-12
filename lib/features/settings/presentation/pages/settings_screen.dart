import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/core/constants/app_vibes.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_state.dart';
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
            appBar: AppBar(title: const Text('Vibe\'ini Degistir')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 vibe sec',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: AppVibes.categories.entries.length,
                      itemBuilder: (context, index) {
                        final entry = AppVibes.categories.entries.elementAt(
                          index,
                        );
                        final kategori = entry.key;
                        final vibeler = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kategori,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vibeler.map((vibe) {
                                final isSelected = selectedVibes.contains(vibe);
                                return FilterChip(
                                  label: Text(vibe),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      context.read<SettingsCubit>().selectVibe(
                                        vibe,
                                      );
                                    } else {
                                      context
                                          .read<SettingsCubit>()
                                          .deselectVibe(vibe);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: selectedVibes.length == 3
                        ? () => context.read<SettingsCubit>().saveVibes()
                        : null,
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
