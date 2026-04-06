import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../providers/statistics_providers.dart' show moodHistoryProvider, refreshStatistics;
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

class LogbookDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> entry;
  /// Pre-resolved challenge title passed from the logbook list.
  final String title;

  const LogbookDetailPage({
    super.key,
    required this.entry,
    required this.title,
  });

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
      duration: const Duration(milliseconds: 400),
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
    return _isSuccess ? const Color(0xFF4CAF50) : cs.tertiary;
  }

  String _formatDate(String? timestamp) {
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

  String _localizedStatus(String? status) {
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

  IconData _emotionIcon(int? feeling) {
    switch (feeling) {
      case 0: return Icons.sentiment_very_dissatisfied;
      case 1: return Icons.sentiment_dissatisfied;
      case 2: return Icons.sentiment_neutral;
      case 3: return Icons.sentiment_satisfied;
      case 4: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  Color _emotionColor(int? feeling) {
    switch (feeling) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return Colors.amber;
      case 3: return Colors.lightGreen;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _emotionText(int? feeling) {
    final l = S.of(context);
    switch (feeling) {
      case 0: return l.veryBad;
      case 1: return l.bad;
      case 2: return l.neutral;
      case 3: return l.good;
      case 4: return l.veryGood;
      default: return l.unknown;
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _showDeleteDialog() {
    final l = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteEntry),
        content: Text(l.deleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          SyntraButton(
            onPressed: _deleteEntry,
            color: Theme.of(context).colorScheme.error,
            height: 40,
            depth: 3,
            child: Text(
              l.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry() async {
    try {
      await LogbookRepository.instance.deleteEntry(widget.entry['id'] as int);
      if (mounted) {
        refreshStatistics(ref);
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.of(context).logbookEntry),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(
                  title: widget.title,
                  earned: widget.entry['earned'] ?? 0,
                  status: widget.entry['status']?.toString(),
                  timestamp: widget.entry['timestamp']?.toString(),
                  rewardFactor: widget.entry['reward_factor'],
                  statusColor: _statusColor(context),
                  isSuccess: _isSuccess,
                  formatDate: _formatDate,
                  localizedStatus: _localizedStatus,
                ),
                const SizedBox(height: AppSpacing.md),
                _FeelingsRow(
                  feeling: widget.entry['feeling'] as int?,
                  perception: widget.entry['perception'] as int?,
                  emotionIcon: _emotionIcon,
                  emotionColor: _emotionColor,
                  emotionText: _emotionText,
                ),
                if (widget.entry['pre_anxiety'] != null &&
                    widget.entry['feeling'] != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _PredictionRealityGapCard(
                    preAnxiety: widget.entry['pre_anxiety'] as int,
                    feeling: widget.entry['feeling'] as int,
                    emotionIcon: _emotionIcon,
                    emotionColor: _emotionColor,
                    emotionText: _emotionText,
                  ),
                ],
                if (widget.entry['notes'] != null &&
                    widget.entry['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _NotesCard(notes: widget.entry['notes'].toString()),
                ],
                const SizedBox(height: AppSpacing.md),
                _MoodCard(
                  challengeId: widget.entry['challenge_id']?.toString() ?? '',
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildDeleteButton(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final cs = Theme.of(context).colorScheme;
    return TextButton.icon(
      icon: const Icon(Icons.delete_outline),
      label: Text(S.of(context).deleteEntry),
      style: TextButton.styleFrom(
        foregroundColor: cs.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _showDeleteDialog,
    );
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String title;
  final int earned;
  final String? status;
  final String? timestamp;
  final dynamic rewardFactor;
  final Color statusColor;
  final bool isSuccess;
  final String Function(String?) formatDate;
  final String Function(String?) localizedStatus;

  const _HeroCard({
    required this.title,
    required this.earned,
    required this.status,
    required this.timestamp,
    required this.rewardFactor,
    required this.statusColor,
    required this.isSuccess,
    required this.formatDate,
    required this.localizedStatus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accent strip
          Container(
            height: 4,
            color: statusColor,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Column(
              children: [
                // Icon
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
                // Title
                Text(
                  title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Date + status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(timestamp),
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
                        localizedStatus(status),
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
          // XP + reward factor row
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
                  '${earned >= 0 ? '+' : ''}$earned ${S.of(context).auraPoints}',
                  style: tt.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (rewardFactor != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 1,
                    height: 16,
                    color: cs.outlineVariant,
                  ),
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

// ─── Feelings row ─────────────────────────────────────────────────────────────

class _FeelingsRow extends StatelessWidget {
  final int? feeling;
  final int? perception;
  final IconData Function(int?) emotionIcon;
  final Color Function(int?) emotionColor;
  final String Function(int?) emotionText;

  const _FeelingsRow({
    required this.feeling,
    required this.perception,
    required this.emotionIcon,
    required this.emotionColor,
    required this.emotionText,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _FeelCard(
            label: l.howDidYouFeelQuestion,
            value: feeling,
            emotionIcon: emotionIcon,
            emotionColor: emotionColor,
            emotionText: emotionText,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _FeelCard(
            label: l.howPerceivedByOthers,
            value: perception,
            emotionIcon: emotionIcon,
            emotionColor: emotionColor,
            emotionText: emotionText,
          ),
        ),
      ],
    );
  }
}

class _FeelCard extends StatelessWidget {
  final String label;
  final int? value;
  final IconData Function(int?) emotionIcon;
  final Color Function(int?) emotionColor;
  final String Function(int?) emotionText;

  const _FeelCard({
    required this.label,
    required this.value,
    required this.emotionIcon,
    required this.emotionColor,
    required this.emotionText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = emotionColor(value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(emotionIcon(value), color: color, size: 26),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              emotionText(value),
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notes card ───────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_rounded, size: 18, color: cs.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  S.of(context).notes,
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: cs.primary, width: 3),
                ),
              ),
              child: Text(
                notes,
                style: tt.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Prediction-reality gap card ──────────────────────────────────────────────

class _PredictionRealityGapCard extends StatelessWidget {
  /// 1–5: 1 = gar nicht nervös, 5 = sehr nervös
  final int preAnxiety;
  /// 0–4: 0 = sehr schlecht, 4 = sehr gut
  final int feeling;
  final IconData Function(int?) emotionIcon;
  final Color Function(int?) emotionColor;
  final String Function(int?) emotionText;

  const _PredictionRealityGapCard({
    required this.preAnxiety,
    required this.feeling,
    required this.emotionIcon,
    required this.emotionColor,
    required this.emotionText,
  });

  // Convert pre_anxiety (1–5, nervousness) to the 0–4 feeling scale for comparison.
  // pre_anxiety=1 (gar nicht) → feeling=4 (sehr gut), pre_anxiety=5 (sehr nervös) → feeling=0 (sehr schlecht)
  int get _anxietyAsFeelingScale => (5 - preAnxiety).clamp(0, 4);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    // Positive gap: felt better than feared. Negative: worse than feared.
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
                Text(
                  l.predictionRealityGapTitle,
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Before
                Column(
                  children: [
                    Text(l.beforeLabel,
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: beforeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          emotionIcon(_anxietyAsFeelingScale),
                          color: beforeColor,
                          size: 26),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(emotionText(_anxietyAsFeelingScale),
                        style: tt.labelSmall
                            ?.copyWith(color: beforeColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.arrow_forward_rounded,
                    color: cs.outlineVariant, size: 20),
                // After
                Column(
                  children: [
                    Text(l.afterLabel,
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
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
                    Text(emotionText(feeling),
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
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood trend card ──────────────────────────────────────────────────────────

class _MoodCard extends ConsumerWidget {
  final String challengeId;
  const _MoodCard({required this.challengeId});

  static const _smileyLabels = ['😞', '😕', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(moodHistoryProvider(challengeId));
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (scores) {
        if (scores.length < 2) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;
        final spots = [
          for (var i = 0; i < scores.length; i++)
            FlSpot(i.toDouble(), scores[i].toDouble()),
        ];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart_rounded,
                        size: 18, color: cs.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      S.of(context).moodTrend,
                      style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: cs.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
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
            ),
          ),
        );
      },
    );
  }
}
