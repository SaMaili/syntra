import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/shop_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_progress_bar.dart';

/// Hero header shown at the top of the challenges screen.
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
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + inline stat counts ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l.navChallenge,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.emoji_events_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: Text(
                  '$availableXp',
                  key: ValueKey(availableXp),
                  style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ),
              if (freezes > 0) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.ac_unit_rounded, size: 14, color: cs.tertiary),
                const SizedBox(width: 2),
                Text(
                  '×$freezes',
                  style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.tertiary),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Full-width streak bar ───────────────────────────────────────────
          StreakBar(
            isActive: isStreakActive,
            progress: progress,
            currentWeekXp: currentWeekXp,
            streakLabel: '$displayStreak ${l.weeksShort}',
          ),
        ],
      ),
    );
  }
}

// ─── Streak bar ───────────────────────────────────────────────────────────────

class StreakBar extends StatefulWidget {
  final bool isActive;
  final double progress;
  final int currentWeekXp;
  final String streakLabel;
  final double labelOpacity;

  const StreakBar({
    super.key,
    required this.isActive,
    required this.progress,
    required this.currentWeekXp,
    required this.streakLabel,
    this.labelOpacity = 1.0,
  });

  @override
  State<StreakBar> createState() => _StreakBarState();
}

class _StreakBarState extends State<StreakBar> {
  int _prevXp = 0;

  @override
  void didUpdateWidget(StreakBar old) {
    super.didUpdateWidget(old);
    if (old.currentWeekXp != widget.currentWeekXp) {
      setState(() => _prevXp = old.currentWeekXp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final labelColor = widget.isActive ? const Color(0xFFFF6D00) : cs.onSurfaceVariant;
    final barColor = cs.primary;

    return Opacity(
      opacity: widget.labelOpacity,
      child: Row(
        children: [
          // Fire icon + streak label
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded, size: 15, color: labelColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.streakLabel,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: labelColor),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Animated progress track
          Expanded(
            child: SyntraXpBar(
              value: widget.progress,
              initialValue: (_prevXp / kWeeklyXpThreshold).clamp(0.0, 1.0),
              minHeight: 5,
              color: barColor,
              backgroundColor: cs.surfaceContainerHighest,
              silent: true,
            ),
          ),

          // XP counter — counts up from previous value
          const SizedBox(width: AppSpacing.sm),
          TweenAnimationBuilder<int>(
            key: ValueKey('$_prevXp→${widget.currentWeekXp}'),
            tween: IntTween(begin: _prevXp, end: widget.currentWeekXp),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '$value/$kWeeklyXpThreshold',
              style: tt.labelSmall?.copyWith(color: cs.outline),
            ),
          ),
        ],
      ),
    );
  }
}
