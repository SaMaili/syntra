import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_spacing.dart';

// ─── Emotion helpers (package-visible so other logbook widgets can import) ────

IconData emotionIcon(int? feeling) {
  switch (feeling) {
    case 0: return Icons.sentiment_very_dissatisfied;
    case 1: return Icons.sentiment_dissatisfied;
    case 2: return Icons.sentiment_neutral;
    case 3: return Icons.sentiment_satisfied;
    case 4: return Icons.sentiment_very_satisfied;
    default: return Icons.sentiment_neutral;
  }
}

Color emotionColor(int? feeling) {
  switch (feeling) {
    case 0: return Colors.red;
    case 1: return Colors.orange;
    case 2: return Colors.amber;
    case 3: return Colors.lightGreen;
    case 4: return Colors.green;
    default: return Colors.grey;
  }
}

String emotionText(BuildContext context, int? feeling) {
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

// ─── Feelings row ─────────────────────────────────────────────────────────────

class LogbookFeelingsRow extends StatelessWidget {
  final int? feeling;
  final int? perception;

  const LogbookFeelingsRow({
    super.key,
    required this.feeling,
    required this.perception,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _FeelCard(label: l.howDidYouFeelQuestion, value: feeling),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _FeelCard(label: l.howPerceivedByOthers, value: perception),
        ),
      ],
    );
  }
}

class _FeelCard extends StatelessWidget {
  final String label;
  final int? value;

  const _FeelCard({required this.label, required this.value});

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
              emotionText(context, value),
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
