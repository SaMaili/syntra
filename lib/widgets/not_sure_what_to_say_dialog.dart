import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../theme/app_spacing.dart';

class NotSureWhatToSaySheet extends StatelessWidget {
  final List<String> hints;

  const NotSureWhatToSaySheet({super.key, required this.hints});

  static Future<void> show(BuildContext context, List<String> hints) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => NotSureWhatToSaySheet(hints: hints),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ───────────────────────────────────────────────────────
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
            const SizedBox(height: AppSpacing.lg),
    
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_outline,
                        color: Colors.amber, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    l10n.lostForWords,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
    
            // ── Hints ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hints
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(Icons.circle,
                                  size: 7,
                                  color: cs.primary),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(h, style: tt.bodyLarge),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
