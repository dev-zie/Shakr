import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/chat/presentation/pages/my_chats_page.dart';
import 'package:shakr/features/main/presentation/cubit/navigation_cubit.dart';
import 'package:shakr/features/profile/presentation/pages/profile_page.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_page.dart';

class MainBody extends StatelessWidget {
  const MainBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, index) {
        return IndexedStack(
          index: index,
          children: const [ShakingPage(), MyChatsPage(), ProfilePage()],
        );
      },
    );
  }
}
