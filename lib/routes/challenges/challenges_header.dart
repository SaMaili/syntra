import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/shop_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';

/// Scrollable hero header shown at the top of the challenges screen.
class ChallengesHeroHeader extends ConsumerWidget {
  const ChallengesHeroHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(overviewStatsProvider);
    final availableXp = ref.watch(availableAuraProvider) ?? 0;
    final weekStreak = stats.whenOrNull(data: (s) => s['weekStreak']) ?? 0;
    final pendingWeekStreak =
        stats.whenOrNull(data: (s) => s['pendingWeekStreak']) ?? 0;
    final currentWeekXp = ref.watch(currentWeekXpProvider).valueOrNull ?? 0;
    final freezes = ref.watch(streakFreezesProvider);

    final isStreakActive = weekStreak > 0;
    final displayStreak = weekStreak > 0 ? weekStreak : pendingWeekStreak;
    final progress = (currentWeekXp / kWeeklyXpThreshold).clamp(0.0, 1.0);

    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Streak progress pill ──────────────────────────────────────────
          _StreakProgressPill(
            isActive: isStreakActive,
            progress: progress,
            currentWeekXp: currentWeekXp,
            streakLabel: '$displayStreak ${l.weeksShort}',
          ),

          // ── Freeze badge (only when user owns at least one) ───────────────
          if (freezes > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            _StatBadge(
              icon: Icons.ac_unit_rounded,
              label: '×$freezes',
              color: cs.tertiary,
              bg: cs.tertiary.withValues(alpha: 0.12),
            ),
          ],

          const Spacer(),

          // ── Aura badge ────────────────────────────────────────────────────
          _StatBadge(
            icon: Icons.emoji_events,
            label: '$availableXp ${l.auraPoints}',
            color: cs.onPrimaryContainer,
            bg: cs.primaryContainer,
          ),
        ],
      ),
    );
  }
}

// ─── Streak progress pill ─────────────────────────────────────────────────────

class _StreakProgressPill extends StatefulWidget {
  final bool isActive;
  final double progress; // 0.0–1.0  (currentWeekXp / kWeeklyXpThreshold)
  final int currentWeekXp;
  final String streakLabel; // e.g. "4 weeks"

  const _StreakProgressPill({
    required this.isActive,
    required this.progress,
    required this.currentWeekXp,
    required this.streakLabel,
  });

  @override
  State<_StreakProgressPill> createState() => _StreakProgressPillState();
}

class _StreakProgressPillState extends State<_StreakProgressPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // True only while the bar is visually moving (or in the post-completion delay).
  bool _isAnimating = false;

  // Tracks the current animation "generation" to prevent stale delays
  // from clearing _isAnimating when a newer animation has taken over.
  int _animGeneration = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this)
      // Start at the current value so the first render is correct without
      // an animation.
      ..value = widget.progress;
  }

  @override
  void didUpdateWidget(_StreakProgressPill old) {
    super.didUpdateWidget(old);
    if ((old.progress - widget.progress).abs() > 0.001) {
      _animateTo(widget.progress);
    }
  }

  Future<void> _animateTo(double target) async {
    final gen = ++_animGeneration;
    // Brief pause before the bar moves so the user notices the change.
    await Future.delayed(const Duration(seconds: 1));
    if (gen != _animGeneration || !mounted) return;
    setState(() => _isAnimating = true);
    try {
      await _ctrl
          .animateTo(
            target,
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
          )
          .orCancel;

      // After every animation hold the x/300 label for 3 seconds so the user
      // can read the new value before it flips back to the streak label.
      if (mounted) {
        await Future.delayed(const Duration(seconds: 3));
      }

      // After the hold: only clear _isAnimating if no newer call has taken over.
      if (gen != _animGeneration || !mounted) return;
      setState(() => _isAnimating = false);
    } on TickerCanceled {
      // A newer _animateTo call took over; it manages _isAnimating.
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final p = _ctrl.value;
        final cs = Theme.of(context).colorScheme;
        final bg = cs.surfaceContainerHighest;

        // ── Colors per state ────────────────────────────────────────────────
        // _isAnimating takes priority so the filling style is held for the
        // entire animation + 2 s delay, even if isActive flips mid-flight.
        // full  : settled + isActive  → amber
        // filling: _isAnimating       → soft orange
        // idle  : settled, not full   → grey
        final Color fgColor;
        final Color fillColor;

        if (_isAnimating) {
          fgColor = cs.tertiary.withValues(alpha: 0.65);
          fillColor = cs.tertiary.withValues(alpha: 0.22);
        } else if (widget.isActive) {
          fgColor = Colors.amber.shade800;
          fillColor = Colors.amber.withValues(alpha: 0.25);
        } else {
          fgColor = cs.onSurfaceVariant;
          fillColor = cs.tertiary.withValues(alpha: 0.14);
        }

        // ── Decoration ──────────────────────────────────────────────────────
        final BoxDecoration decoration;
        if (p < 0.005) {
          decoration = BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          );
        } else {
          decoration = BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            gradient: LinearGradient(
              stops: [0.0, p, p, 1.0],
              colors: [fillColor, fillColor, bg, bg],
            ),
          );
        }

        // ── Label ───────────────────────────────────────────────────────────
        // filling  → "x/300" (takes precedence so animation is always visible)
        // full     → "x weeks" (new streak count) in orange
        // idle     → "x weeks" (current/pending streak) in grey
        final String labelText;
        final ValueKey<String> labelKey;

        if (_isAnimating) {
          labelText = '${(p * kWeeklyXpThreshold).round()}/$kWeeklyXpThreshold';
          labelKey = const ValueKey('filling');
        } else if (widget.isActive) {
          labelText = widget.streakLabel;
          labelKey = const ValueKey('full');
        } else {
          labelText = widget.streakLabel;
          labelKey = const ValueKey('idle');
        }

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  size: 18, color: fgColor),
              const SizedBox(width: AppSpacing.xs),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  labelText,
                  key: labelKey,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Generic stat badge ───────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
