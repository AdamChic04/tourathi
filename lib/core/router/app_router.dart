import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_router_refresh.dart';
import '../../features/account/account_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/password_screens.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/place_details/place_details_screen.dart';
import '../../features/coming_soon/coming_soon_screen.dart';
import '../../features/ai_planner/ai_planner_screen.dart';
import '../../features/ai_planner/my_plans_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter router(AuthRouterRefresh authRefresh) => GoRouter(
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      // Always display the original splash animation on a normal launch.
      if (path == '/') return null;

      final hasSession = Supabase.instance.client.auth.currentSession != null;
      final signedOutRoutes = <String>{
        '/login', '/signup', '/forgot-password', '/verify-email',
      };

      if (authRefresh.isRecoveringPassword && hasSession &&
          path != '/reset-password') {
        return '/reset-password';
      }
      if (!hasSession) {
        return signedOutRoutes.contains(path) ? null : '/login';
      }
      if (signedOutRoutes.contains(path)) return '/main';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(isSignUp: false),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthScreen(isSignUp: true),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
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
        path: '/my-plans',
        builder: (context, state) => const MyPlansScreen(),
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
        builder: (context, state) => const AccountScreen(),
      ),
    ],
  );
}
