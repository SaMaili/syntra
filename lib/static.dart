import 'package:flutter/material.dart';

import 'Challenge.dart';
import 'database/challenge_database.dart';

/// Static color constants for the Syntra app
/// This file centralizes all color definitions to maintain consistency
class AppStatic {
  // Primary Colors
  /// Main grape purple color - used for primary elements, buttons, and highlights
  static const Color grape = Color(0xFF5C2CAF);

  /// Darker grape variant - used for button backgrounds and emphasis
  static const Color grapeDark = Color(0xFF5D2EB0);

  /// Marian blue - used for secondary elements and unselected items
  static const Color marianBlue = Color(0xFF453D80);

  /// Deep purple - used for text and dark elements
  static const Color deepPurple = Color(0xFF2F276D);

  // Background Colors
  /// Snow white - used for scaffold background and light surfaces
  static const Color snow = Color(0xFFF7F3F2);

  // Text Colors
  /// Primary text color - used for most text content
  static const Color textPrimary = Color(0xFF2F276D);

  /// Secondary text color - used for subtitles and less important text
  static const Color textSecondary = Color(0xFF453D80);

  // UI Element Colors
  /// White color for text on dark backgrounds
  static const Color white = Colors.white;

  /// Transparent color for overlays and effects
  static const Color transparent = Colors.transparent;

  // Opacity Variants
  /// Grape color with 10% opacity - used for subtle backgrounds
  static Color get grapeLight => grape.withOpacity(0.1);

  /// Marian blue with 10% opacity - used for subtle backgrounds
  static Color get marianBlueLight => marianBlue.withOpacity(0.1);

  /// Grape color with 30% opacity - used for dividers
  static Color get grapeDivider => grape.withOpacity(0.3);

  /// Marian blue with 20% opacity - used for progress bar backgrounds
  static Color get marianBlueBackground => marianBlue.withOpacity(0.2);

  /// Text color with 70% opacity - used for secondary text
  static Color get textSecondaryLight => textPrimary.withOpacity(0.7);

  /// Holt die Challenges aus der Datenbank
  static Future<List<Challenge>> getChallengesFromDB() async {
    return await ChallengeDatabase.instance.readAllChallenges();
  }

  /// Konstante Liste aller Challenges, wird beim App-Start befüllt
  static late List<Challenge> CHALLENGES;
}
