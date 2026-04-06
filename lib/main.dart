import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shakr/core/theme/app_theme.dart';
import 'package:shakr/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(body: Center(child: Text('Shakr'))),
    );
  }
}
