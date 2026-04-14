import 'package:flutter/material.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';
import 'onboarding_shared.dart';

// ─── Screen 1: Hook ──────────────────────────────────────────────────────────

class Page1Hook extends StatelessWidget {
  final VoidCallback onNext;
  const Page1Hook({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return OnboardingPage(
      icon: iconCircle(context, Icons.psychology_alt_rounded),
      headline: l.onboarding1Headline,
      subtext: l.onboarding1Subtext,
      buttonLabel: l.onboarding1Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 2: How it works ──────────────────────────────────────────────────

class Page2HowItWorks extends StatelessWidget {
  final VoidCallback onNext;
  const Page2HowItWorks({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return OnboardingPage(
      icon: iconCircle(context, Icons.route_rounded),
      headline: l.onboarding2Headline,
      subtext: l.onboarding2Subtext,
      extra: Column(
        children: [
          StepRow(number: 1, icon: Icons.explore_rounded, label: l.onboarding2Step1, cs: cs),
          const SizedBox(height: AppSpacing.sm),
          StepRow(number: 2, icon: Icons.timer_rounded, label: l.onboarding2Step2, cs: cs),
          const SizedBox(height: AppSpacing.sm),
          StepRow(number: 3, icon: Icons.check_circle_rounded, label: l.onboarding2Step3, cs: cs),
        ],
      ),
      buttonLabel: l.onboarding2Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 3: Safety statement ──────────────────────────────────────────────

class Page3Safety extends StatelessWidget {
  final VoidCallback onNext;
  const Page3Safety({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return OnboardingPage(
      icon: iconCircle(context, Icons.favorite_rounded, bg: cs.secondaryContainer),
      headline: l.onboarding3Headline,
      subtext: l.onboarding3Subtext,
      buttonLabel: l.onboarding3Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 4: Starting point ────────────────────────────────────────────────

class Page4StartingPoint extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const Page4StartingPoint({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: iconCircle(context, Icons.tune_rounded)),
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
                LevelCard(
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
                LevelCard(
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
                LevelCard(
                  level: 3,
                  title: l.onboarding4Level3Title,
                  subtitle: l.onboarding4Level3Subtitle,
                  icon: Icons.rocket_launch,
                  selected: selected == 3,
                  color: Colors.red,
                  cs: cs,
                  onTap: () => onSelect(3),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Screen 5: Commitment ────────────────────────────────────────────────────

class Page5Commitment extends StatelessWidget {
  final VoidCallback onNext;
  const Page5Commitment({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return OnboardingPage(
      icon: iconCircle(context, Icons.access_time_rounded, bg: cs.tertiaryContainer),
      headline: l.onboarding5Headline,
      subtext: l.onboarding5Subtext,
      buttonLabel: l.onboarding5Button,
      onButton: onNext,
    );
  }
}

// ─── Screen 6: Notifications ─────────────────────────────────────────────────

class Page6Notifications extends StatelessWidget {
  final Set<int> selectedSlots;
  final bool requesting;
  final void Function(int) onToggleSlot;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const Page6Notifications({
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
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconCircle(context, Icons.notifications_active_rounded),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l.wantReminders,
                        style: tt.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.reminderExplanation,
                        style: tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlotChip(
                            icon: Icons.wb_sunny_rounded,
                            label: l.morning,
                            time: '9:00',
                            selected: selectedSlots.contains(1),
                            color: Colors.orange,
                            cs: cs,
                            onTap: () => onToggleSlot(1),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SlotChip(
                            icon: Icons.wb_cloudy_rounded,
                            label: l.afternoon,
                            time: '14:00',
                            selected: selectedSlots.contains(2),
                            color: cs.primary,
                            cs: cs,
                            onTap: () => onToggleSlot(2),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SlotChip(
                            icon: Icons.nights_stay_rounded,
                            label: l.evening,
                            time: '19:00',
                            selected: selectedSlots.contains(3),
                            color: Colors.deepPurple,
                            cs: cs,
                            onTap: () => onToggleSlot(3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SyntraButton.icon(
            onPressed: requesting ? null : onEnable,
            icon: Icons.notifications_active_rounded,
            label: requesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l.enableReminders),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onSkip,
            child: Text(
              l.rememberOnMyOwn,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Screen 7: First challenge ───────────────────────────────────────────────

class Page7FirstChallenge extends StatelessWidget {
  final Challenge? challenge;
  final VoidCallback onStartNow;
  final VoidCallback onLater;

  const Page7FirstChallenge({
    required this.challenge,
    required this.onStartNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconCircle(context, Icons.flag_rounded,
                          bg: cs.tertiaryContainer),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l.heresYourFirst,
                        style: tt.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l.firstChallengeDesc,
                        style: tt.bodyLarge
                            ?.copyWith(color: cs.onSurfaceVariant),
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
                                          style: tt.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.chipRadius),
                                      ),
                                      child: Text(
                                          '+${challenge!.xp} ${l.auraPoints}',
                                          style: tt.labelSmall?.copyWith(
                                              color: cs.onPrimaryContainer,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(challenge!.description,
                                    style: tt.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant),
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
                                      style: tt.labelSmall
                                          ?.copyWith(color: cs.outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SyntraButton.icon(
            onPressed: challenge != null ? onStartNow : null,
            icon: Icons.rocket_launch_rounded,
            label: Text(l.startNow),
          ),
          const SizedBox(height: AppSpacing.sm),
          SyntraButton(
            onPressed: onLater,
            color: cs.surfaceContainerHigh,
            child: Text(l.doItLater, style: TextStyle(color: cs.onSurface)),
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
