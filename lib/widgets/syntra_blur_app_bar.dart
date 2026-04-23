import 'package:flutter/material.dart';

/// An AppBar with an adaptive gradient scrim — white in light mode, dark in
/// dark mode — fading to transparent at the bottom for a seamless edge.
///
/// Colors and title style are inherited from [AppBarTheme] (set globally in
/// [AppTheme]), so this widget only adds the gradient flexibleSpace.
///
/// Usage:
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   appBar: SyntraBlurAppBar(title: Text('Profile')),
///   body: ListView(
///     padding: EdgeInsets.only(top: SyntraBlurAppBar.topPadding(context)),
///     ...
///   ),
/// )
/// ```
class SyntraBlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;

  const SyntraBlurAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  /// Top padding a scrollable body should add so its first item clears the bar.
  /// Uses viewPadding (raw hardware inset) so it works correctly whether called
  /// from an outer build context or from inside an extendBodyBehindAppBar body,
  /// where Scaffold replaces padding.top with the full app-bar height.
  static double topPadding(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top + kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scrimAlpha = isDark ? 0.65 : 0.35;
    final fgColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      foregroundColor: fgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: scrimAlpha),
              Colors.transparent,
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }
}
