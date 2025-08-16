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
  static Color get grapeLight => grape.withValues(alpha: 0.1);

  /// Marian blue with 10% opacity - used for subtle backgrounds
  static Color get marianBlueLight => marianBlue.withValues(alpha: 0.1);

  /// Grape color with 30% opacity - used for dividers
  static Color get grapeDivider => grape.withValues(alpha: 0.3);

  /// Marian blue with 20% opacity - used for progress bar backgrounds
  static Color get marianBlueBackground => marianBlue.withValues(alpha: 0.2);

  /// Text color with 70% opacity - used for secondary text
  static Color get textSecondaryLight => textPrimary.withValues(alpha: 0.7);

  /// Holt die Challenges aus der Datenbank
  static Future<List<Challenge>> getChallengesFromDB([
    String? languageCode,
  ]) async {
    return await ChallengeDatabase.instance.readAllChallenges(
      languageCode ?? 'en',
    );
  }

  /// Konstante Liste aller Challenges, wird beim App-Start befüllt
  static late List<Challenge> CHALLENGES;

  /// User-controlled notification settings
  static const String defaultMorningTime = '09:00';
  static const String defaultAfternoonTime = '14:00';
  static const String defaultEveningTime = '19:00';

  /// Default notification schedule settings
  static const Map<String, dynamic> defaultNotificationSettings = {
    'morningEnabled': false,
    'morningTime': defaultMorningTime,
    'afternoonEnabled': false,
    'afternoonTime': defaultAfternoonTime,
    'eveningEnabled': false,
    'eveningTime': defaultEveningTime,
  };

  /// Motivational notification messages (English)
  static const List<String> motivationMessagesEN = [
    "Ready for a new challenge? Let's go!",
    "Keep up the great work! Try a challenge today!",
    "Your next win is waiting. Take on a challenge!",
    "Small steps, big results. Do a challenge!",
    "Complete a challenge now! Remember, every bit counts!",
    "You are the sun! But what is the sun if it can't shine?\nDo a challenge!",
    "Are you outside? You should do a challenge!",
    "It takes only 5 minutes to do a challenge!\nWhat are you waiting for?",
  ];

  /// Motivational notification messages (German)
  static const List<String> motivationMessagesDE = [
    "Bereit für eine neue Challenge? Los geht's!",
    "Weiter so! Probier heute eine Challenge aus!",
    "Dein nächster Erfolg wartet. Starte eine Challenge!",
    "Kleine Schritte, große Wirkung. Mach eine Challenge!",
    "Bleib motiviert! Jetzt eine Challenge abschließen!",
    "Du bist die Sonne! Aber was ist die Sonne, wenn sie nicht scheinen kann?\nMach eine Challenge!",
    "Bist du draußen? Dann mach eine Challenge!",
    "Eine Challenge dauert nur 5 Minuten!\nWorauf wartest du?",
  ];

  /// Legacy default messages (kept for backward compatibility)
  static const List<String> motivationMessages = motivationMessagesEN;

  /// Localized title for motivation notifications
  static String localizedMotivationTitle(String localeCode) {
    switch (localeCode) {
      case 'de':
        return 'Syntra Erinnerung';
      default:
        return 'Syntra Motivation';
    }
  }

  /// Returns a random localized motivation message for the given locale code
  static String randomMotivationMessage(String localeCode) {
    final list = (localeCode == 'de') ? motivationMessagesDE : motivationMessagesEN;
    if (list.isEmpty) return 'Stay motivated!';
    // Use DateTime milliseconds to vary selection without new Random each call
    final idx = DateTime.now().millisecondsSinceEpoch % list.length;
    return list[idx];
  }
}
