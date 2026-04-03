import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/logbook_repository.dart';
import 'data/settings_repository.dart';
import 'generated/l10n.dart';
import 'logic/notification_manager.dart';
import 'providers/settings_providers.dart';
import 'providers/statistics_providers.dart' show homeTabIndexProvider;
import 'routes/challenges_screen.dart';
import 'routes/daily_challenge_screen.dart';
import 'routes/settings_screen.dart';
import 'routes/statistics_screen.dart';
import 'routes/streak_celebration_screen.dart';
import 'services/sound_service.dart';
import 'static.dart';

// ─── Shell ────────────────────────────────────────────────────────────────────

class HomeBar extends ConsumerStatefulWidget {
  const HomeBar({super.key});

  @override
  ConsumerState<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends ConsumerState<HomeBar> {
  int _index = 0;
  late PageController _pageController;
  // True while animateToPage is in flight — suppresses intermediate onPageChanged.
  bool _isProgrammatic = false;

  static const _screens = <Widget>[
    ChallengesScreen(),
    DailyChallengeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
    _scheduleIfEnabled();
    _showDailyGreeting();
    // Listen for programmatic tab switches (e.g., "Explore all challenges").
    ref.listenManual(homeTabIndexProvider, (_, next) {
      if (mounted) {
        _onDestinationSelected(next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int i) {
    if (_index == i) return;
    setState(() => _index = i);
    ref.read(homeTabIndexProvider.notifier).state = i;
    _isProgrammatic = true;
    _pageController
        .animateToPage(
          i,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubicEmphasized,
        )
        .whenComplete(() => _isProgrammatic = false);
  }

  Future<void> _scheduleIfEnabled() async {
    await Future.microtask(() {});
    if (!mounted) return;
    final enabled = ref.read(notificationsEnabledProvider);
    if (enabled) {
      await NotificationManager.scheduleDailyReminders();
    }
  }

  Future<void> _showDailyGreeting() async {
    await Future.microtask(() {});
    if (!mounted) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastOpened = await SettingsRepository.instance.loadLastOpenedDate();
    await SettingsRepository.instance.saveLastOpenedDate(today);

    if (lastOpened == today) return; // Already opened today — no greeting

    if (!mounted) return;

    if (lastOpened == null) return; // First ever open after onboarding — skip

    final stats = await LogbookRepository.instance.overviewStats();
    final streak = stats['streak'] ?? 0;

    final lastDate = DateTime.tryParse(lastOpened);
    final daysSince = lastDate != null
        ? DateTime.now().difference(lastDate).inDays
        : 0;

    if (!mounted) return;

    final l = S.of(context);
    if (daysSince >= 7) {
      _showGreetingBanner(
        icon: Icons.waving_hand_rounded,
        message: l.greetingLongTime,
        autoDismiss: false,
      );
    } else if (streak == 0) {
      _showGreetingBanner(
        icon: Icons.refresh_rounded,
        message: l.greetingFresh,
        autoDismiss: false,
      );
    } else {
      _showStreakCelebration(streak);
    }
  }

  void _showGreetingBanner({
    required IconData icon,
    required String message,
    required bool autoDismiss,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        duration:
            autoDismiss ? const Duration(seconds: 2) : const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showStreakCelebration(int streak) async {
    if (!mounted) return;
    final lastCelebrated =
        await SettingsRepository.instance.loadLastCelebratedStreak();

    if (streak > lastCelebrated) {
      await SettingsRepository.instance.saveLastCelebratedStreak(streak);
      final isMilestone = AppStatic.streakMilestones.contains(streak);
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StreakCelebrationScreen(
              streak: streak,
              isMilestone: isMilestone,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) {
          // Skip updates during programmatic animation to avoid nav bar
          // briefly highlighting intermediate tabs.
          if (_isProgrammatic) return;
          if (_index != i) setState(() => _index = i);
        },
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Listener(
        onPointerDown: (_) {
          HapticFeedback.selectionClick();
          SoundService.playClick(enabled: ref.read(soundEffectsEnabledProvider));
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            tooltipTheme: const TooltipThemeData(
              triggerMode: TooltipTriggerMode.manual,
              waitDuration: Duration(days: 365),
              showDuration: Duration.zero,
            ),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: S.of(context).navChallenge,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: S.of(context).navDaily,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: S.of(context).navStats,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: S.of(context).navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
