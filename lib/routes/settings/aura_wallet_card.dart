import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../providers/shop_providers.dart';
import '../../theme/brand_colors.dart';

/// Quiet brand-tinted "Your Aura" card at the top of Settings.
///
/// Pink-to-dark diagonal gradient, soft pink glow blob in the top-right
/// corner, star icon + uppercase label + big total. Theme-aware: in light
/// mode the gradient fades into the surface tint rather than near-black.
class AuraWalletCard extends ConsumerWidget {
  const AuraWalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final available = ref.watch(availableAuraProvider) ?? 0;

    final surfaceTint = s.bg1;
    final valueColor = isDark ? Colors.white : cs.onSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.10),
            surfaceTint,
          ],
          stops: const [0.0, 0.6],
        ),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Pink glow blob — anchored top-right.
            Positioned(
              top: -40,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cs.primary.withValues(alpha: 0.30),
                        cs.primary.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.star_rounded,
                        size: 20, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.auraWalletLabel.toUpperCase(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fmt(available),
                          style: tt.titleLarge?.copyWith(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            letterSpacing: -0.4,
                            color: valueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
