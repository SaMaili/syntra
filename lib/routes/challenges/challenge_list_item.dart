import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../providers/challenge_providers.dart';
import '../../routes/challenge_detail_screen.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/brand_colors.dart';
import '../../widgets/syntra_button.dart';

/// V2 challenge card: tap-to-focus, level stripe on the leading edge,
/// single meta row, icon cluster on the right, and reveal-on-focus actions.
///
/// Focus animation follows the design system (`ChallengeCard.jsx`): a single
/// controller drives the surface fill, border, stripe glow and the action-row
/// reveal so they stay in lockstep. Timing is intentionally **asymmetric** —
/// a slow, deliberate open where the action content fades + slides down into
/// place *after* the row has started expanding, and a quick, snappy close.
class ChallengeListItem extends ConsumerStatefulWidget {
  final Challenge challenge;
  final bool isDone;
  final bool focused;
  final VoidCallback onTap;
  final VoidCallback onStart;

  const ChallengeListItem({
    super.key,
    required this.challenge,
    required this.isDone,
    required this.focused,
    required this.onTap,
    required this.onStart,
  });

  @override
  ConsumerState<ChallengeListItem> createState() => _ChallengeListItemState();
}

class _ChallengeListItemState extends ConsumerState<ChallengeListItem>
    with SingleTickerProviderStateMixin {
  // Design-system signature easing.
  static const _ease = Cubic(.16, 1, .3, 1);

  // The action content trails the height: it only starts fading + sliding in
  // once the row is ~a third open (the design's 100–120ms reveal delay).
  static const _reveal = Interval(0.30, 1.0, curve: _ease);

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520), // open — slow & deliberate
      reverseDuration: const Duration(milliseconds: 220), // close — snappy
      value: widget.focused ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ChallengeListItem old) {
    super.didUpdateWidget(old);
    if (widget.focused != old.focused) {
      widget.focused ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final challenge = widget.challenge;
    final bookmarked = ref
        .watch(bookmarkedChallengeIdsProvider)
        .contains(challenge.id);

    final zoneGradient = ComfortZoneLogic.levelGradient(challenge.level);
    final stripeGlow = zoneGradient.colors.last;
    // Focused: dark bg2 (#161616) / light bg1 (#FFFFFF). Unfocused: fully
    // transparent — the level stripe alone anchors the row.
    final focusedBg = isDark ? s.bg2 : s.bg1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          // Smooth eased progress for the surface + stripe; trailing progress
          // for the revealed action content (fade + slide).
          final double t = _ease
              .transform(_ctrl.value)
              .clamp(0.0, 1.0)
              .toDouble();
          final double r = _reveal
              .transform(_ctrl.value)
              .clamp(0.0, 1.0)
              .toDouble();

          final cardBg = Color.lerp(Colors.transparent, focusedBg, t)!;
          final borderColor = Color.lerp(Colors.transparent, s.bg4, t)!;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Card body (border + bg + content) ───────────────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    // Left padding 22 keeps content clear of the 3px stripe at
                    // left:0 (matches the prototype's `16px 18px 16px 22px`).
                    padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                challenge.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  fontSize: 19,
                                  // Pure white in dark mode to match design
                                  // (#fff); M3 onSurface has a faint pink tint.
                                  color: isDark ? Colors.white : cs.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _IconCluster(
                              flirt: challenge.flirt,
                              bookmarked: bookmarked,
                              done: widget.isDone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challenge.description,
                          maxLines: widget.focused ? 4 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MetaRow(
                          time: challenge.time,
                          level: challenge.level,
                          aura: challenge.aura,
                          zoneGradient: zoneGradient,
                        ),
                        // Action reveal — height tracks the controller; the
                        // content fades + slides down into place on the
                        // trailing interval so it never pops in.
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: t,
                            child: Opacity(
                              opacity: r,
                              child: Transform.translate(
                                offset: Offset(0, -6 * (1 - r)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SyntraButton.small(
                                          onPressed: widget.onStart,
                                          height: 44,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(S.of(context).letsGo),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      _BookmarkButton(
                                        bookmarked: bookmarked,
                                        onTap: () => ref
                                            .read(
                                              bookmarkedChallengeIdsProvider
                                                  .notifier,
                                            )
                                            .toggle(challenge.id),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      _InfoButton(
                                        onTap: () => _onInfoTap(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Level stripe (left edge, glow intensifies with focus) ───
              Positioned(
                left: 0,
                top: 12,
                bottom: 12,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: zoneGradient,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        // 0.40 → 0.67 alpha, 8 → 14 blur as focus ramps.
                        color: stripeGlow.withValues(alpha: 0.40 + 0.27 * t),
                        blurRadius: 8 + 6 * t,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onInfoTap(BuildContext context) async {
    final start = await showChallengeDetailSheet(context, widget.challenge);
    if (start == true) widget.onStart();
  }
}

// ─── Icon cluster (flirt flame / bookmark / done check) ──────────────────────

class _IconCluster extends StatelessWidget {
  final bool flirt;
  final bool bookmarked;
  final bool done;

  const _IconCluster({
    required this.flirt,
    required this.bookmarked,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final children = <Widget>[];
    if (flirt) {
      children.add(
        Icon(
          Icons.local_fire_department_rounded,
          size: 18,
          color: cs.primary.withValues(alpha: 0.85),
        ),
      );
    }
    if (bookmarked) {
      children.add(
        const Icon(Icons.bookmark_rounded, size: 18, color: BrandColors.amber),
      );
    }
    if (done) {
      children.add(
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppTheme.successGreen,
        ),
      );
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            children[i],
          ],
        ],
      ),
    );
  }
}

// ─── Single meta row ─────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final int time;
  final int level;
  final int aura;
  final LinearGradient zoneGradient;

  const _MetaRow({
    required this.time,
    required this.level,
    required this.aura,
    required this.zoneGradient,
  });

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mutedStyle = tt.labelMedium?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(_fmt(time), style: mutedStyle),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: zoneGradient,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(S.of(context).levelN(level), style: mutedStyle),
        const SizedBox(width: AppSpacing.md),
        Icon(Icons.star_rounded, size: 14, color: cs.primary),
        const SizedBox(width: 4),
        Text(
          '+$aura',
          style: mutedStyle?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Bookmark + info buttons (small ghost squares) ───────────────────────────

class _BookmarkButton extends StatelessWidget {
  final bool bookmarked;
  final VoidCallback onTap;

  const _BookmarkButton({required this.bookmarked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bookmarked
              ? BrandColors.amber.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: bookmarked
                ? BrandColors.amber.withValues(alpha: 0.45)
                : cs.outlineVariant,
            width: 1,
          ),
        ),
        child: Icon(
          bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 20,
          color: bookmarked ? BrandColors.amber : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InfoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Icon(
          Icons.info_outline_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Legacy alias for callers still using the old name ───────────────────────

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetaChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.outline),
        const SizedBox(width: 3),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: cs.outline),
        ),
      ],
    );
  }
}
