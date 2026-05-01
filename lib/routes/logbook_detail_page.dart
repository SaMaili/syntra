import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../providers/prediction_gap_providers.dart';
import '../providers/statistics_providers.dart' show refreshStatistics;
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/prediction_gap_card.dart';
import '../widgets/syntra_button.dart';
import 'logbook/field_rows.dart';
import 'logbook/mood_display.dart';
import 'logbook/notes_section.dart';

class LogbookDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> entry;
  final String title;

  const LogbookDetailPage({
    super.key,
    required this.entry,
    required this.title,
  });

  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic> entry,
    String title,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogbookDetailPage(entry: entry, title: title),
    );
  }

  @override
  ConsumerState<LogbookDetailPage> createState() => _LogbookDetailPageState();
}

class _LogbookDetailPageState extends ConsumerState<LogbookDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool get _isSuccess => widget.entry['status']?.toString() == 'success';

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _isSuccess ? AppTheme.successGreen : cs.tertiary;
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _showDeleteDialog() {
    final l = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: cs.onErrorContainer, size: 28),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.deleteEntry,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    l.deleteEntryConfirm,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SyntraButton(
                    onPressed: _deleteEntry,
                    color: cs.error,
                    height: 52,
                    child: Text(l.delete, style: TextStyle(color: cs.onError)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l.cancel,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry() async {
    try {
      await LogbookRepository.instance.deleteEntry(widget.entry['id'] as int);
      if (mounted) {
        refreshStatistics(ref);
        Navigator.of(context).pop(); // close dialog
        Navigator.of(context).pop(true); // close sheet with result
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Material(
          color: cs.surface,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // ── Sheet header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.xs, 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 40), // balance close button
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: cs.outlineVariant,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              S.of(context).logbookEntry,
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                // ── Scrollable content ────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroCard(
                          entry: widget.entry,
                          title: widget.title,
                          statusColor: _statusColor(context),
                          isSuccess: _isSuccess,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LogbookFeelingsRow(
                          feeling: widget.entry['feeling'] as int?,
                          perception: widget.entry['perception'] as int?,
                        ),
                        if (widget.entry['pre_anxiety'] != null &&
                            widget.entry['feeling'] != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _PredictionRealityGapCard(
                            preAnxiety: widget.entry['pre_anxiety'] as int,
                            feeling: widget.entry['feeling'] as int,
                          ),
                        ],
                        if (widget.entry['notes'] != null &&
                            widget.entry['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          LogbookNotesCard(
                            notes: widget.entry['notes'].toString(),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        LogbookMoodChartCard(
                          challengeId:
                              widget.entry['challenge_id']?.toString() ?? '',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsightsCard(context),
                        const SizedBox(height: AppSpacing.xl),
                        _buildDeleteButton(),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    final challengeId = widget.entry['challenge_id']?.toString() ?? '';

    return ref.watch(predictionGapProvider(challengeId)).when(
      data: (insight) {
        if (insight == null) return const SizedBox.shrink();
        return PredictionGapCard(insight: insight);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDeleteButton() {
    final cs = Theme.of(context).colorScheme;
    return TextButton.icon(
      icon: const Icon(Icons.delete_outline),
      label: Text(S.of(context).deleteEntry),
      style: TextButton.styleFrom(
        foregroundColor: cs.error,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _showDeleteDialog,
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String title;
  final Color statusColor;
  final bool isSuccess;

  const _HeroCard({
    required this.entry,
    required this.title,
    required this.statusColor,
    required this.isSuccess,
  });

  String _formatDate(BuildContext context, String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return S.of(context).unknown;
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year}';
    } catch (_) {
      return timestamp;
    }
  }

  String _localizedStatus(BuildContext context, String? status) {
    final l = S.of(context);
    switch (status) {
      case 'success':
        return l.statusSuccess;
      case 'tried':
        return l.statusTried;
      default:
        return status ?? l.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final earned = entry['aura'] ?? 0;
    final rewardFactor = entry['reward_factor'];

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: statusColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.emoji_events_rounded
                        : Icons.directions_run_rounded,
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(context, entry['timestamp']?.toString()),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _localizedStatus(context, entry['status']?.toString()),
                        style: tt.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: cs.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: statusColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${earned >= 0 ? '+' : ''}$earned ${l.auraPoints}',
                  style: tt.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rewardFactor != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Container(width: 1, height: 16, color: cs.outlineVariant),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.trending_up_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${(rewardFactor * 100).toInt()}%',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l.rewardFactor,
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prediction-reality gap card ──────────────────────────────────────────────

class _PredictionRealityGapCard extends StatelessWidget {
  final int preAnxiety;
  final int feeling;

  const _PredictionRealityGapCard({
    required this.preAnxiety,
    required this.feeling,
  });

  int get _anxietyAsFeelingScale => (5 - preAnxiety).clamp(0, 4);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final gap = feeling - _anxietyAsFeelingScale;
    final String insight;
    if (gap > 0) {
      insight = l.gapPositive;
    } else if (gap < 0) {
      insight = l.gapNegative;
    } else {
      insight = l.gapNeutral;
    }

    final beforeColor = emotionColor(_anxietyAsFeelingScale);
    final afterColor = emotionColor(feeling);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, size: 18, color: cs.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l.predictionRealityGapTitle,
                    style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(l.beforeLabel,
                        style:
                            tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: beforeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(emotionIcon(_anxietyAsFeelingScale),
                          color: beforeColor, size: 26),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(emotionText(context, _anxietyAsFeelingScale),
                        style: tt.labelSmall?.copyWith(
                            color: beforeColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward_rounded,
                    color: cs.outlineVariant, size: 20),
                Column(
                  children: [
                    Text(l.afterLabel,
                        style:
                            tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: afterColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(emotionIcon(feeling),
                          color: afterColor, size: 26),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(emotionText(context, feeling),
                        style: tt.labelSmall?.copyWith(
                            color: afterColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                insight,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
