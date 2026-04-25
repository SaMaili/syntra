import 'package:flutter/material.dart';
import 'package:syntra/challenge.dart';
import 'package:syntra/challenge_ui.dart';

import '../../generated/l10n.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../routes/challenge_detail_screen.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/syntra_button.dart';

class ChallengeListItem extends StatelessWidget {
  final Challenge challenge;
  final bool isDone;
  final VoidCallback onStart;

  const ChallengeListItem({
    required this.challenge,
    required this.isDone,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final cardColor = isDone
        ? Color.lerp(
            Theme.of(context).cardTheme.color ?? cs.surfaceContainer,
            AppTheme.successGreen,
            0.12,
          )
        : null;

    return Card(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.cardRadius),
            ),
            onTap: () => _onInfoTap(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: ComfortZoneLogic.levelGradient(
                              challenge.level),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'L${challenge.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isDone)
                        const Padding(
                          padding: EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.check_circle_rounded,
                              size: 16, color: AppTheme.successGreen),
                        ),
                      if (challenge.flirt)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Icon(Icons.favorite,
                              size: 16, color: cs.secondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    challenge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 155;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MetaChip(
                            icon: Icons.timer_outlined,
                            label: _formatTime(challenge.time),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MetaChip(
                            icon: Icons.emoji_events_outlined,
                            label: compact
                                ? '${challenge.xp}A'
                                : '${challenge.xp} ${S.of(context).auraPoints}',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MetaChip(
                            icon: challenge.typeIcon,
                            label: challenge.typeLabel(S.of(context)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SyntraButton.small(
                  onPressed: onStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(S.of(context).letsGo),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _onInfoTap(BuildContext context) async {
    final start = await showChallengeDetailSheet(context, challenge);
    if (start == true) onStart();
  }
}

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const MetaChip({required this.icon, required this.label});

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
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: cs.outline),
        ),
      ],
    );
  }
}
