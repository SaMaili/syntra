import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';

/// Card wrapper used by the redesigned Profile sections. Octarine title on
/// the left, optional muted hint on the right, dark surface + 1px outline
/// (matches the design's `Section` component).
class ProfileSection extends StatelessWidget {
  final String title;
  final String? right;
  final Widget child;

  const ProfileSection({
    super.key,
    required this.title,
    this.right,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final titleColor = isDark ? Colors.white : cs.onSurface;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
              ),
              if (right != null)
                Text(
                  right!,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
