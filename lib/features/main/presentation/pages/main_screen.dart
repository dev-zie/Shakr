import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';
import 'package:shakr/features/main/presentation/widgets/main_bottom_nav.dart';
import 'package:shakr/features/profile/presentation/pages/profile_screen.dart';
import 'package:shakr/features/chat/presentation/pages/my_chats_screen.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_screen.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit()..emit(initialIndex),
      child: BlocListener<NavigationCubit, int>(
        listener: (context, index) {
          if (index == 0) {
            sl<ShakeCubit>().init();
          } else {
            sl<ShakeCubit>().disposeScreen();
          }
        },
        child: Scaffold(
          body: BlocBuilder<NavigationCubit, int>(
            builder: (context, index) {
              return IndexedStack(
                index: index,
                children: const [
                  ShakingScreen(),
                  MyChatsScreen(),
                  ProfileScreen(),
                ],
              );
            },
          ),
          bottomNavigationBar: const MainBottomNav(),
        ),
      ),
    );
  }
}
