import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../services/sound_service.dart';
import '../theme/app_spacing.dart';

/// A 3D-styled tactile button that aligns with Syntra's "Experience" design.
class SyntraButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final double height;
  final double depth;
  final bool fullWidth;

  const SyntraButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.height = 56,
    this.depth = 4,
    this.fullWidth = true,
  });

  /// A smaller variant of the button, typically for list items.
  const SyntraButton.small({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.height = 36,
    this.depth = 3,
    this.fullWidth = false,
  });

  /// A variant with an icon and label.
  factory SyntraButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    required Widget label,
    Color? color,
    double height = 56,
    double depth = 4,
    bool fullWidth = true,
  }) {
    return SyntraButton(
      key: key,
      onPressed: onPressed,
      color: color,
      height: height,
      depth: depth,
      fullWidth: fullWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: height * 0.4),
          const SizedBox(width: 8),
          Flexible(child: label),
        ],
      ),
    );
  }

  @override
  ConsumerState<SyntraButton> createState() => _SyntraButtonState();
}

class _SyntraButtonState extends ConsumerState<SyntraButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // Determine the base intent color (defaulting to primary)
    final baseColor = widget.color ?? cs.primary;

    // Apply the softening logic you liked (45% grey) to make it 
    // "less intimidating" regardless of which neon color we use.
    final mainColor = Color.lerp(baseColor, Colors.grey, 0.45)!;
    
    // Increase shadow contrast by darkening the lerp factor
    final shadowColor = Color.lerp(mainColor, Colors.black, 0.35) ?? Colors.black;
    final isDisabled = widget.onPressed == null;

    // Derive foreground color from the actual rendered background so that any
    // colored button (red, cyan, orange…) always gets legible content.
    final fgColor = isDisabled
        ? cs.onSurfaceVariant
        : ThemeData.estimateBrightnessForColor(mainColor) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    Widget result = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final topPadding = _controller.value * widget.depth;
        
        return IntrinsicWidth(
          child: SizedBox(
            height: widget.height + widget.depth,
            child: Stack(
              children: [
                // Bottom Layer (Shadow/Depth)
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: widget.depth),
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: isDisabled ? cs.surfaceContainerHighest : shadowColor,
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                    ),
                  ),
                ),
                // Top Layer (Button Face)
                Padding(
                  padding: EdgeInsets.only(top: topPadding, bottom: widget.depth - topPadding),
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: isDisabled ? cs.surfaceContainerHigh : mainColor,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                    alignment: Alignment.center,
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.height < 40 ? 13 : 16,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: fgColor,
                          size: widget.height * 0.5,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.fullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        _controller.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: isDisabled ? null : (_) {
        _controller.reverse();
        SoundService.playClick(enabled: ref.read(soundEffectsEnabledProvider));
        widget.onPressed?.call();
      },
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      child: result,
    );
  }
}
