import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';

// ─── Dot progress indicator ──────────────────────────────────────────────────

class DotIndicator extends StatelessWidget {
  final int page;
  final int total;
  const DotIndicator({required this.page, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(total, (i) {
        final active = i == page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page base template ───────────────────────────────────────────────────────

class OnboardingPage extends StatelessWidget {
  final Widget icon;
  final String headline;
  final String subtext;
  final Widget? extra;
  final String buttonLabel;
  final VoidCallback onButton;

  const OnboardingPage({
    required this.icon,
    required this.headline,
    required this.subtext,
    this.extra,
    required this.buttonLabel,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 2),
          icon,
          const SizedBox(height: AppSpacing.xl),
          Text(
            headline,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtext,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (extra != null) ...[
            const SizedBox(height: AppSpacing.xl),
            extra!,
          ],
          const Spacer(flex: 3),
          SyntraButton(
            onPressed: onButton,
            child: Text(buttonLabel),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Icon circle illustration helper ─────────────────────────────────────────

Widget iconCircle(BuildContext context, IconData icon, {Color? bg}) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: bg ?? cs.primaryContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 64, color: cs.onPrimaryContainer),
  );
}

// ─── Step row (used in page 2) ────────────────────────────────────────────────

class StepRow extends StatelessWidget {
  final int number;
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const StepRow({
    required this.number,
    required this.icon,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primaryContainer,
          child: Text('$number',
              style: TextStyle(
                  color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: AppSpacing.md),
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Level card (used in page 4) ─────────────────────────────────────────────

class LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color color;
  final ColorScheme cs;
  final VoidCallback onTap;

  const LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.color,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: selected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Slot chip (used in page 6) ───────────────────────────────────────────────

class SlotChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final bool selected;
  final Color color;
  final ColorScheme cs;
  final VoidCallback onTap;

  const SlotChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.selected,
    required this.color,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : cs.onSurfaceVariant, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : cs.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(time,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
