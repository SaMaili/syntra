import 'dart:io';
import 'package:flutter/material.dart';

/// 8-point grid spacing constants.
/// All padding/margin values in the app should be multiples of 8.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double cardRadius = 20;
  static const double buttonRadius = 16;
  static const double chipRadius = 24;

  /// Dynamic bottom padding to ensure scrollable content clears the translucent
  /// navigation bar. Accounts for M3 NavigationBar (80px) or CupertinoTabBar (50px)
  /// plus the system safe area bottom inset.
  static double bottomNavBarHeight(BuildContext context) {
    final viewPadding = MediaQuery.paddingOf(context).bottom;
    // Platform.isIOS check is safe here as it's a mobile-first app.
    // If running on web, it defaults to the standard NavigationBar height.
    double barHeight = 80.0;
    try {
      if (Platform.isIOS) barHeight = 50.0;
    } catch (_) {}
    return viewPadding + barHeight;
  }
}
