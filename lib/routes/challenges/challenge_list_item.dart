import 'package:flutter/material.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../routes/challenge_detail_screen.dart';
// TODO: re-enable when backend is available: import '../../routes/challenge_done_screen.dart' show socialProofCount;
import '../../theme/app_spacing.dart';
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
            const Color(0xFF4CAF50),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isDone)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: const Icon(Icons.check_circle_rounded,
                              size: 16, color: Color(0xFF4CAF50)),
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
                  // TODO: re-enable social proof once backend provides real participant counts
                  // const SizedBox(height: AppSpacing.xs),
                  // Text(
                  //   '~${socialProofCount(challenge.id)} people in this community have tried this',
                  //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  //         color: cs.onSurfaceVariant.withAlpha(160),
                  //       ),
                  // ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MetaChip(
                        icon: Icons.timer_outlined,
                        label: _formatTime(challenge.time),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MetaChip(
                        icon: Icons.emoji_events_outlined,
                        label: '${challenge.xp} ${S.of(context).auraPoints}',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MetaChip(
                        icon: _typeIcon(challenge.type),
                        label: _typeLabel(context, challenge.type),
                      ),
                    ],
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

  IconData _typeIcon(String type) => switch (type) {
        'group' => Icons.group_outlined,
        'coop' => Icons.people_alt_outlined,
        'dare' => Icons.bolt_outlined,
        _ => Icons.person_outlined,
      };

  String _typeLabel(BuildContext context, String type) {
    final l = S.of(context);
    return switch (type) {
      'group' => l.group,
      'coop' => l.coop,
      'dare' => l.dare,
      _ => l.solo,
    };
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  Future<void> _onInfoTap(BuildContext context) async {
    final start = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChallengeDetailScreen(challenge: challenge),
      ),
    );
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
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: cs.outline),
          ),
        ),
      ],
    );
  }
}
