import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brand_colors.dart';

/// Brand-unique slot-lever toggle.
///
/// A 64×28 recessed track shows static `OFF` / `ON` labels split down the
/// middle. A pink gradient lever slides to the active half and pulses softly
/// while on. Designed to feel different from iOS/Android stock switches —
/// the whole point is that the brand has its own affordance.
class SyntraSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SyntraSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SyntraSwitch> createState() => _SyntraSwitchState();
}

class _SyntraSwitchState extends State<SyntraSwitch> {

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onChanged == null;

    // Track: deepest scaffold tier on dark, warm beige on light.
    final trackBg = isDark ? s.bg0 : s.warmTint;
    final trackBorder = widget.value
        ? cs.primary.withValues(alpha: 0.35)
        : s.bg4;
    final divider = isDark ? s.bg3 : s.bg4;
    final offLabelColor = widget.value ? s.bg5 : s.mutedSubtle;
    final onLabelColor = widget.value ? Colors.white : s.bg5;
    // Inactive lever: snap to bg3 (dark) / bg4 (light) — the original mixed
    // tiers but bg3 reads consistently in dark; bg4 sits a tier deeper than
    // the surrounding track in light, which is what we want.
    final inactiveLever = isDark ? s.bg3 : s.bg4;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onChanged!(!widget.value);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 64,
          height: 28,
          decoration: BoxDecoration(
            color: trackBg,
            border: Border.all(color: trackBorder),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: -1,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Static labels behind the lever.
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            letterSpacing: 1.5,
                            color: offLabelColor,
                          ),
                          child: const Text('OFF'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontFamily: 'Octarine',
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                            letterSpacing: 1.5,
                            color: onLabelColor,
                          ),
                          child: const Text('ON'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Center divider hairline.
              Positioned(
                left: 32,
                top: 4,
                bottom: 4,
                width: 1,
                child: ColoredBox(color: divider),
              ),
              // Sliding lever.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: const Cubic(0.5, 1.4, 0.4, 1),
                left: widget.value ? 32 : 2,
                top: 2,
                bottom: 2,
                width: 30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.value
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.primary.withValues(alpha: 0.92),
                              cs.primary,
                            ],
                          )
                        : null,
                    color: widget.value ? null : inactiveLever,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated expand/collapse wrapper for switch-controlled sub-sections.
class SynReveal extends StatefulWidget {
  final bool open;
  final Widget child;

  const SynReveal({super.key, required this.open, required this.child});

  @override
  State<SynReveal> createState() => _SynRevealState();
}

class _SynRevealState extends State<SynReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.open ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(SynReveal old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      if (widget.open) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _ctrl,
        child: widget.child,
      ),
    );
  }
}

