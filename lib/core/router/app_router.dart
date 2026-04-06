import 'package:go_router/go_router.dart';
import 'package:shakr/features/chat/presentation/pages/chat_expired_screen.dart';
import 'package:shakr/features/chat/presentation/pages/chat_screen.dart';
import 'package:shakr/features/match/presentation/pages/match_found_screen.dart';
import 'package:shakr/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shakr/features/settings/presentation/pages/settings_screen.dart';
import 'package:shakr/features/shake/presentation/pages/home_screen.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_screen.dart';
import 'package:shakr/features/splash/presentation/pages/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/', // uygulama acilinca buradan basla
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/chat', builder: (context, state) => ChatScreen()),
    GoRoute(
      path: '/chat-expired',
      builder: (context, state) => ChatExpiredScreen(),
    ),
    GoRoute(path: '/match', builder: (context, state) => MatchFoundScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
    GoRoute(path: '/shake', builder: (context, state) => ShakingScreen()),
  ],
);
