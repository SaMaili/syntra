import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../challenge.dart';
import '../data/challenge_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../providers/router_notifier.dart';
import '../providers/settings_providers.dart';
import '../routes/active_challenge_screen.dart';
import '../services/syntra_notification_service.dart';
import 'onboarding/onboarding_pages.dart';
import 'onboarding/onboarding_shared.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // Screen 4 state — starting point
  int _comfortLevel = 0; // 0 = not selected, 1–3 = chosen level

  // Screen 6 state — notifications
  final Set<int> _selectedSlots = {};
  bool _requestingPermission = false;

  // Screen 7 state — first challenge
  Challenge? _firstChallenge;

  static const int _totalPages = 7;

  @override
  void initState() {
    super.initState();
    _loadFirstChallenge();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFirstChallenge() async {
    final locale = ref.read(activeLocaleProvider);
    final challenges = await ChallengeRepository.instance.loadChallenges(locale);
    if (mounted) {
      final byId = challenges.where((c) => c.id == '1');
      final soloEasy = challenges
          .where((c) => c.type == ChallengeType.solo && !c.flirt)
          .toList()
        ..sort((a, b) => a.aura.compareTo(b.aura));
      setState(() => _firstChallenge = byId.isNotEmpty
          ? byId.first
          : soloEasy.isNotEmpty
              ? soloEasy.first
              : challenges.first);
    }
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: const Cubic(0.25, 0.46, 0.45, 0.94),
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await SettingsRepository.instance.saveOnboardingComplete(true);
    routerNotifier.completeOnboarding();
  }

  Future<void> _skip() async {
    await _completeOnboarding();
    if (mounted) context.go('/');
  }

  Future<void> _finishWithChallenge() async {
    await _completeOnboarding();
    if (!mounted) return;
    final challenge = _firstChallenge;
    final nav = Navigator.of(context);
    context.go('/');
    if (challenge != null) {
      // Brief delay so HomeBar renders before pushing active challenge
      await Future.delayed(const Duration(milliseconds: 200));
      nav.push(MaterialPageRoute(
        builder: (_) => ActiveChallengeScreen(challenge: challenge),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pages = <Widget>[
      Page1Hook(onNext: _next),
      Page2HowItWorks(onNext: _next),
      Page3Safety(onNext: _next),
      Page4StartingPoint(
        selected: _comfortLevel,
        onSelect: (level) async {
          setState(() => _comfortLevel = level);
          await SettingsRepository.instance.saveComfortZoneLevel(level);
          await ref.read(comfortZoneLevelProvider.notifier).setLevel(level);
          await Future.delayed(const Duration(milliseconds: 300));
          _next();
        },
      ),
      Page5Commitment(onNext: _next),
      Page6Notifications(
        selectedSlots: _selectedSlots,
        requesting: _requestingPermission,
        onToggleSlot: (slot) => setState(() {
          // Single-select (design + onboarding chat: one slot only).
          _selectedSlots
            ..clear()
            ..add(slot);
        }),
        onEnable: () async {
          setState(() => _requestingPermission = true);
          await SyntraNotificationService.instance.requestPermissions();
          await ref.read(notificationsEnabledProvider.notifier).set(true);
          // One nudge a day. The picked preset (morning/afternoon/evening)
          // seeds the single reminder time; default to morning (09:00).
          final slot = _selectedSlots.isEmpty ? 1 : _selectedSlots.first;
          const presetHour = {1: 9, 2: 14, 3: 19};
          await ref.read(reminderEnabledProvider.notifier).set(true);
          await ref.read(reminderTimeProvider.notifier).setTime(
                TimeOfDay(hour: presetHour[slot] ?? 9, minute: 0),
              );
          if (mounted) setState(() => _requestingPermission = false);
          _next();
        },
        onSkip: _next,
      ),
      Page7FirstChallenge(
        challenge: _firstChallenge,
        onStartNow: _finishWithChallenge,
        onLater: () async {
          final router = GoRouter.of(context);
          await _completeOnboarding();
          if (mounted) router.go('/');
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
              // ─── Header: progress + Skip ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: OnbProgress(page: _page, total: _totalPages),
                    ),
                    if (_page < _totalPages - 1)
                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(14, 6, 0, 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          S.of(context).skip,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ─── Page body: pages slide side-by-side (real PageView) ──
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: pages,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

