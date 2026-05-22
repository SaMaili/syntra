import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';

/// Brand pill chip — reusable for tab filters, vibe selectors, etc.
///
/// Active state: pink gradient (`cs.primary`) with a soft glow, `cs.onPrimary`
/// text. Inactive: a dark-token surface (`#161616` / `#F5F2F0`) with muted
/// text. Layout: optional leading icon, label, optional trailing count.
///
/// 1:1 with the design tokens:
///   dark inactive bg: #161616  ·  light inactive bg: #F5F2F0
///   active gradient: linear-gradient(135deg, #FF6BF6, #FF10F0)
class SyntraChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  final String label;
  final int? count;
  final IconData? icon;
  final SyntraChipSize size;

  const SyntraChip({
    super.key,
    required this.active,
    required this.onTap,
    required this.label,
    this.count,
    this.icon,
    this.size = SyntraChipSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final s = SyntraSurface.of(context);

    final pad = size == SyntraChipSize.sm
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    final fontSize = size == SyntraChipSize.sm ? 12.0 : 13.0;

    final inactiveBg = s.bg2;
    final inactiveFg = cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: pad,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.92),
                    cs.primary,
                  ],
                )
              : null,
          color: active ? null : inactiveBg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize,
                color: active ? Colors.white : inactiveFg,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : inactiveFg,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: tt.labelMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: (active ? Colors.white : inactiveFg)
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum SyntraChipSize { sm, md }
