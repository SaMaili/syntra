import 'package:flutter/material.dart';

import '../data/logbook_repository.dart';
import '../generated/l10n.dart';
import '../theme/app_spacing.dart';

class ChallengeInfoNotification {
  static Future<void> showLastNotesNotification(
    BuildContext context,
    String challengeId,
  ) async {
    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Clear any existing snackbars of the same type before showing a new one
    messenger.clearSnackBars();

    final result = await LogbookRepository.instance
        .lastNotesForChallenge(challengeId);

    String notes = '';
    String time = '';
    if (result != null) {
      notes = result['notes']?.toString() ?? '';
      time = result['timestamp']?.toString() ?? '';
    }

    String formattedTime = '';
    if (time.isNotEmpty) {
      try {
        final dt = DateTime.parse(time);
        formattedTime =
            '${dt.day.toString().padLeft(2, '0')}.'
            '${dt.month.toString().padLeft(2, '0')}.'
            '${dt.year}';
      } catch (_) {
        formattedTime = time;
      }
    }

    if (!context.mounted) return;

    if (notes.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noNotesYet)));
      return;
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius * 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: cs.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.challengeAlreadyCompleted,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Notes block ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  '"$notes"',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Date row ─────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.lastCompleted} $formattedTime',
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // ── Repeat note ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.repeatChallengeInfo,
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Action ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.okayButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
