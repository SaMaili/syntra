import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../challenge_ui.dart';
import '../generated/l10n.dart';
import '../providers/note_providers.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import 'statistics/average_mood_card.dart' show MoodAreaPainter;
import '../widgets/detail_card.dart';
import '../widgets/prediction_gap_card.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_sheet.dart';

/// Shows the challenge detail as a slide-up modal bottom sheet.
Future<bool?> showChallengeDetailSheet(
  BuildContext context,
  Challenge challenge,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (_) => ChallengeDetailSheet(challenge: challenge),
  );
}

/// Slide-up panel showing full challenge details.
class ChallengeDetailSheet extends ConsumerWidget {
  final Challenge challenge;

  const ChallengeDetailSheet({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final isDone = ref.watch(isChallengeCompletedProvider(challenge.id));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: syntraSheetDecoration(context),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Drag handle ─────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: SyntraSheetHandle(),
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
                    const Icon(
                      Icons.check_circle_rounded,
                      color: BrandColors.green,
                      size: 22,
                    ),
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

                    const SizedBox(height: AppSpacing.xl),
                    _InsightsCard(challengeId: challenge.id),
                    const SizedBox(height: AppSpacing.md),
                    _LastNoteCard(challengeId: challenge.id),

                    if (challenge.hints.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _HintsCard(hints: challenge.hints),
                    ],

                    const SizedBox(height: AppSpacing.md),
                    _MoodChartCard(challengeId: challenge.id),
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
      ),
    );
  }
}

// ─── Hints card ───────────────────────────────────────────────────────────────

class _HintsCard extends StatelessWidget {
  final List<String> hints;
  const _HintsCard({required this.hints});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DetailCard(
      icon: Icons.lightbulb_outline_rounded,
      title: S.of(context).challengeHintsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hints
            .map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '• $h',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Last note card ───────────────────────────────────────────────────────────

String _formatDayMonthYear(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  } catch (_) {
    return raw;
  }
}

class _LastNoteCard extends ConsumerWidget {
  final String challengeId;
  const _LastNoteCard({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(lastNoteProvider(challengeId))
        .when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (data) {
            final notes = data?['notes']?.toString() ?? '';
            if (notes.isEmpty) return const SizedBox.shrink();

            final cs = Theme.of(context).colorScheme;
            final tt = Theme.of(context).textTheme;
            final formattedDate = _formatDayMonthYear(
              data?['timestamp']?.toString(),
            );

            return DetailCard(
              icon: Icons.sticky_note_2_rounded,
              title: S.of(context).lastNoteTitle,
              trailing: formattedDate.isEmpty
                  ? null
                  : Text(
                      formattedDate,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
              child: Text(
                '"$notes"',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            );
          },
        );
  }
}

// ─── Mood trend chart card ────────────────────────────────────────────────────

class _MoodChartCard extends ConsumerWidget {
  final String challengeId;
  const _MoodChartCard({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(moodHistoryProvider(challengeId));
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (scores) {
        if (scores.length < 2) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        final l = S.of(context);
        final values = scores.map((s) => s.toDouble()).toList();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DetailCard(
          icon: Icons.mood_rounded,
          title: S.of(context).moodTrend,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 80,
                child: CustomPaint(
                  painter: MoodAreaPainter(
                    values: values,
                    line: cs.primary,
                    baseline: isDark
                        ? SyntraSurface.dark.bg4
                        : SyntraSurface.light.bg3,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.moodAgoLabel(values.length),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                  Text(
                    l.moodTodayLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
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

    final chips = <({IconData? icon, String label, Color bg})>[
      (
        icon: Icons.timer_outlined,
        label: fmtTime(challenge.time),
        bg: cs.secondaryContainer,
      ),
      (
        icon: Icons.emoji_events_outlined,
        label: '+${challenge.aura} ${l.auraPoints}',
        bg: cs.primaryContainer,
      ),
      (
        icon: Icons.shield_outlined,
        label: 'L${challenge.level}',
        bg: cs.surfaceContainerHighest,
      ),
      (
        icon: challenge.typeIcon,
        label: challenge.typeLabel(l),
        bg: cs.surfaceContainerHighest,
      ),
      if (challenge.environment != ChallengeEnvironment.all &&
          challenge.environment.isNotEmpty)
        (
          icon: null,
          label: challenge.environmentLabel(l),
          bg: cs.surfaceContainerHighest,
        ),
      if (challenge.flirt)
        (
          icon: Icons.favorite_rounded,
          label: 'Flirt',
          bg: cs.secondaryContainer,
        ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips
          .map(
            (c) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Insights card ────────────────────────────────────────────────────────────

class _InsightsCard extends StatelessWidget {
  final String challengeId;
  const _InsightsCard({required this.challengeId});

  @override
  Widget build(BuildContext context) {
    return PredictionGapCard(challengeId: challengeId);
  }
}
