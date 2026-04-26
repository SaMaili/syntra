import 'package:flutter/material.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/challenge_ui.dart';
import 'package:syntra/theme/app_spacing.dart';

import '../generated/l10n.dart';
import 'challenge_info_notification.dart';

/// Full-screen challenge card used during an active session.
///
/// Renders the challenge title, description, and meta chips in a
/// Material 3 Card that fills its parent. The description is vertically
/// centered when short and scrollable when long.
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool showXP;
  final VoidCallback? onInfoPressed;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.showXP = true,
    this.onInfoPressed,
  });

  String _fmtDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                topRight: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Text(
              challenge.title,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onPrimaryContainer,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // ── Description — vertically centered, scrollable ────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  // Forces the description to at least fill the available
                  // height so short text is centered rather than top-aligned.
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        challenge.description,
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurface,
                          height: 1.65,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Footer: meta chips + info button ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: _fmtDuration(challenge.time),
                      ),
                      _MetaChip(
                        icon: challenge.typeIcon,
                        label: challenge.typeLabel(l),
                      ),
                      _MetaChip(
                        icon: Icons.shield_outlined,
                        label: 'L${challenge.level}',
                      ),
                      if (showXP)
                        _MetaChip(
                          icon: Icons.star_rounded,
                          label: '+${challenge.aura} ${l.auraPoints}',
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline,
                      color: cs.onSurfaceVariant, size: 22),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: l.challengeInformation,
                  onPressed: onInfoPressed ??
                      () => ChallengeInfoNotification
                          .showLastNotesNotification(
                              context, challenge.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meta chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
