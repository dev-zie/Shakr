import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_constants.dart';
import 'package:shakr/common/getit/injection.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_state.dart';
import 'package:shakr/features/splash/presentation/widgets/splash_body.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>()..getCurrentUser(),
      listener: (context, state) async {
        if (state.status == AuthStatus.success) {
          final isCompleted =
              await sl<LocalStorageService>().isOnboardingCompleted();
          await Future.delayed(
            const Duration(seconds: AppConstants.splashDelaySeconds),
          );
          if (!context.mounted) return;
          context.replace(isCompleted ? '/main/shake' : '/onboarding');
        }
        if (state.status == AuthStatus.error) {
          sl<AuthCubit>().signInAnonymously();
        }
      },
      child: const Scaffold(body: SplashBody()),
    );
  }
}
