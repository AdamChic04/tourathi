import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/place_details/place_details_screen.dart';
import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/ai_planner/ai_planner_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(Object appProvider) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainShell(),
          transitionDuration: const Duration(milliseconds: 550),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/home',
        redirect: (context, state) => '/main',
      ),
      GoRoute(
        path: '/place/:id',
        builder: (context, state) => PlaceDetailsScreen(
          placeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ai-planner',
        builder: (context, state) => const AiPlannerScreen(),
      ),
      GoRoute(
        path: '/ar-hub',
        builder: (context, state) =>
            const ComingSoonScreen(feature: 'AR Reconstruction'),
      ),
      GoRoute(
        path: '/social-journal',
        builder: (context, state) =>
            const ComingSoonScreen(feature: 'Travel Journal'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const ComingSoonScreen(feature: 'User Profile'),
      ),
    ],
  );
}
