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
import 'routes/priming_screen.dart';
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
  static const priming = '/priming';
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
      path: AppRoutes.priming,
      builder: (context, state) {
        final args = state.extra as _PrimingArgs;
        return PrimingScreen(
          challenge: args.challenge,
          isDailyMission: args.isDailyMission,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.activeChallenge,
      builder: (context, state) {
        final args = state.extra as _ActiveChallengeArgs;
        return ActiveChallengeScreen(
          challenge: args.challenge,
          isDailyMission: args.isDailyMission,
          overrideTime: args.overrideTime,
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
          isDailyMission: args.isDailyMission,
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

class _PrimingArgs {
  final Challenge challenge;
  final bool isDailyMission;
  const _PrimingArgs(this.challenge, {this.isDailyMission = false});
}

class _ActiveChallengeArgs {
  final Challenge challenge;
  final bool isDailyMission;
  final int? overrideTime;
  const _ActiveChallengeArgs(this.challenge,
      {this.isDailyMission = false, this.overrideTime});
}

class _ChallengeDoneArgs {
  final Challenge challenge;
  final double rewardFactor;
  final int? durationSeconds;
  final bool isDailyMission;
  const _ChallengeDoneArgs(
    this.challenge,
    this.rewardFactor, {
    this.durationSeconds,
    this.isDailyMission = false,
  });
}

class _StreakCelebrationArgs {
  final int streak;
  final bool isMilestone;
  const _StreakCelebrationArgs(this.streak, this.isMilestone);
}

/// Type-safe helpers so callers never deal with raw strings or dynamic casts.
extension AppNavigation on BuildContext {
  /// Push the priming countdown screen. Returns the reward factor once the full
  /// challenge flow completes, or null if the user cancelled at the priming step.
  Future<double?> pushPriming(Challenge challenge, {bool isDailyMission = false}) =>
      GoRouter.of(this).push<double>(
        AppRoutes.priming,
        extra: _PrimingArgs(challenge, isDailyMission: isDailyMission),
      );

  Future<double?> pushActiveChallenge(
    Challenge challenge, {
    bool isDailyMission = false,
    int? overrideTime,
  }) =>
      GoRouter.of(this).push<double>(
        AppRoutes.activeChallenge,
        extra: _ActiveChallengeArgs(challenge,
            isDailyMission: isDailyMission, overrideTime: overrideTime),
      );

  Future<double?> pushChallengeDone(
    Challenge challenge,
    double rewardFactor, {
    int? durationSeconds,
    bool isDailyMission = false,
  }) =>
      GoRouter.of(this).push<double>(
        AppRoutes.challengeDone,
        extra: _ChallengeDoneArgs(
          challenge,
          rewardFactor,
          durationSeconds: durationSeconds,
          isDailyMission: isDailyMission,
        ),
      );

  void goLogbook() => GoRouter.of(this).push(AppRoutes.logbook);

  void goLogbookDetail(Map<String, dynamic> entry) =>
      GoRouter.of(this).push(AppRoutes.logbookDetail, extra: entry);

  void goAbout() => GoRouter.of(this).push(AppRoutes.about);

  Future<void> goStreakCelebration(int streak, bool isMilestone) =>
      GoRouter.of(this).push<void>(
        AppRoutes.streakCelebration,
        extra: _StreakCelebrationArgs(streak, isMilestone),
      );
}
