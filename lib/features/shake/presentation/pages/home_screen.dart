import 'package:flutter/material.dart';
import 'package:shakr/features/shake/presentation/widgets/home_body.dart';
import 'package:shakr/features/shake/presentation/widgets/settings_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [SettingsButton()]),
      body: HomeBody(),
    );
  }
}
