import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';
import 'package:shakr/common/theme/app_shadows.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Container(
          height: 100,
          decoration: BoxDecoration(boxShadow: AppShadows.upward),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              final cubit = context.read<NavigationCubit>();
              switch (index) {
                case 0:
                  cubit.goToShake();
                case 1:
                  cubit.goToChats();
                case 2:
                  cubit.goToProfile();
              }
            },
            iconSize: 18,
            selectedFontSize: 12,
            unselectedFontSize: 8,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Icon(LucideIcons.radar),
                ),
                label: AppStrings.tabShake,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Icon(LucideIcons.messageCircle),
                ),
                label: AppStrings.tabChats,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Icon(LucideIcons.user),
                ),
                label: AppStrings.tabProfile,
              ),
            ],
          ),
        );
      },
    );
  }
}
