import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../generated/l10n.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

/// Shows the challenge detail as a slide-up modal bottom sheet.
Future<bool?> showChallengeDetailSheet(
  BuildContext context,
  Challenge challenge,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChallengeDetailSheet(challenge: challenge),
  );
}

/// Slide-up panel showing full challenge details.
class ChallengeDetailSheet extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeDetailSheet({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final isDone = ref
        .watch(completedChallengeIdsProvider)
        .valueOrNull
        ?.contains(challenge.id) ??
        false;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                if (isDone) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 22),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Scrollable body ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TagChips(challenge: challenge),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    challenge.description,
                    style: tt.bodyLarge?.copyWith(height: 1.6),
                  ),

                  if (challenge.hints.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l.notSureWhatToSay,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: challenge.hints
                            .map((h) => Text(
                                  '• $h',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSecondaryContainer,
                                    height: 1.5,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  _MoodChart(challengeId: challenge.id),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── Pinned launch button ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: SyntraButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icons.rocket_launch_rounded,
              label: Text(l.letsGo),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood trend chart ─────────────────────────────────────────────────────────

class _MoodChart extends ConsumerWidget {
  final String challengeId;
  const _MoodChart({required this.challengeId});

  static const _smileyLabels = ['😞', '😕', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(moodHistoryProvider(challengeId));
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (scores) {
        if (scores.length < 2) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final spots = [
          for (var i = 0; i < scores.length; i++)
            FlSpot(i.toDouble(), scores[i].toDouble()),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).moodTrend,
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 4,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 2,
                        getTitlesWidget: (v, _) => Text(
                          _smileyLabels[v.round().clamp(0, 4)],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: cs.primary,
                      barWidth: 2.5,
                      dotData: FlDotData(show: spots.length <= 10),
                      belowBarData: BarAreaData(
                        show: true,
                        color: cs.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Tag / meta chips ─────────────────────────────────────────────────────────

class _TagChips extends StatelessWidget {
  final Challenge challenge;
  const _TagChips({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    String fmtTime(int s) {
      if (s < 60) return '${s}s';
      final m = s ~/ 60;
      final r = s % 60;
      return r == 0 ? '${m}m' : '${m}m ${r}s';
    }

    String envLabel(String e) => switch (e) {
          'street' => l.filterEnvStreet,
          'transit' => l.filterEnvTransit,
          'cafe' => l.filterEnvCafe,
          'event' => l.filterEnvEvent,
          _ => '',
        };

    final chips = <({IconData? icon, String label, Color bg})>[
      (
        icon: Icons.timer_outlined,
        label: fmtTime(challenge.time),
        bg: cs.secondaryContainer
      ),
      (
        icon: Icons.emoji_events_outlined,
        label: '+${challenge.xp} ${l.auraPoints}',
        bg: cs.primaryContainer
      ),
      (
        icon: Icons.shield_outlined,
        label: 'L${challenge.level}',
        bg: cs.surfaceContainerHighest
      ),
      (
        icon: switch (challenge.type) {
          'group' => Icons.group_outlined,
          'coop' => Icons.people_alt_outlined,
          'dare' => Icons.bolt_outlined,
          _ => Icons.person_outlined,
        },
        label: switch (challenge.type) {
          'group' => l.group,
          'coop' => l.coop,
          'dare' => l.dare,
          _ => l.solo,
        },
        bg: cs.surfaceContainerHighest,
      ),
      if (challenge.environment != 'all' && challenge.environment.isNotEmpty)
        (
          icon: null,
          label: envLabel(challenge.environment),
          bg: cs.surfaceContainerHighest
        ),
      if (challenge.flirt)
        (
          icon: Icons.favorite_rounded,
          label: 'Flirt',
          bg: cs.secondaryContainer
        ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips
          .map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.icon != null) ...[
                      Icon(c.icon, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      c.label,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
