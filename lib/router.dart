import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'challenge.dart';
import 'home_bar.dart';
import 'logic/badges_logic.dart';
import 'logic/warmup_logic.dart' show WarmupSession;
import 'providers/router_notifier.dart';
import 'routes/about_page.dart';
import 'routes/active_challenge_screen.dart';
import 'routes/all_badges_page.dart';
import 'routes/challenge_done_screen.dart';
import 'routes/logbook_detail_page.dart';
import 'routes/logbook_page.dart';
import 'routes/onboarding_screen.dart';
import 'routes/badge_unlocked_screen.dart';
import 'routes/level_up_screen.dart';
import 'routes/streak_celebration_screen.dart';

/// All named routes in the app.
abstract class AppRoutes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const activeChallenge = '/active_challenge';
  static const challengeDone = '/challenge_done';
  static const logbook = '/logbook';
  static const about = '/about';
  static const streakCelebration = '/streak_celebration';
  static const levelUp = '/level_up';
  static const badgeUnlocked = '/badge_unlocked';
  static const allBadges = '/badges';
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
        final args = state.extra as _ActiveChallengeArgs;
        return ActiveChallengeScreen(
          challenge: args.challenge,
          isGuided: args.isGuided,
          overrideTime: args.overrideTime,
          warmup: args.warmup,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.challengeDone,
      builder: (context, state) {
        final args = state.extra as _ChallengeDoneArgs;
        return ChallengeDoneScreen(
          challenge: args.challenge,
          rewardFactor: args.rewardFactor,
          durationSeconds: args.durationSeconds,
          isGuided: args.isGuided,
          warmup: args.warmup,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.logbook,
      builder: (context, state) => const LogbookPage(),
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
    GoRoute(
      path: AppRoutes.levelUp,
      builder: (context, state) {
        final args = state.extra as _LevelUpArgs;
        return LevelUpScreen(newLevel: args.newLevel);
      },
    ),
    GoRoute(
      path: AppRoutes.badgeUnlocked,
      builder: (context, state) {
        final args = state.extra as _BadgeUnlockedArgs;
        return BadgeUnlockedScreen(badge: args.badge);
      },
    ),
    GoRoute(
      path: AppRoutes.allBadges,
      builder: (context, state) => const AllBadgesPage(),
    ),
  ],
);

class _ActiveChallengeArgs {
  final Challenge challenge;
  final bool isGuided;
  final int? overrideTime;
  final WarmupSession? warmup;
  const _ActiveChallengeArgs(this.challenge,
      {this.isGuided = false, this.overrideTime, this.warmup});
}

class _ChallengeDoneArgs {
  final Challenge challenge;
  final double rewardFactor;
  final int? durationSeconds;
  final bool isGuided;
  final WarmupSession? warmup;
  const _ChallengeDoneArgs(
    this.challenge,
    this.rewardFactor, {
    this.durationSeconds,
    this.isGuided = false,
    this.warmup,
  });
}

class _StreakCelebrationArgs {
  final int streak;
  final bool isMilestone;
  const _StreakCelebrationArgs(this.streak, this.isMilestone);
}

class _LevelUpArgs {
  final int newLevel;
  const _LevelUpArgs(this.newLevel);
}

class _BadgeUnlockedArgs {
  final AppBadge badge;
  const _BadgeUnlockedArgs(this.badge);
}

/// Type-safe helpers so callers never deal with raw strings or dynamic casts.
extension AppNavigation on BuildContext {
  Future<double?> pushActiveChallenge(
    Challenge challenge, {
    bool isGuided = false,
    int? overrideTime,
    WarmupSession? warmup,
  }) =>
      GoRouter.of(this).push<double>(
        AppRoutes.activeChallenge,
        extra: _ActiveChallengeArgs(challenge,
            isGuided: isGuided,
            overrideTime: overrideTime,
            warmup: warmup),
      );

  /// Replaces the entire navigation stack with a fresh [ActiveChallengeScreen].
  /// Use this for "try again" and warm-up chaining so the old challenge route
  /// is not left in the stack.
  void goActiveChallenge(
    Challenge challenge, {
    bool isGuided = false,
    int? overrideTime,
    WarmupSession? warmup,
  }) =>
      GoRouter.of(this).go(
        AppRoutes.activeChallenge,
        extra: _ActiveChallengeArgs(challenge,
            isGuided: isGuided,
            overrideTime: overrideTime,
            warmup: warmup),
      );

  Future<double?> pushChallengeDone(
    Challenge challenge,
    double rewardFactor, {
    int? durationSeconds,
    bool isGuided = false,
    WarmupSession? warmup,
  }) =>
      GoRouter.of(this).push<double>(
        AppRoutes.challengeDone,
        extra: _ChallengeDoneArgs(
          challenge,
          rewardFactor,
          durationSeconds: durationSeconds,
          isGuided: isGuided,
          warmup: warmup,
        ),
      );

  /// Resets the stack to the home shell — used to end a warm-up run cleanly
  /// (the chained `.go` navigations leave no home route to pop back to).
  void goHome() => GoRouter.of(this).go(AppRoutes.home);

  void goLogbook() => GoRouter.of(this).push(AppRoutes.logbook);

  Future<bool?> goLogbookDetail(Map<String, dynamic> entry, String title) =>
      LogbookDetailPage.show(this, entry, title);

  void goAbout() => GoRouter.of(this).push(AppRoutes.about);

  Future<void> goStreakCelebration(int streak, bool isMilestone) =>
      GoRouter.of(this).push<void>(
        AppRoutes.streakCelebration,
        extra: _StreakCelebrationArgs(streak, isMilestone),
      );

  Future<void> goLevelUp(int newLevel) =>
      GoRouter.of(this).push<void>(
        AppRoutes.levelUp,
        extra: _LevelUpArgs(newLevel),
      );

  Future<void> goBadgeUnlocked(AppBadge badge) =>
      GoRouter.of(this).push<void>(
        AppRoutes.badgeUnlocked,
        extra: _BadgeUnlockedArgs(badge),
      );

  void goAllBadges() => GoRouter.of(this).push(AppRoutes.allBadges);
}
