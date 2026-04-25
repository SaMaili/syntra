import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_spacing.dart';

class LogbookNotesCard extends StatelessWidget {
  final String notes;

  const LogbookNotesCard({super.key, required this.notes});

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
