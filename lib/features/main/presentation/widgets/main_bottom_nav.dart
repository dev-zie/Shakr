import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return BottomNavigationBar(
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.vibration),
              label: AppStrings.tabShake,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: AppStrings.tabChats,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppStrings.tabProfile,
            ),
          ],
        );
      },
    );
  }
}
