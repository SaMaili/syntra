import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import 'syntra_button.dart';

/// The single source of truth for every slide-up panel in the app.
///
/// - [showSyntraSheet] — content-sized panels (confirmations, info, pickers).
/// - [SyntraSheetShell] — the full-width decorated shell + grab handle.
/// - [syntraSheetDecoration] / [SyntraSheetHandle] — the raw skin, reused by
///   the draggable/scrollable sheets so they match exactly.
const double kSyntraSheetRadius = 24;

/// The shared panel skin: a solid opaque [SyntraSurface.bg1] base with an
/// optional [accent] halo from the top, a hairline top border and a rounded
/// top. Never translucent.
BoxDecoration syntraSheetDecoration(BuildContext context, {Color? accent}) {
  final s = SyntraSurface.of(context);
  return BoxDecoration(
    // Accent is composited *over* the opaque base, so the panel is solid
    // even where the halo is strongest.
    gradient: accent != null
        ? RadialGradient(
            center: const Alignment(0, -1.1),
            radius: 1.1,
            colors: [
              Color.alphaBlend(accent.withValues(alpha: 0.20), s.bg1),
              s.bg1,
            ],
            stops: const [0.0, 0.6],
          )
        : null,
    color: accent == null ? s.bg1 : null,
    border: Border(top: BorderSide(color: s.bg3)),
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(kSyntraSheetRadius),
    ),
  );
}

/// The 40×4 grab handle every panel shows at its top.
class SyntraSheetHandle extends StatelessWidget {
  const SyntraSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: s.bg4,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// Full-screen-width, content-sized panel shell: the skin, the grab handle and
/// a bottom safe-area inset. Used by [showSyntraSheet]; can also wrap the body
/// of a [DraggableScrollableSheet] when [scrollable] is true.
class SyntraSheetShell extends StatelessWidget {
  final Widget child;
  final Color? accent;

  /// When true the child is allowed to fill the available height (for
  /// draggable/scrollable bodies) instead of being shrink-wrapped.
  final bool scrollable;

  const SyntraSheetShell({
    super.key,
    required this.child,
    this.accent,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: syntraSheetDecoration(context, accent: accent),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const SyntraSheetHandle(),
            const SizedBox(height: 8),
            if (scrollable) Expanded(child: child) else Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Shows the standard Syntra slide-up panel. The panel is full-screen-width
/// and content-sized — wrap tall content in a scroll view yourself.
Future<T?> showSyntraSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  Color? accent,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    // Override the Material-3 ~640 dp cap so the panel spans the full width.
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (ctx) => SyntraSheetShell(
      accent: accent,
      child: Builder(builder: builder),
    ),
  );
}

/// The standard Syntra confirmation dialog — same skin language as the panels
/// (opaque [SyntraSurface.bg1] base, accent halo from the top, hairline
/// border, 24 dp radius), an Octarine display title, a [SyntraButton] primary
/// action and a ghost cancel. Returns `true` only if confirmed.
Future<bool> showSyntraConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  Color? accent,
  bool destructive = false,
}) async {
  final s = SyntraSurface.of(context);
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final actionColor = destructive ? cs.error : (accent ?? cs.primary);
  final glow = accent ?? actionColor;

  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.0),
            radius: 1.2,
            colors: [
              Color.alphaBlend(glow.withValues(alpha: 0.16), s.bg1),
              s.bg1,
            ],
            stops: const [0.0, 0.7],
          ),
          border: Border.all(color: s.bg3),
          borderRadius: BorderRadius.circular(kSyntraSheetRadius),
        ),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleLarge?.copyWith(
                fontFamily: 'Octarine',
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SyntraButton(
              color: actionColor,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmLabel),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
