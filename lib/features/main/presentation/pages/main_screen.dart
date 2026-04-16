import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';
import 'package:shakr/features/main/presentation/widgets/main_bottom_nav.dart';
import 'package:shakr/features/profile/presentation/pages/profile_page.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, int>(
          builder: (context, index) {
            return IndexedStack(
              index: index,
              children: const [
                ShakingScreen(),
                Center(child: Text(AppStrings.chatsPlaceholder)),
                ProfilePage(),
              ],
            );
          },
        ),
        bottomNavigationBar: const MainBottomNav(),
      ),
    );
  }
}
