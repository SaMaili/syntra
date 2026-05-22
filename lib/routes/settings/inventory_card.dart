import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings_repository.dart';
import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/shop_providers.dart';
import '../../theme/brand_colors.dart';
import '../../widgets/syntra_settings_widgets.dart';
import '../../widgets/syntra_sheet.dart';

/// Compact inventory row showing the Streak Freeze item — slot dots for
/// the current count and a "buy" chip pinned to the right. Tapping the chip
/// opens the existing confirm sheet and spends Aura.
class InventoryCard extends ConsumerWidget {
  const InventoryCard({super.key});

  Future<void> _buy(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    final available = ref.read(availableAuraProvider);
    final freezes = ref.read(streakFreezesProvider);
    final l = S.of(context);

    if (freezes >= kMaxStreakFreezes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.shopMaxOwned)));
      return;
    }
    if (available == null || available < kStreakFreezePrice) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.shopNotEnoughAura)));
      return;
    }

    final confirmed = await showSyntraSheet<bool>(
      context,
      useRootNavigator: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.ac_unit_rounded,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.shopConfirmTitle,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                l.shopConfirmBody(kStreakFreezePrice),
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l.shopBuyFor(kStreakFreezePrice)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(spentAuraProvider.notifier).spend(kStreakFreezePrice);
    await ref.read(streakFreezesProvider.notifier).add();
    final currentWeek = WeeklyStreakLogic.isoYearWeek(DateTime.now());
    final frozenWeeks = await SettingsRepository.instance.loadFrozenWeeks();
    await SettingsRepository.instance.saveFrozenWeeks({
      ...frozenWeeks,
      currentWeek,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.shopPurchased)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final freezes = ref.watch(streakFreezesProvider);

    final divider = s.bg3;
    final chipBg = s.bg2;
    final labelColor = isDark ? Colors.white : cs.onSurface;

    return SettingsGroup(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.ac_unit_rounded,
                  color: BrandColors.blueLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.streakFreezeName,
                      style: tt.titleSmall?.copyWith(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.shopStreakFreezeDesc,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SlotDots(
                filled: freezes,
                total: kMaxStreakFreezes,
                fillColor: BrandColors.blueLight,
                trackColor: divider,
              ),
              const SizedBox(width: 8),
              _BuyChip(
                price: kStreakFreezePrice,
                bg: chipBg,
                border: divider,
                onTap: () => _buy(context, ref),
                enabled: freezes < kMaxStreakFreezes,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlotDots extends StatelessWidget {
  final int filled;
  final int total;
  final Color fillColor;
  final Color trackColor;
  const _SlotDots({
    required this.filled,
    required this.total,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: i < filled ? fillColor : Colors.transparent,
              border: Border.all(color: trackColor, width: 1),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

class _BuyChip extends StatelessWidget {
  final int price;
  final Color bg;
  final Color border;
  final VoidCallback onTap;
  final bool enabled;

  const _BuyChip({
    required this.price,
    required this.bg,
    required this.border,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : cs.onSurface;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 11, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                '$price',
                style: TextStyle(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
