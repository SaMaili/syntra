import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'brand_colors.dart';

/// Material 3 theme built from a single seed color.
/// Flutter generates the full tonal palette automatically.
///
/// All concrete hex values live in [BrandColors] / [SyntraSurface] — this file
/// only wires those tokens into Material's `ThemeData`.
abstract class AppTheme {
  /// Primary brand color — Neon Pink. Re-exported here for legacy callers; new
  /// code should reference [BrandColors.pink] directly.
  static const Color seedColor = BrandColors.pink;

  /// Colour used for "done / success" states (checkmark icons, completed-card
  /// tint). Re-exported from [BrandColors.green] for legacy callers.
  static const Color successGreen = BrandColors.green;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Octarine',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: seedColor,
        secondary: BrandColors.cyan,
        tertiary: BrandColors.orange,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: BrandColors.lightScaffold,
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700, height: 1.2),
        titleLarge:    TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        titleMedium:   TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        titleSmall:    TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        labelMedium:   TextStyle(fontFamily: 'Octarine', height: 1.2),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Octarine',
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        primary: seedColor,
        secondary: BrandColors.red,
        tertiary: BrandColors.orange,
        surface: SyntraSurface.dark.bg1,
      ),
      brightness: Brightness.dark,
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        displaySmall:  TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700, height: 1.2),
        titleLarge:    TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        titleMedium:   TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        titleSmall:    TextStyle(fontFamily: 'Octarine', fontWeight: FontWeight.w700),
        labelMedium:   TextStyle(fontFamily: 'Octarine', height: 1.2),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: Colors.grey[700]!, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 0,
      ),
    );
  }
}
