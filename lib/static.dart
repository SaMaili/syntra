/// Notification message pools and default schedule constants.
///
/// Legacy color constants have been removed — use `Theme.of(context).colorScheme`
/// or the tokens in `lib/theme/app_theme.dart` instead.
class AppStatic {
  // ─── Notification defaults ──────────────────────────────────────────────────

  static const String defaultMorningTime = '09:00';
  static const String defaultAfternoonTime = '14:00';
  static const String defaultEveningTime = '19:00';

  static const Map<String, dynamic> defaultNotificationSettings = {
    'morningEnabled': false,
    'morningTime': defaultMorningTime,
    'afternoonEnabled': false,
    'afternoonTime': defaultAfternoonTime,
    'eveningEnabled': false,
    'eveningTime': defaultEveningTime,
  };

  // ─── Motivation messages ────────────────────────────────────────────────────

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

  static const List<String> motivationMessagesDE = [
    "Bereit für eine neue Challenge? Los geht's!",
    "Weiter so! Probier heute eine Challenge aus!",
    "Dein nächster Erfolg wartet. Starte eine Challenge!",
    "Kleine Schritte, große Wirkung. Mach eine Challenge!",
    "Bleib motiviert! Jetzt eine Challenge abschließen!",
    "Du bist die Sonne! Aber was ist die Sonne, wenn sie nicht scheinen kann?\nMach eine Challenge!",
    "Bist du gerade draußen? Dann mach eine Challenge!",
    "Eine Challenge dauert nur 5 Minuten!\nWorauf wartest du?",
  ];

  static String localizedMotivationTitle(String localeCode) {
    switch (localeCode) {
      case 'de':
        return 'Syntra Erinnerung';
      default:
        return 'Syntra Motivation';
    }
  }

  static String randomMotivationMessage(String localeCode) {
    final list =
        (localeCode == 'de') ? motivationMessagesDE : motivationMessagesEN;
    if (list.isEmpty) return 'Stay motivated!';
    final idx = DateTime.now().millisecondsSinceEpoch % list.length;
    return list[idx];
  }

  // ─── Streak Milestones ─────────────────────────────────────────────────────

  static const List<int> streakMilestones = [1, 3, 7, 14, 30, 60, 100];
}
