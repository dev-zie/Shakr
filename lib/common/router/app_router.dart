import 'package:go_router/go_router.dart';
import 'package:shakr/features/chat/presentation/pages/chat_expired_page.dart';
import 'package:shakr/features/chat/presentation/pages/chat_page.dart';
import 'package:shakr/features/main/presentation/pages/main_page.dart';
import 'package:shakr/features/match/presentation/pages/match_found_page.dart';
import 'package:shakr/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shakr/features/settings/presentation/pages/settings_page.dart';
import 'package:shakr/features/shake/presentation/pages/shaking_page.dart';
import 'package:shakr/features/splash/presentation/pages/splash_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/shaking',
      builder: (context, state) => const ShakingPage(),
    ),
    GoRoute(
      path: '/match/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return MatchFoundPage(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/chat/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        final chatStartTime = state.extra as DateTime?;
        final isPermanent = state.uri.queryParameters['permanent'] == 'true';
        final name = state.uri.queryParameters['name'];
        final photo = state.uri.queryParameters['photo'];

        return ChatPage(
          matchId: matchId,
          chatStartTime: chatStartTime ?? DateTime.now(),
          isPermanent: isPermanent,
          otherUserName: name,
          otherUserPhoto: photo,
        );
      },
    ),
    GoRoute(
      path: '/chat-expired/:matchId',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId']!;
        return ChatExpiredPage(matchId: matchId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/main/shake',
      builder: (context, state) => const MainPage(initialIndex: 0),
    ),
    GoRoute(
      path: '/main/chats',
      builder: (context, state) => const MainPage(initialIndex: 1),
    ),
    GoRoute(
      path: '/main/profile',
      builder: (context, state) => const MainPage(initialIndex: 2),
    ),
  ],
);
