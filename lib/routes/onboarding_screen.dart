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
import '../theme/app_spacing.dart';
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
    final soloEasy = challenges
        .where((c) => c.type == ChallengeType.solo && !c.flirt)
        .toList()
      ..sort((a, b) => a.xp.compareTo(b.xp));
    if (mounted) {
      setState(() => _firstChallenge = soloEasy.isNotEmpty ? soloEasy.first : challenges.first);
    }
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
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

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: DotIndicator(page: _page, total: _totalPages)),
                  if (_page < _totalPages - 1)
                    TextButton(
                      onPressed: _skip,
                      child: Text(S.of(context).skip,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                ],
              ),
            ),

            // ─── Page content ─────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
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
                    onToggleSlot: (slot) =>
                        setState(() => _selectedSlots.contains(slot)
                            ? _selectedSlots.remove(slot)
                            : _selectedSlots.add(slot)),
                    onEnable: () async {
                      setState(() => _requestingPermission = true);
                      await SyntraNotificationService.instance.requestPermissions();
                      await ref.read(notificationsEnabledProvider.notifier).set(true);
                      final slots = _selectedSlots.isEmpty ? {1, 2, 3} : _selectedSlots;
                      for (final slot in slots) {
                        await ref.read(notificationSlotsProvider.notifier).updateSlot(
                          slot - 1,
                          (await SettingsRepository.instance.loadSlot(slot))
                              .copyWith(enabled: true),
                        );
                      }
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
