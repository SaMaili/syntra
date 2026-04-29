import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A card with a consistent header (icon + title) used across detail screens.
/// Eliminates duplication of the Card+Padding+header-Row pattern.
class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  /// Optional widget rendered at the trailing edge of the header row
  /// (e.g. a date or a count).
  final Widget? trailing;

  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
