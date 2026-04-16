import 'package:go_router/go_router.dart';
import 'package:shakr/features/chat/presentation/pages/chat_expired_screen.dart';
import 'package:shakr/features/chat/presentation/pages/chat_screen.dart';
import 'package:shakr/features/main/presentation/pages/main_screen.dart';
import 'package:shakr/features/match/presentation/pages/match_found_screen.dart';
import 'package:shakr/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:shakr/features/settings/presentation/pages/settings_screen.dart';
import 'package:shakr/features/shake/presentation/pages/home_screen.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_screen.dart';
import 'package:shakr/features/splash/presentation/pages/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/shaking',
      builder: (context, state) => const ShakingScreen(),
    ),
    GoRoute(
      path: '/match/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return MatchFoundScreen(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/chat/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return ChatScreen(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/chat-expired/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return ChatExpiredScreen(matchId: matchId);
      },
    ),
    // GoRoute(
    //   path: '/settings',
    //   builder: (context, state) => const SettingsScreen(),
    // ),
    GoRoute(
      path: '/main/shake',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);
