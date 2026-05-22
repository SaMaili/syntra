import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Small uppercase grey label that sits above a [SettingsGroup].
///
/// 1:1 with the design's `SectionLabel`: 11 px Inter 700, 2 px tracking,
/// `cs.outline` color, 24 px top margin / 8 px bottom margin.
class SettingsSectionLabel extends StatelessWidget {
  final String label;
  const SettingsSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: cs.outline,
        ),
      ),
    );
  }
}

/// Rounded dark card that groups [SettingsRow]s under a [SettingsSectionLabel].
class SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A single settings row: leading icon, label + optional sublabel, trailing
/// widget (usually a `SyntraSwitch`, a chevron, or a value chip).
///
/// Adds a 1 px bottom divider unless [last] is true.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final bool last;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.sublabel,
    this.trailing,
    this.last = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final labelColor = isDark ? Colors.white : cs.onSurface;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: s.bg3, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: tt.titleSmall?.copyWith(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: labelColor,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// Value-on-the-right chip with a chevron — used for "Language: English →".
class SettingsRowValue extends StatelessWidget {
  final String value;
  final bool showChevron;
  const SettingsRowValue({super.key, required this.value, this.showChevron = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: tt.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showChevron) ...[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 16, color: cs.outline),
        ],
      ],
    );
  }
}
