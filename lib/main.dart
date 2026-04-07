import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shakr/core/router/app_router.dart';
import 'package:shakr/core/theme/app_theme.dart';
import 'package:shakr/firebase_options.dart';
import 'package:shakr/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
