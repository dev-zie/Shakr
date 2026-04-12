import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/core/constants/app_strings.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_state.dart';
import 'package:shakr/injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    sl<LocalStorageService>().resetOnboarding(); // gecici, test icin
    sl<AuthCubit>().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, state) async {
        if (state is AuthSucces) {
          final isCompleted = await sl<LocalStorageService>()
              .isOnboardingCompleted();
          if (isCompleted) {
            context.go('/home'); 
          } else {
            context.go('/onboarding');
          }
        }
        if (state is AuthError) {
          print('Auth Error: ${state.message}');
          sl<AuthCubit>().signInAnonymously();
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
