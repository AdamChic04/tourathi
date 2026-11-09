import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity_details/activity_details_screen.dart';
import '../../features/ai_group_planner/ai_group_planner_screen.dart';
import '../../features/ai_image_generator/ai_image_generator_screen.dart';
import '../../features/ai_planner/ai_planner_screen.dart';
import '../../features/ar_hub/ar_hub_screen.dart';
import '../../features/community_details/community_details_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../features/group_chat/group_chat_screen.dart';
import '../../features/jordan_passport/jordan_passport_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/place_details/place_details_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/social_journal/social_journal_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/travel_groups/travel_groups_screen.dart';
import '../providers/app_provider.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  static GoRouter router(AppProvider appProvider) {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/main',
          pageBuilder: (_, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const MainShell(),
            transitionDuration: const Duration(milliseconds: 600),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final eased = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: eased,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.025),
                    end: Offset.zero,
                  ).animate(eased),
                  child: child,
                ),
              );
            },
          ),
        ),
        GoRoute(
          path: '/home',
          redirect: (_, __) => '/main',
        ),
        GoRoute(
          path: '/place/:id',
          builder: (_, state) => PlaceDetailsScreen(
            placeId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/ai-planner',
          builder: (_, __) => const AiPlannerScreen(),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (_, state) => ActivityDetailsScreen(
            activityId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/travel-groups',
          builder: (_, __) => const TravelGroupsScreen(),
        ),
        GoRoute(
          path: '/community/:id',
          builder: (_, state) => CommunityDetailsScreen(
            communityId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/ai-group-planner',
          builder: (_, __) => const AiGroupPlannerScreen(),
        ),
        GoRoute(
          path: '/group-chat/:id',
          builder: (_, state) => GroupChatScreen(
            groupId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/rewards',
          builder: (_, __) => const RewardsScreen(),
        ),
        GoRoute(
          path: '/ai-image-generator',
          builder: (_, __) => const AiImageGeneratorScreen(),
        ),
        GoRoute(
          path: '/social-journal',
          builder: (_, __) => const SocialJournalScreen(),
        ),
        GoRoute(
          path: '/ar-hub',
          builder: (_, __) => const ArHubScreen(),
        ),
        GoRoute(
          path: '/marketplace',
          builder: (_, __) => const MarketplaceScreen(),
        ),
        GoRoute(
          path: '/jordan-passport',
          builder: (_, __) => const JordanPassportScreen(),
        ),
        GoRoute(
          path: '/emergency',
          builder: (_, __) => const EmergencyScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
      ],
    );
  }
}
