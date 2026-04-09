import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.welcomeString,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/shaking');
                },
                child: Text(AppStrings.shakeString),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
