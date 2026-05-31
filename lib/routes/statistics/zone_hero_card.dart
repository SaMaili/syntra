import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../providers/settings_providers.dart';
import '../../providers/statistics_providers.dart' show czlCompletionsProvider;
import '../../theme/app_spacing.dart';
import '../../theme/brand_colors.dart';
import '../../widgets/syntra_button.dart';
import '../../widgets/syntra_sheet.dart';

/// Profile hero: a full-bleed gradient card representing the user's current
/// Comfort Zone — name, one-line description, and progress toward the next
/// level. Tap → opens an info sheet about the zone. Manual level changes now
/// live on the [ZoneLadder] below it (tap a bar to inspect / downgrade).
class ZoneHeroCard extends ConsumerWidget {
  const ZoneHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(comfortZoneLevelProvider);
    final completions = ref.watch(czlCompletionsProvider);
    final isMax = level >= ComfortZoneLogic.maxLevel;
    final needed = ComfortZoneLogic.completionsNeeded(level);
    final progress = isMax ? 1.0 : (completions / needed).clamp(0.0, 1.0);

    final gradient = ComfortZoneLogic.levelGradient(level);
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final levelName =
        ComfortZoneLogic.levelNames[level.clamp(1, ComfortZoneLogic.maxLevel)];
    final nextLevelName = isMax
        ? null
        : ComfortZoneLogic.levelNames[(level + 1).clamp(
            1,
            ComfortZoneLogic.maxLevel,
          )];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showZoneInfoSheet(context, ref, level),
        child: Ink(
          decoration: BoxDecoration(
            // Clean two-stop zone gradient — no dark stop. The corner
            // dimming in the JSX prototype used `rgba(0,0,0,.4) 130%` which
            // is out-of-range in Flutter (stops must be 0..1) and stamped
            // a dark blob on the bottom-right.
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradient.colors.first, gradient.colors.last],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withValues(alpha: 0.20),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft top-right white sparkle.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const RadialGradient(
                        center: Alignment(0.6, -0.6),
                        radius: 0.7,
                        colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.comfortZoneLevel} · ${l.levelN(level)}'
                          .toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      levelName,
                      style: tt.displaySmall?.copyWith(
                        fontFamily: 'Octarine',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isMax)
                      Text(
                        l.reachedTheTop,
                        style: tt.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      )
                    else if (nextLevelName == null)
                      Text(
                        l.completionsToLevel(completions, needed, level + 1),
                        style: tt.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      )
                    else
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            l.completionsToLevel(completions, needed, level + 1),
                            style: tt.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              nextLevelName,
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!isMax) ...[
                      const SizedBox(height: 18),
                      _ProgressRow(
                        level: level,
                        completions: completions,
                        needed: needed,
                        progress: progress,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final int level;
  final int completions;
  final int needed;
  final double progress;

  const _ProgressRow({
    required this.level,
    required this.completions,
    required this.needed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final labelStyle = tt.labelSmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.85),
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.levelN(level), style: labelStyle),
            Text('$completions / $needed', style: labelStyle),
            Text(l.levelN(level + 1), style: labelStyle),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6,
            color: Colors.black.withValues(alpha: 0.25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact "zone ladder" — one bar per level (1..10). Reached levels show the
/// zone's gradient; the current level is taller and glows.
class ZoneLadder extends ConsumerWidget {
  const ZoneLadder({super.key});

  /// Tapping a bar opens that level's sheet. Manual *upgrades* aren't allowed,
  /// so the current level and anything above it just show the info sheet;
  /// lower levels open the downgrade flow.
  void _onBarTap(BuildContext context, WidgetRef ref, int level, int current) {
    if (level < current) {
      showDowngradeSheet(context, ref, level);
    } else {
      showZoneInfoSheet(context, ref, level);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(comfortZoneLevelProvider);
    final cs = Theme.of(context).colorScheme;
    final restColor = SyntraSurface.of(context).bg3;

    // Stretch each cell to the full height so the whole column — not just the
    // few-pixel bar — is a tap target; the bar is bottom-aligned within it.
    return SizedBox(
      height: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 1; i <= ComfortZoneLogic.maxLevel; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < ComfortZoneLogic.maxLevel ? 4 : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _onBarTap(context, ref, i, current),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _LadderBar(
                        level: i,
                        reached: i <= current,
                        current: i == current,
                        restColor: restColor,
                        glow: cs.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LadderBar extends StatelessWidget {
  final int level;
  final bool reached;
  final bool current;
  final Color restColor;
  final Color glow;

  const _LadderBar({
    required this.level,
    required this.reached,
    required this.current,
    required this.restColor,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = ComfortZoneLogic.levelGradient(level);
    final height = current ? 28.0 : (reached ? 18.0 : 8.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: height,
      decoration: BoxDecoration(
        gradient: reached ? gradient : null,
        color: reached ? null : restColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: current
            ? [
                BoxShadow(
                  color: gradient.colors.last.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
    );
  }
}

// ─── Sheets ──────────────────────────────────────────────────────────────────

/// Opens an info sheet describing the given comfort-zone level.
Future<void> showZoneInfoSheet(
  BuildContext context,
  WidgetRef ref,
  int level,
) async {
  await showSyntraSheet<void>(
    context,
    builder: (ctx) => _ZoneInfoSheet(level: level),
  );
}

/// Opens the downgrade sheet for [level] (always strictly below the current
/// level). Shows the target level's identity, then requires a confirmation
/// dialog before actually stepping the user down.
Future<void> showDowngradeSheet(
  BuildContext context,
  WidgetRef ref,
  int level,
) async {
  await showSyntraSheet<void>(
    context,
    builder: (ctx) => _DowngradeSheet(level: level),
  );
}

/// Two-step gate: the user explicitly opted to drop a level, now confirm it.
Future<bool> _confirmDowngrade(BuildContext context, int level) {
  final l = S.of(context);
  return showSyntraConfirmDialog(
    context,
    title: l.levelDownTitle,
    message: '${l.levelN(level)} — ${l.levelDownBody}',
    confirmLabel: l.levelDownConfirm,
    cancelLabel: l.levelDownCancel,
    destructive: true,
  );
}

String _levelName(S l, int level) => switch (level) {
  1 => l.levelName1,
  2 => l.levelName2,
  3 => l.levelName3,
  4 => l.levelName4,
  5 => l.levelName5,
  6 => l.levelName6,
  7 => l.levelName7,
  8 => l.levelName8,
  9 => l.levelName9,
  _ => l.levelName10,
};

String _levelDesc(S l, int level) => switch (level) {
  1 => l.levelDesc1,
  2 => l.levelDesc2,
  3 => l.levelDesc3,
  4 => l.levelDesc4,
  5 => l.levelDesc5,
  6 => l.levelDesc6,
  7 => l.levelDesc7,
  8 => l.levelDesc8,
  9 => l.levelDesc9,
  _ => l.levelDesc10,
};

class _ZoneInfoSheet extends StatelessWidget {
  final int level;
  const _ZoneInfoSheet({required this.level});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final gradient = ComfortZoneLogic.levelGradient(level);
    final icon = ComfortZoneLogic
        .levelIcons[level.clamp(1, ComfortZoneLogic.levelIcons.length - 1)];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
            ),
            child: Icon(icon, size: 44, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _levelName(l, level),
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(
              l.levelN(level),
              style: tt.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              _levelDesc(l, level),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SyntraButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.letsGoButton),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Per-level sheet shown when the user taps a ladder bar *below* their current
/// level. Identical identity block to [_ZoneInfoSheet], plus a destructive
/// "Downgrade to Level N" action gated behind [_confirmDowngrade].
class _DowngradeSheet extends ConsumerWidget {
  final int level;
  const _DowngradeSheet({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final gradient = ComfortZoneLogic.levelGradient(level);
    final icon = ComfortZoneLogic
        .levelIcons[level.clamp(1, ComfortZoneLogic.levelIcons.length - 1)];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
            ),
            child: Icon(icon, size: 44, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _levelName(l, level),
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(
              l.levelN(level),
              style: tt.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              _levelDesc(l, level),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SyntraButton(
              color: cs.error,
              onPressed: () async {
                final confirmed = await _confirmDowngrade(context, level);
                if (!confirmed || !context.mounted) return;
                await ref
                    .read(comfortZoneLevelProvider.notifier)
                    .setLevel(level);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l.downgradeToLevel(level)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
