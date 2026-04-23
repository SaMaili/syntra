import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/logbook_repository.dart';
import 'data/settings_repository.dart';
import 'generated/l10n.dart';
import 'logic/notification_manager.dart';
import 'providers/scroll_providers.dart';
import 'providers/settings_providers.dart';
import 'providers/statistics_providers.dart' show homeTabIndexProvider;
import 'router.dart';
import 'routes/challenges_screen.dart';
import 'routes/daily_challenge_screen.dart';
import 'routes/profile_screen.dart';
import 'routes/settings_screen.dart';
import 'services/sound_service.dart';
import 'static.dart';

// ─── Shell ────────────────────────────────────────────────────────────────────

class HomeBar extends ConsumerStatefulWidget {
  const HomeBar({super.key});

  @override
  ConsumerState<HomeBar> createState() => _HomeBarState();
}

class _HomeBarState extends ConsumerState<HomeBar>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _animFrom = 0;
  int _animTo = 0;
  late AnimationController _anim;
  bool _isAnimating = false;

  // Only screens that have been visited are added to the tree.
  // This prevents off-screen widgets from running initState (and firing
  // animations / sounds) before the user has ever navigated to them.
  final Set<int> _visited = {0};

  // Swipe tracking
  double _dragProgress = 0.0;
  bool _isDragging = false;
  double? _dragStartX;
  int? _dragTarget;

  static const _screens = <Widget>[
    ChallengesScreen(),
    DailyChallengeScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scheduleIfEnabled();
    _showDailyGreeting();
    ref.listenManual(homeTabIndexProvider, (_, next) {
      if (mounted) _onDestinationSelected(next);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int i) {
    if (_index == i) {
      if (i == 0) {
        ref.read(challengesScrollToTopProvider.notifier).update((s) => s + 1);
      }
      return;
    }
    if (_isAnimating) return;
    _animFrom = _index;
    _animTo = i;
    setState(() {
      _visited.add(i);
      _index = i;
      _isAnimating = true;
    });
    ref.read(homeTabIndexProvider.notifier).state = i;
    _anim.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _isAnimating = false);
    });
  }

  // Returns the horizontal offset for screen [i] given screen width [w].
  // Only the two involved pages move; all others stay off-screen.
  double _pageOffset(int i, double w) {
    double t;
    int from, to;

    if (_isAnimating) {
      t = Curves.easeInOutCubicEmphasized.transform(_anim.value);
      from = _animFrom;
      to = _animTo;
    } else if (_isDragging && _dragTarget != null) {
      t = _dragProgress;
      from = _index;
      to = _dragTarget!;
    } else {
      return i == _index ? 0.0 : (i < _index ? -w : w);
    }

    final d = to > from ? 1.0 : -1.0;
    if (i == from) return -d * w * t;
    if (i == to) return d * w * (1.0 - t);
    // Pages outside the transition range stay off-screen.
    return i < (from < to ? from : to) ? -w : w;
  }

  void _onDragStart(DragStartDetails d) {
    if (_isAnimating) return;
    _dragStartX = d.localPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_isAnimating || _dragStartX == null) return;
    final dx = d.localPosition.dx - _dragStartX!;
    if (!_isDragging) {
      if (dx < -8 && _index < _screens.length - 1) {
        _dragTarget = _index + 1;
        _visited.add(_dragTarget!);
      } else if (dx > 8 && _index > 0) {
        _dragTarget = _index - 1;
        _visited.add(_dragTarget!);
      } else {
        return;
      }
    }
    final w = MediaQuery.sizeOf(context).width;
    final dir = _dragTarget! > _index ? 1.0 : -1.0;
    setState(() {
      _isDragging = true;
      _dragProgress = (-dx * dir / w).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_isDragging || _dragTarget == null) {
      setState(() {
        _isDragging = false;
        _dragStartX = null;
      });
      return;
    }

    final vel = d.primaryVelocity ?? 0.0;
    final dir = _dragTarget! > _index ? 1.0 : -1.0;
    final complete = _dragProgress > 0.4 ||
        (dir > 0 && vel < -500) ||
        (dir < 0 && vel > 500);
    final target = _dragTarget!;

    _animFrom = _index;
    _animTo = target;
    setState(() {
      _isDragging = false;
      _dragTarget = null;
      _isAnimating = true;
      if (complete) _index = target;
    });

    if (complete) {
      ref.read(homeTabIndexProvider.notifier).state = target;
    }

    _anim.value = _dragProgress;
    final future = complete
        ? _anim.animateTo(1.0, duration: const Duration(milliseconds: 220))
        : _anim.animateBack(0.0, duration: const Duration(milliseconds: 220));
    future.whenComplete(() {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _dragProgress = 0.0;
        });
      }
    });

    _dragStartX = null;
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
        await context.goStreakCelebration(streak, isMilestone);
      }
    }
  }

  // ─── Bottom nav ──────────────────────────────────────────────────────────────

  Widget _buildNavBar(BuildContext context) {
    final l = S.of(context);

    if (Platform.isIOS) {
      // CupertinoTabBar — iOS 26 automatically renders it as liquid glass.
      return Listener(
        onPointerDown: (_) {
          HapticFeedback.selectionClick();
          SoundService.playClick(
              enabled: ref.read(soundEffectsEnabledProvider));
        },
        child: CupertinoTabBar(
          currentIndex: _index,
          onTap: _onDestinationSelected,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.compass),
              activeIcon: const Icon(CupertinoIcons.compass_fill),
              label: l.navChallenge,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.calendar),
              activeIcon: const Icon(CupertinoIcons.calendar_today),
              label: l.navDaily,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person),
              activeIcon: const Icon(CupertinoIcons.person_fill),
              label: l.navProfile,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.settings),
              activeIcon: const Icon(CupertinoIcons.settings_solid),
              label: l.navSettings,
            ),
          ],
        ),
      );
    }

    // Android — tinted frosted glass NavigationBar.
    final cs = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Listener(
          onPointerDown: (_) {
            HapticFeedback.selectionClick();
            SoundService.playClick(
                enabled: ref.read(soundEffectsEnabledProvider));
          },
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor:
                    cs.surface.withValues(alpha: 0.45),
                surfaceTintColor: cs.surfaceTint.withValues(alpha: 0.15),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
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
                  label: l.navChallenge,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today),
                  label: l.navDaily,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l.navProfile,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final w = MediaQuery.sizeOf(context).width;
              return Stack(
                children: [
                  for (int i = 0; i < _screens.length; i++)
                    if (_visited.contains(i))
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_pageOffset(i, w), 0),
                          child: _screens[i],
                        ),
                      ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }
}
