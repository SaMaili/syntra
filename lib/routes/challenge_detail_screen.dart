import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../generated/l10n.dart';
import '../providers/statistics_providers.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

/// Full-screen challenge detail view — replaces the modal bottom sheet used
/// in [ChallengeCard]. Pushed as a [MaterialPageRoute] from [_onInfoTap].
class ChallengeDetailScreen extends ConsumerWidget {
  final Challenge challenge;

  /// Called when the user taps "Let's Go". The screen pops first, then
  /// the caller is responsible for starting the challenge.
  final VoidCallback onStart;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final isDone = ref
        .watch(completedChallengeIdsProvider)
        .valueOrNull
        ?.contains(challenge.id) ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          challenge.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isDone)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Icon(Icons.check_circle_rounded,
                  color: const Color(0xFF4CAF50), size: 22),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meta chips ─────────────────────────────────────────────
                  _TagChips(challenge: challenge),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Description ────────────────────────────────────────────
                  Text(
                    challenge.description,
                    style: tt.bodyLarge?.copyWith(height: 1.6),
                  ),

                  // ── Not sure what to say ───────────────────────────────────
                  if (challenge.notSureWhatToSay.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l.notSureWhatToSay,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadius),
                      ),
                      child: Text(
                        challenge.notSureWhatToSay,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSecondaryContainer,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── Pinned launch button ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg +
                  MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: SyntraButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onStart();
              },
              icon: Icons.rocket_launch_rounded,
              label: Text(l.letsGo),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tag / meta chips ─────────────────────────────────────────────────────────

class _TagChips extends StatelessWidget {
  final Challenge challenge;
  const _TagChips({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    String fmtTime(int s) {
      if (s < 60) return '${s}s';
      final m = s ~/ 60;
      final r = s % 60;
      return r == 0 ? '${m}m' : '${m}m ${r}s';
    }

    String envLabel(String e) => switch (e) {
          'home' => '🏠 Home',
          'work' => '💼 Work',
          _ => '🌍 Any',
        };

    final chips = <({IconData? icon, String label, Color bg})>[
      (
        icon: Icons.timer_outlined,
        label: fmtTime(challenge.time),
        bg: cs.secondaryContainer
      ),
      (
        icon: Icons.emoji_events_outlined,
        label: '+${challenge.xp} XP',
        bg: cs.primaryContainer
      ),
      (
        icon: challenge.type == 'group'
            ? Icons.group_outlined
            : Icons.person_outlined,
        label: challenge.type == 'group' ? l.group : l.solo,
        bg: cs.surfaceContainerHighest,
      ),
      if (challenge.environment != 'all' && challenge.environment.isNotEmpty)
        (
          icon: null,
          label: envLabel(challenge.environment),
          bg: cs.surfaceContainerHighest
        ),
      if (challenge.flirt)
        (
          icon: Icons.favorite_rounded,
          label: 'Flirt',
          bg: cs.secondaryContainer
        ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips
          .map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.icon != null) ...[
                      Icon(c.icon, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      c.label,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
