import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'challenge.dart';
import 'home_bar.dart';
import 'providers/router_notifier.dart';
import 'routes/about_page.dart';
import 'routes/active_challenge_screen.dart';
import 'routes/challenge_done_screen.dart';
import 'routes/logbook_detail_page.dart';
import 'routes/logbook_page.dart';
import 'routes/onboarding_screen.dart';
import 'routes/streak_celebration_screen.dart';

/// All named routes in the app.
abstract class AppRoutes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const activeChallenge = '/active_challenge';
  static const challengeDone = '/challenge_done';
  static const logbook = '/logbook';
  static const logbookDetail = '/logbook_detail';
  static const about = '/about';
  static const streakCelebration = '/streak_celebration';
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: routerNotifier,
  redirect: (context, state) {
    final onboardingDone = routerNotifier.onboardingComplete;
    final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
    if (!onboardingDone && !isOnboarding) return AppRoutes.onboarding;
    if (onboardingDone && isOnboarding) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeBar(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeChallenge,
      builder: (context, state) {
        final challenge = state.extra as Challenge;
        return ActiveChallengeScreen(challenge: challenge);
      },
    ),
    GoRoute(
      path: AppRoutes.challengeDone,
      builder: (context, state) {
        final args = state.extra as _ChallengeDoneArgs;
        return ChallengeDoneScreen(
          challenge: args.challenge,
          rewardFactor: args.rewardFactor,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.logbook,
      builder: (context, state) => const LogbookPage(),
    ),
    GoRoute(
      path: AppRoutes.logbookDetail,
      builder: (context, state) {
        final entry = state.extra as Map<String, dynamic>;
        return LogbookDetailPage(entry: entry);
      },
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutNotePage(),
    ),
    GoRoute(
      path: AppRoutes.streakCelebration,
      builder: (context, state) {
        final args = state.extra as _StreakCelebrationArgs;
        return StreakCelebrationScreen(
          streak: args.streak,
          isMilestone: args.isMilestone,
        );
      },
    ),
  ],
);

class _ChallengeDoneArgs {
  final Challenge challenge;
  final double rewardFactor;
  const _ChallengeDoneArgs(this.challenge, this.rewardFactor);
}

class _StreakCelebrationArgs {
  final int streak;
  final bool isMilestone;
  const _StreakCelebrationArgs(this.streak, this.isMilestone);
}

/// Type-safe helpers so callers never deal with raw strings or dynamic casts.
extension AppNavigation on BuildContext {
  void goActiveChallenge(Challenge challenge) =>
      GoRouter.of(this).push(AppRoutes.activeChallenge, extra: challenge);

  void goChallengeDone(Challenge challenge, double rewardFactor) =>
      GoRouter.of(this).push(
        AppRoutes.challengeDone,
        extra: _ChallengeDoneArgs(challenge, rewardFactor),
      );

  void goLogbook() => GoRouter.of(this).push(AppRoutes.logbook);

  void goLogbookDetail(Map<String, dynamic> entry) =>
      GoRouter.of(this).push(AppRoutes.logbookDetail, extra: entry);

  void goAbout() => GoRouter.of(this).push(AppRoutes.about);

  void goStreakCelebration(int streak, bool isMilestone) =>
      GoRouter.of(this).push(
        AppRoutes.streakCelebration,
        extra: _StreakCelebrationArgs(streak, isMilestone),
      );
}
