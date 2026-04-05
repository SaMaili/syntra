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
import '../widgets/syntra_button.dart';

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
        .where((c) => c.type == 'solo' && !c.flirt)
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
                  // Progress dots
                  Expanded(child: _DotIndicator(page: _page, total: _totalPages)),
                  // Skip button (hidden on last page)
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
                  _Page1Hook(onNext: _next),
                  _Page2HowItWorks(onNext: _next),
                  _Page3Safety(onNext: _next),
                  _Page4StartingPoint(
                    selected: _comfortLevel,
                    onSelect: (level) async {
                      setState(() => _comfortLevel = level);
                      await SettingsRepository.instance.saveComfortZoneLevel(level);
                      await ref.read(comfortZoneLevelProvider.notifier).setLevel(level);
                      await Future.delayed(const Duration(milliseconds: 300));
                      _next();
                    },
                  ),
                  _Page5Commitment(onNext: _next),
                  _Page6Notifications(
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
                      // Enable selected slots (default all selected if none chosen)
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
                  _Page7FirstChallenge(
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

// ─── Dot progress indicator ──────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int page;
  final int total;
  const _DotIndicator({required this.page, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(total, (i) {
        final active = i == page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page base ───────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final Widget icon;
  final String headline;
  final String subtext;
  final Widget? extra;
  final String buttonLabel;
  final VoidCallback onButton;

  const _OnboardingPage({
    required this.icon,
    required this.headline,
    required this.subtext,
    this.extra,
    required this.buttonLabel,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Illustration area
          icon,
          const SizedBox(height: AppSpacing.xl),
          // Headline
          Text(
            headline,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Subtext
          Text(
            subtext,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (extra != null) ...[
            const SizedBox(height: AppSpacing.xl),
            extra!,
          ],
          const Spacer(flex: 3),
          // CTA button
          SyntraButton(
            onPressed: onButton,
            child: Text(buttonLabel),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Illustration helper ─────────────────────────────────────────────────────

Widget _iconCircle(BuildContext context, IconData icon, {Color? bg}) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: bg ?? cs.primaryContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 64, color: cs.onPrimaryContainer),
  );
}

// ─── Screen 1: Hook ──────────────────────────────────────────────────────────

class _Page1Hook extends StatelessWidget {
  final VoidCallback onNext;
  const _Page1Hook({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return _OnboardingPage(
      icon: _iconCircle(context, Icons.psychology_alt_rounded),
      headline: l.onboarding1Headline,
      subtext: l.onboarding1Subtext,
      buttonLabel: l.onboarding1Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 2: How it works ──────────────────────────────────────────────────

class _Page2HowItWorks extends StatelessWidget {
  final VoidCallback onNext;
  const _Page2HowItWorks({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return _OnboardingPage(
      icon: _iconCircle(context, Icons.route_rounded),
      headline: l.onboarding2Headline,
      subtext: l.onboarding2Subtext,
      extra: Column(
        children: [
          _StepRow(
            number: 1,
            icon: Icons.explore_rounded,
            label: l.onboarding2Step1,
            cs: cs,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StepRow(
            number: 2,
            icon: Icons.timer_rounded,
            label: l.onboarding2Step2,
            cs: cs,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StepRow(
            number: 3,
            icon: Icons.check_circle_rounded,
            label: l.onboarding2Step3,
            cs: cs,
          ),
        ],
      ),
      buttonLabel: l.onboarding2Button,
      onButton: onNext,
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _StepRow(
      {required this.number,
      required this.icon,
      required this.label,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primaryContainer,
          child: Text('$number',
              style: TextStyle(
                  color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: AppSpacing.md),
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Screen 3: Safety statement ──────────────────────────────────────────────

class _Page3Safety extends StatelessWidget {
  final VoidCallback onNext;
  const _Page3Safety({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return _OnboardingPage(
      icon: _iconCircle(context, Icons.favorite_rounded,
          bg: cs.secondaryContainer),
      headline: l.onboarding3Headline,
      subtext: l.onboarding3Subtext,
      buttonLabel: l.onboarding3Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 4: Starting point ────────────────────────────────────────────────

class _Page4StartingPoint extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const _Page4StartingPoint(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          _iconCircle(context, Icons.tune_rounded),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l.onboarding4Headline,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.onboarding4Subtext,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _LevelCard(
            level: 1,
            title: l.onboarding4Level1Title,
            subtitle: l.onboarding4Level1Subtitle,
            icon: Icons.self_improvement,
            selected: selected == 1,
            color: Colors.green,
            cs: cs,
            onTap: () => onSelect(1),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LevelCard(
            level: 2,
            title: l.onboarding4Level2Title,
            subtitle: l.onboarding4Level2Subtitle,
            icon: Icons.trending_up,
            selected: selected == 2,
            color: Colors.amber,
            cs: cs,
            onTap: () => onSelect(2),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LevelCard(
            level: 3,
            title: l.onboarding4Level3Title,
            subtitle: l.onboarding4Level3Subtitle,
            icon: Icons.rocket_launch,
            selected: selected == 3,
            color: Colors.red,
            cs: cs,
            onTap: () => onSelect(3),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color color;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.color,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Screen 5: Commitment ────────────────────────────────────────────────────

class _Page5Commitment extends StatelessWidget {
  final VoidCallback onNext;
  const _Page5Commitment({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return _OnboardingPage(
      icon: _iconCircle(context, Icons.access_time_rounded,
          bg: cs.tertiaryContainer),
      headline: l.onboarding5Headline,
      subtext: l.onboarding5Subtext,
      buttonLabel: l.onboarding5Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 6: Notifications ─────────────────────────────────────────────────

class _Page6Notifications extends StatelessWidget {
  final Set<int> selectedSlots;
  final bool requesting;
  final void Function(int) onToggleSlot;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const _Page6Notifications({
    required this.selectedSlots,
    required this.requesting,
    required this.onToggleSlot,
    required this.onEnable,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _iconCircle(context, Icons.notifications_active_rounded),
          const SizedBox(height: AppSpacing.xl),
          Text(
            S.of(context).wantReminders,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            S.of(context).reminderExplanation,
            style: tt.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SlotChip(
                icon: Icons.wb_sunny_rounded,
                label: S.of(context).morning,
                time: '9:00',
                selected: selectedSlots.contains(1),
                color: Colors.orange,
                cs: cs,
                onTap: () => onToggleSlot(1),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SlotChip(
                icon: Icons.wb_cloudy_rounded,
                label: S.of(context).afternoon,
                time: '14:00',
                selected: selectedSlots.contains(2),
                color: cs.primary,
                cs: cs,
                onTap: () => onToggleSlot(2),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SlotChip(
                icon: Icons.nights_stay_rounded,
                label: S.of(context).evening,
                time: '19:00',
                selected: selectedSlots.contains(3),
                color: Colors.deepPurple,
                cs: cs,
                onTap: () => onToggleSlot(3),
              ),
            ],
          ),
          const Spacer(flex: 3),
          SyntraButton.icon(
            onPressed: requesting ? null : onEnable,
            icon: Icons.notifications_active_rounded,
            label: requesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(S.of(context).enableReminders),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onSkip,
            child: Text(
              S.of(context).rememberOnMyOwn,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool selected;
  final Color color;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _SlotChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.selected,
    required this.color,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : cs.onSurfaceVariant, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : cs.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(time,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ─── Screen 7: First challenge ───────────────────────────────────────────────

class _Page7FirstChallenge extends StatelessWidget {
  final Challenge? challenge;
  final VoidCallback onStartNow;
  final VoidCallback onLater;

  const _Page7FirstChallenge({
    required this.challenge,
    required this.onStartNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          _iconCircle(context, Icons.flag_rounded, bg: cs.tertiaryContainer),
          const SizedBox(height: AppSpacing.xl),
          Text(
            S.of(context).heresYourFirst,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            S.of(context).firstChallengeDesc,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (challenge != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(challenge!.title,
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.chipRadius),
                          ),
                          child: Text('+${challenge!.xp} ${S.of(context).auraPoints}',
                              style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(challenge!.description,
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 14, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(challenge!.time),
                          style: tt.labelSmall?.copyWith(color: cs.outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            const CircularProgressIndicator(),
          const Spacer(flex: 3),
          SyntraButton.icon(
            onPressed: challenge != null ? onStartNow : null,
            icon: Icons.rocket_launch_rounded,
            label: Text(S.of(context).startNow),
          ),
          const SizedBox(height: AppSpacing.sm),
          SyntraButton(
            onPressed: onLater,
            color: cs.surfaceContainerHigh,
            child: Text(
              S.of(context).doItLater,
              style: TextStyle(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}
