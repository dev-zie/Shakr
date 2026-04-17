import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

import 'package:shakr/features/chat/presentation/widgets/my_chats_body.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = sl<AuthCubit>().currentUid;
    if (uid == null) {
      return const Center(child: Text(AppStrings.loginRequired));
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tabChats), centerTitle: true),
      body: MyChatsBody(uid: uid),
    );
  }
}
