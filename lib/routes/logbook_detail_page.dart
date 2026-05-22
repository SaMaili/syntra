// logbook_detail_page.dart — V2 slide-up sheet.
//
// Sections (top → bottom):
//   • Drag handle + date + close X
//   • Status eyebrow ("✓ Completed" / "✗ Tried") + big Octarine title
//   • Meta row (aura · time)
//   • Insight card (orange→pink gradient): plain-English headline + Before/After pills
//   • Reflection key/value list (feel + perception with colored dots)
//   • Optional note card (italic)
//   • Mood-trend mini chart (soft pink area)
//   • Delete button
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../providers/statistics_providers.dart'
    show moodHistoryProvider, refreshStatistics;
import '../theme/brand_colors.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_sheet.dart';
import 'logbook/field_rows.dart' show emotionColor, emotionIcon, emotionText;

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
      barrierColor: Colors.black.withValues(alpha: 0.55),
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => LogbookDetailPage(entry: entry, title: title),
    );
  }

  @override
  ConsumerState<LogbookDetailPage> createState() => _LogbookDetailPageState();
}

class _LogbookDetailPageState extends ConsumerState<LogbookDetailPage> {
  bool get _isSuccess => widget.entry['status']?.toString() == 'success';

  String _formatDate(BuildContext context, String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return S.of(context).unknown;
    try {
      final dt = DateTime.parse(timestamp);
      final l = S.of(context);
      final monthName = _monthName(dt.month, l);
      return '$monthName ${dt.day} ${dt.year} · '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  String _monthName(int month, S l) {
    switch (month) {
      case 1:
        return l.monthJanShort;
      case 2:
        return l.monthFebShort;
      case 3:
        return l.monthMarShort;
      case 4:
        return l.monthAprShort;
      case 5:
        return l.monthMayShort;
      case 6:
        return l.monthJunShort;
      case 7:
        return l.monthJulShort;
      case 8:
        return l.monthAugShort;
      case 9:
        return l.monthSepShort;
      case 10:
        return l.monthOctShort;
      case 11:
        return l.monthNovShort;
      default:
        return l.monthDecShort;
    }
  }

  Future<void> _confirmDelete() async {
    final l = S.of(context);
    final confirmed = await showSyntraSheet<bool>(
      context,
      useRootNavigator: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: cs.onErrorContainer,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.deleteEntry,
                textAlign: TextAlign.center,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                l.deleteEntryConfirm,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SyntraButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                color: cs.error,
                child: Text(l.delete, style: TextStyle(color: cs.onError)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  l.cancel,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;
    try {
      await LogbookRepository.instance.deleteEntry(widget.entry['id'] as int);
      if (!mounted) return;
      refreshStatistics(ref);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: syntraSheetDecoration(context),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kSyntraSheetRadius),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _SheetTop(
                  date: _formatDate(
                    context,
                    widget.entry['timestamp']?.toString(),
                  ),
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: _StatusHeader(
                  title: widget.title,
                  isSuccess: _isSuccess,
                  aura: (widget.entry['aura'] as int?) ?? 0,
                  durationSeconds: widget.entry['duration_seconds'] as int?,
                ),
              ),
              if (widget.entry['pre_anxiety'] != null &&
                  widget.entry['feeling'] != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: _InsightCard(
                      preAnxiety: widget.entry['pre_anxiety'] as int,
                      feeling: widget.entry['feeling'] as int,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _ReflectionCard(
                    feeling: widget.entry['feeling'] as int?,
                    perception: widget.entry['perception'] as int?,
                  ),
                ),
              ),
              if ((widget.entry['notes']?.toString() ?? '').trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: _NoteCard(note: widget.entry['notes'].toString()),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _MoodTrendCard(
                    challengeId: widget.entry['challenge_id']?.toString() ?? '',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(S.of(context).deleteEntry),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.viewPaddingOf(context).bottom + 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Drag handle + date + close ────────────────────────────────────────────

class _SheetTop extends StatelessWidget {
  final String date;
  final VoidCallback onClose;
  const _SheetTop({required this.date, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);
    final handleColor = s.bg4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Status header (eyebrow + big title + meta row) ────────────────────────

class _StatusHeader extends StatelessWidget {
  final String title;
  final bool isSuccess;
  final int aura;
  final int? durationSeconds;

  const _StatusHeader({
    required this.title,
    required this.isSuccess,
    required this.aura,
    required this.durationSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    const green = BrandColors.green;
    final titleColor = isDark ? Colors.white : cs.onSurface;
    final statusColor = isSuccess ? green : cs.tertiary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.self_improvement_rounded,
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                (isSuccess ? l.statusSuccess : l.statusTried).toUpperCase(),
                style: tt.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              height: 1.15,
              letterSpacing: -0.5,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _MetaItem(
                icon: Icons.star_rounded,
                iconColor: cs.primary,
                text: '+$aura ${l.auraPoints}',
                textColor: cs.primary,
                bold: true,
              ),
              if (durationSeconds != null && durationSeconds! > 0)
                _MetaItem(
                  icon: Icons.schedule_rounded,
                  iconColor: cs.onSurfaceVariant,
                  text: _fmtTime(durationSeconds!),
                  textColor: cs.onSurfaceVariant,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;
  final bool bold;

  const _MetaItem({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: tt.labelLarge?.copyWith(
            color: textColor,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Insight card (orange→pink gradient, before/after pills) ───────────────

class _InsightCard extends StatelessWidget {
  final int preAnxiety; // 1..5 (5 = very nervous)
  final int feeling; // 0..4 (4 = very satisfied)

  const _InsightCard({required this.preAnxiety, required this.feeling});

  // Map pre_anxiety (1..5 with 5=nervous) onto the satisfaction scale (0..4
  // with 4=calm). Higher pre_anxiety → lower satisfaction equivalent.
  int get _beforeIdx => (5 - preAnxiety).clamp(0, 4);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;
    const orange = BrandColors.orange;

    final gap = feeling - _beforeIdx;
    final String headline;
    if (gap > 0) {
      headline = l.logbookInsightBetter;
    } else if (gap < 0) {
      headline = l.logbookInsightWorse;
    } else {
      headline = l.logbookInsightMatched;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            orange.withValues(alpha: 0.16),
            cs.primary.withValues(alpha: 0.16),
          ],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.28), width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.logbookInsightEyebrow.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: tt.titleMedium?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.3,
              color: fg,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _BeforeAfterPill(label: l.beforeLabel, idx: _beforeIdx),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_rounded,
                color: cs.primary.withValues(alpha: 0.85),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BeforeAfterPill(label: l.afterLabel, idx: feeling),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterPill extends StatelessWidget {
  final String label;
  final int idx;
  const _BeforeAfterPill({required this.label, required this.idx});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    final bg = isDark ? s.bg2 : s.bg1;
    final color = emotionColor(idx);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.55),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Icon(emotionIcon(idx), color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            emotionText(context, idx),
            style: tt.labelLarge?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reflection key/value card ─────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final int? feeling;
  final int? perception;

  const _ReflectionCard({required this.feeling, required this.perception});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final bg = s.bg1;
    final border = s.bg3;

    if (feeling == null && perception == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.logbookReflectionEyebrow.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          if (feeling != null)
            _KvRow(
              k: l.howDidYouFeelQuestion,
              v: emotionText(context, feeling),
              tint: emotionColor(feeling),
            ),
          if (perception != null)
            _KvRow(
              k: l.howPerceivedByOthers,
              v: emotionText(context, perception),
              tint: emotionColor(perception),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  final String k;
  final String v;
  final Color tint;
  final bool isLast;

  const _KvRow({
    required this.k,
    required this.v,
    required this.tint,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);
    final divider = s.warmTint;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tint.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                v,
                style: tt.labelLarge?.copyWith(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: tint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Note card (italic body) ───────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final String note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final fg = isDark ? Colors.white : cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3, width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.logbookNoteEyebrow.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$note"',
            style: tt.titleSmall?.copyWith(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mood-trend mini area chart ────────────────────────────────────────────

class _MoodTrendCard extends ConsumerWidget {
  final String challengeId;
  const _MoodTrendCard({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(moodHistoryProvider(challengeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (scores) {
        if (scores.length < 2) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: s.bg1,
            border: Border.all(color: s.bg3, width: 1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      l.logbookMoodTrendEyebrow.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    l.lastNCount(scores.length),
                    style: tt.labelSmall?.copyWith(
                      color: cs.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: CustomPaint(
                  size: const Size.fromHeight(80),
                  painter: _MoodAreaPainter(
                    values: scores.map((s) => s.toDouble()).toList(),
                    line: cs.primary,
                    baseline: isDark ? s.bg4 : s.bg3,
                  ),
                  child: const SizedBox(width: double.infinity),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoodAreaPainter extends CustomPainter {
  final List<double> values;
  final Color line;
  final Color baseline;

  _MoodAreaPainter({
    required this.values,
    required this.line,
    required this.baseline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const padding = 4.0;
    final w = size.width;
    final h = size.height;
    final n = values.length;
    final stepX = n > 1 ? (w - padding * 2) / (n - 1) : 0.0;

    double yFor(double v) =>
        padding + (1 - (v.clamp(0, 4)) / 4) * (h - padding * 2);

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final x = padding + i * stepX;
      final y = yFor(values[i]);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }

    final areaPath = Path.from(dataPath)
      ..lineTo(padding + (n - 1) * stepX, h)
      ..lineTo(padding, h)
      ..close();

    // Dashed neutral baseline (y at value=2).
    final baselineY = yFor(2);
    final basePaint = Paint()
      ..color = baseline
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 3.0;
    final span = w - padding * 2;
    final count = (span / (dash + gap)).floor();
    for (int i = 0; i < count; i++) {
      final x0 = padding + i * (dash + gap);
      canvas.drawLine(
        Offset(x0, baselineY),
        Offset(x0 + dash, baselineY),
        basePaint,
      );
    }

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [line.withValues(alpha: 0.35), line.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, linePaint);
  }

  @override
  bool shouldRepaint(_MoodAreaPainter old) =>
      old.values != values || old.line != line || old.baseline != baseline;
}
