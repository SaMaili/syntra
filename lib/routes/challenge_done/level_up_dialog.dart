import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/syntra_button.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  const LevelUpDialog({required this.newLevel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final name = newLevel <= ComfortZoneLogic.maxLevel
        ? ComfortZoneLogic.levelNames[newLevel]
        : ComfortZoneLogic.levelNames[ComfortZoneLogic.maxLevel];
    final desc = newLevel <= ComfortZoneLogic.maxLevel
        ? ComfortZoneLogic.levelDescriptions[newLevel]
        : ComfortZoneLogic.levelDescriptions[ComfortZoneLogic.maxLevel];

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius * 2)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ComfortZoneLogic.levelGradient(newLevel),
              ),
              child: Icon(
                ComfortZoneLogic.levelIcons[
                    newLevel.clamp(1, ComfortZoneLogic.maxLevel)],
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.levelUnlocked(newLevel),
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: tt.titleMedium
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              desc,
              style: tt.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SyntraButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.letsGoButton),
            ),
          ],
        ),
      ),
    );
  }
}
