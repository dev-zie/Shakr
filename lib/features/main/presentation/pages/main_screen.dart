import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';
import 'package:shakr/features/main/presentation/widgets/main_body.dart';
import 'package:shakr/features/main/presentation/widgets/main_bottom_nav.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) {
        if (initialIndex == 0) {
          sl<ShakeCubit>().init();
        }
        return NavigationCubit()..goTo(initialIndex);
      },
      child: BlocListener<NavigationCubit, int>(
        listener: (context, index) {
          if (index == 0) {
            sl<ShakeCubit>().init();
          } else {
            sl<ShakeCubit>().disposeScreen();
          }
        },
        child: const Scaffold(
          body: MainBody(),
          bottomNavigationBar: MainBottomNav(),
        ),
      ),
    );
  }
}
