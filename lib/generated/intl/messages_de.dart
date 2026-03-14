// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(challengeTitle) => "Bereit für: ${challengeTitle}?";

  static String m1(challengeTitle) =>
      "Deine Challenge \"${challengeTitle}\" ist gerade beendet! 🏆";

  static String m2(time) => "Nächste Motivation 1: ${time}";

  static String m3(time) => "Nächste Motivation 2: ${time}";

  static String m4(period, time) =>
      "⏰ ${period} Erinnerung aktualisiert auf ${time}";

  static String m5(seconds) => "In ${seconds} Sekunden verfügbar";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Über"),
    "aboutSubtitle": MessageLookupByLibrary.simpleMessage(
      "App-Version und Informationen",
    ),
    "acceptChallenge": MessageLookupByLibrary.simpleMessage(
      "Challenge annehmen",
    ),
    "addCustomChallenge": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "addCustomChallengeTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "afternoon": MessageLookupByLibrary.simpleMessage("Nachmittag"),
    "allowExactAlarms": MessageLookupByLibrary.simpleMessage(
      "Genaue Alarme zulassen",
    ),
    "auraPoints": MessageLookupByLibrary.simpleMessage("Aura"),
    "backToHome": MessageLookupByLibrary.simpleMessage("Zurück zum Hauptmenü"),
    "bad": MessageLookupByLibrary.simpleMessage("Schlecht"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "celebrateSmallWins": MessageLookupByLibrary.simpleMessage(
      "Feiere täglich kleine Erfolge",
    ),
    "challenge": MessageLookupByLibrary.simpleMessage("Challenge"),
    "challengeAborted": MessageLookupByLibrary.simpleMessage(
      "Challenge abgebrochen",
    ),
    "challengeAbortedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Challenge abgebrochen!",
    ),
    "challengeAlreadyCompleted": MessageLookupByLibrary.simpleMessage(
      "Du hast diese Challenge bereits abgeschlossen!",
    ),
    "challengeAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Challenge existiert bereits?",
    ),
    "challengeCompleted": MessageLookupByLibrary.simpleMessage(
      "Challenge abgeschlossen!",
    ),
    "challengeCompletedDaily": MessageLookupByLibrary.simpleMessage(
      "Challenge abgeschlossen!",
    ),
    "challengeCompletedGeneric": MessageLookupByLibrary.simpleMessage(
      "Challenge abgeschlossen!",
    ),
    "challengeCompletedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Challenge abgeschlossen! Logbuch-Eintrag gespeichert.",
    ),
    "challengeConfirmMessage": m0,
    "challengeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge starten?",
    ),
    "challengeDescriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge-Beschreibung",
    ),
    "challengeDetails": MessageLookupByLibrary.simpleMessage(
      "Challenge-Details",
    ),
    "challengeId": MessageLookupByLibrary.simpleMessage("Challenge-ID"),
    "challengeLogbook": MessageLookupByLibrary.simpleMessage(
      "Challenge-Logbuch",
    ),
    "challengeName": MessageLookupByLibrary.simpleMessage("Challenge-Name"),
    "challengeStartQuestion": MessageLookupByLibrary.simpleMessage(
      "Challenge starten?",
    ),
    "challengeTimerCompleteBody": m1,
    "challengeTimerCompleteTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Timer abgelaufen!",
    ),
    "challengeType": MessageLookupByLibrary.simpleMessage("Challenge-Typ"),
    "challengesShuffled": MessageLookupByLibrary.simpleMessage(
      "Challenges gemischt!",
    ),
    "closeDialog": MessageLookupByLibrary.simpleMessage("Schließen"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Kommt bald"),
    "completed": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "congratulations": MessageLookupByLibrary.simpleMessage(
      "Glückwunsch! Du hast die Challenge abgeschlossen.",
    ),
    "dailyChallenge": MessageLookupByLibrary.simpleMessage(
      "Tägliche Challenge",
    ),
    "dailyReminders": MessageLookupByLibrary.simpleMessage(
      "Tägliche Erinnerungen",
    ),
    "dailyRemindersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Lass dich daran erinnern, Herausforderungen zu meistern",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dunkler Modus"),
    "darkModeSubtitle": MessageLookupByLibrary.simpleMessage(
      "In den dunklen Modus wechseln",
    ),
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "dbDebugShow": MessageLookupByLibrary.simpleMessage(
      "DB Debug: Zeige gesamte Logbuch-Tabelle",
    ),
    "debugDeleteTooltip": MessageLookupByLibrary.simpleMessage(
      "Debug L��schen",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteEntry": MessageLookupByLibrary.simpleMessage("Eintrag löschen"),
    "deleteEntryQuestion": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Eintrag löschen möchtest?",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
    "done": MessageLookupByLibrary.simpleMessage("Erledigt"),
    "doneExcited": MessageLookupByLibrary.simpleMessage("GESCHAFFT! 😎"),
    "embraceChallenges": MessageLookupByLibrary.simpleMessage(
      "Betrachte Herausforderungen als Chancen",
    ),
    "enterDescription": MessageLookupByLibrary.simpleMessage(
      "Beschreibung eingeben",
    ),
    "enterName": MessageLookupByLibrary.simpleMessage("Namen eingeben"),
    "enterYourNotes": MessageLookupByLibrary.simpleMessage(
      "Gib hier deine Notizen ein...",
    ),
    "entryDeleted": MessageLookupByLibrary.simpleMessage("Eintrag gelöscht"),
    "evening": MessageLookupByLibrary.simpleMessage("Abend"),
    "everyDayNewChance": MessageLookupByLibrary.simpleMessage(
      "Jeder Tag ist eine neue Chance zu wachsen und sich selbst zu übertreffen.",
    ),
    "exactAlarmsDescription": MessageLookupByLibrary.simpleMessage(
      "Um genaue Challenge-Timer zu gewährleisten, erlaube bitte genaue Alarme in deinen Geräteeinstellungen.",
    ),
    "existingChallenge": MessageLookupByLibrary.simpleMessage("Bestehend"),
    "failed": MessageLookupByLibrary.simpleMessage("Gescheitert"),
    "feeling": MessageLookupByLibrary.simpleMessage("Gefühl"),
    "focusProgress": MessageLookupByLibrary.simpleMessage(
      "Fokussiere dich auf Fortschritt, nicht Perfektion",
    ),
    "getNewMotivation": MessageLookupByLibrary.simpleMessage(
      "Neue Motivation erhalten",
    ),
    "goToSettings": MessageLookupByLibrary.simpleMessage(
      "Zu den Einstellungen",
    ),
    "good": MessageLookupByLibrary.simpleMessage("Gut"),
    "greatJobDaily": MessageLookupByLibrary.simpleMessage(
      "Großartig! Du hast die heutige Challenge gemeistert.",
    ),
    "group": MessageLookupByLibrary.simpleMessage("Gruppe"),
    "growthStartsDecision": MessageLookupByLibrary.simpleMessage(
      "Wachstum beginnt mit einer Entscheidung: Mut, Offenheit und Positivität.",
    ),
    "howDidYouFeel": MessageLookupByLibrary.simpleMessage(
      "Wie hast du dich gefühlt?",
    ),
    "howDoYouFeel": MessageLookupByLibrary.simpleMessage("Wie fühlst du dich?"),
    "howPerceivedQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie denkst du, wurdest du wahrgenommen?",
    ),
    "howPerceivedThink": MessageLookupByLibrary.simpleMessage(
      "Wie denkst du, wirst du wahrgenommen?",
    ),
    "importantNotificationHints": MessageLookupByLibrary.simpleMessage(
      "Wichtige Benachrichtigungseinstellungen",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageGerman": MessageLookupByLibrary.simpleMessage("Deutsch"),
    "languageJapanese": MessageLookupByLibrary.simpleMessage("日本語"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wähle deine bevorzugte Sprache",
    ),
    "lastCompleted": MessageLookupByLibrary.simpleMessage(
      "Zuletzt abgeschlossen:",
    ),
    "lastNote": MessageLookupByLibrary.simpleMessage("Letzte Notiz:"),
    "learnSetbacks": MessageLookupByLibrary.simpleMessage(
      "Lerne aus Rückschlägen",
    ),
    "letsGo": MessageLookupByLibrary.simpleMessage("LOS GEHT\'S!"),
    "logbook": MessageLookupByLibrary.simpleMessage("Logbuch"),
    "logbookEntry": MessageLookupByLibrary.simpleMessage("Logbuch-Eintrag"),
    "logbookEntrySaved": MessageLookupByLibrary.simpleMessage(
      "Logbuch-Eintrag gespeichert",
    ),
    "lostForWords": MessageLookupByLibrary.simpleMessage("Sprachlos?"),
    "mindsetGrowth": MessageLookupByLibrary.simpleMessage("Mindset & Wachstum"),
    "mindsetShapesReality": MessageLookupByLibrary.simpleMessage(
      "Deine Denkweise formt deine Realität.",
    ),
    "mindsetTips": MessageLookupByLibrary.simpleMessage("Mindset-Tipps"),
    "morning": MessageLookupByLibrary.simpleMessage("Morgen"),
    "motivationMessage1": MessageLookupByLibrary.simpleMessage(
      "Bereit für eine neue Herausforderung? Los geht\'s!",
    ),
    "motivationMessage2": MessageLookupByLibrary.simpleMessage(
      "Weiter so! Probiere heute eine Challenge aus!",
    ),
    "motivationMessage3": MessageLookupByLibrary.simpleMessage(
      "Dein nächster Erfolg wartet. Nimm eine Challenge an!",
    ),
    "motivationMessage4": MessageLookupByLibrary.simpleMessage(
      "Kleine Schritte, große Ergebnisse. Mach eine Challenge!",
    ),
    "motivationMessage5": MessageLookupByLibrary.simpleMessage(
      "Bleib motiviert! Absolviere jetzt eine Challenge!",
    ),
    "motivationMessage6": MessageLookupByLibrary.simpleMessage(
      "Du bist die Sonne! Aber was ist die Sonne, wenn sie nicht scheinen kann?\nMach eine Challenge!",
    ),
    "motivationMessage7": MessageLookupByLibrary.simpleMessage(
      "Bist du draußen? Dann solltest du eine Challenge machen!",
    ),
    "motivationMessage8": MessageLookupByLibrary.simpleMessage(
      "Es dauert nur 5 Minuten, eine Challenge zu machen!\nWorauf wartest du?",
    ),
    "motivationalQuote": MessageLookupByLibrary.simpleMessage(
      "\"Die einzige Grenze für die Verwirklichung von morgen werden unsere Zweifel von heute sein.\"",
    ),
    "navChallenge": MessageLookupByLibrary.simpleMessage("Challenge"),
    "navDaily": MessageLookupByLibrary.simpleMessage("Täglich"),
    "navSettings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "navStats": MessageLookupByLibrary.simpleMessage("Statistik"),
    "negative": MessageLookupByLibrary.simpleMessage("Negativ"),
    "neutral": MessageLookupByLibrary.simpleMessage("Neutral"),
    "newChallenge": MessageLookupByLibrary.simpleMessage("Neu"),
    "nextMotivation1": m2,
    "nextMotivation2": m3,
    "noChalllengesFound": MessageLookupByLibrary.simpleMessage(
      "Keine Challenges gefunden",
    ),
    "noNotesYet": MessageLookupByLibrary.simpleMessage(
      "Du hast noch keine Notizen für diese Challenge.",
    ),
    "notSureWhatToSay": MessageLookupByLibrary.simpleMessage(
      "Nicht sicher was du sagen sollst?",
    ),
    "notToday": MessageLookupByLibrary.simpleMessage("Heute nicht 🙈"),
    "notes": MessageLookupByLibrary.simpleMessage("Notizen:"),
    "notesPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Deine Gedanken, Beobachtungen, ...",
    ),
    "notificationPermissionsDescription": MessageLookupByLibrary.simpleMessage(
      "Für zuverlässige Benachrichtigungen deaktiviere bitte die Batterieoptimierung für diese App und überprüfe deine Autostart-/Hintergrund-App-Einstellungen.",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
    "notificationsDisabled": MessageLookupByLibrary.simpleMessage(
      "🔕 Benachrichtigungen deaktiviert",
    ),
    "notificationsEnabled": MessageLookupByLibrary.simpleMessage(
      "✅ Benachrichtigungen aktiviert",
    ),
    "notificationsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Lass dich an tägliche Herausforderungen erinnern",
    ),
    "okayButton": MessageLookupByLibrary.simpleMessage("Okay"),
    "openBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Batterieeinstellungen öffnen",
    ),
    "perception": MessageLookupByLibrary.simpleMessage("Wahrnehmung"),
    "positive": MessageLookupByLibrary.simpleMessage("Positiv"),
    "preferAnotherChallenge": MessageLookupByLibrary.simpleMessage(
      "Ich hätte lieber eine andere Challenge",
    ),
    "reminderUpdated": m4,
    "repeatChallengeInfo": MessageLookupByLibrary.simpleMessage(
      "Du kannst diese Challenge so oft wiederholen, wie du möchtest!",
    ),
    "saveEntry": MessageLookupByLibrary.simpleMessage("Eintrag speichern"),
    "score": MessageLookupByLibrary.simpleMessage("Punkte:"),
    "searchChallenge": MessageLookupByLibrary.simpleMessage("Challenge suchen"),
    "searchForChallenge": MessageLookupByLibrary.simpleMessage(
      "Nach einer Challenge suchen...",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "shuffleTooltip": MessageLookupByLibrary.simpleMessage(
      "Challenges mischen",
    ),
    "solo": MessageLookupByLibrary.simpleMessage("Solo"),
    "soundEffects": MessageLookupByLibrary.simpleMessage("Soundeffekte"),
    "soundEffectsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Spiele Töne für Interaktionen",
    ),
    "startChallengeQuestion": MessageLookupByLibrary.simpleMessage(
      "Hast du die heutige Challenge geschafft?",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stayCurious": MessageLookupByLibrary.simpleMessage(
      "Bleibe neugierig und aufgeschlossen",
    ),
    "stillSecondsLeft": m5,
    "streak": MessageLookupByLibrary.simpleMessage("Serie"),
    "thankYouFeedback": MessageLookupByLibrary.simpleMessage(
      "Danke für dein Feedback!",
    ),
    "timeRemaining": MessageLookupByLibrary.simpleMessage("Verbleibende Zeit"),
    "timeUpNotificationBody": MessageLookupByLibrary.simpleMessage(
      "Deine Challenge-Zeit ist vorbei! Zeit für Action! 💪",
    ),
    "timeUpNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "Zeit ist um!",
    ),
    "today": MessageLookupByLibrary.simpleMessage("Heute"),
    "tooBad": MessageLookupByLibrary.simpleMessage(
      "Schade! Du hast die Challenge abgebrochen.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "tryAgainNextTime": MessageLookupByLibrary.simpleMessage(
      "Versuch es beim nächsten Mal!",
    ),
    "veryBad": MessageLookupByLibrary.simpleMessage("Sehr schlecht"),
    "veryGood": MessageLookupByLibrary.simpleMessage("Sehr gut"),
    "veryNegative": MessageLookupByLibrary.simpleMessage("Sehr negativ"),
    "veryPositive": MessageLookupByLibrary.simpleMessage("Sehr positiv"),
    "weeklyChallenges": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Challenges",
    ),
    "weeklyXpProgress": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Aura",
    ),
    "wellDone": MessageLookupByLibrary.simpleMessage(
      "Gut gemacht! Mach weiter so!",
    ),
    "xp": MessageLookupByLibrary.simpleMessage("XP"),
    "yesChallengeStart": MessageLookupByLibrary.simpleMessage(
      "Ja, ich habe sie gemacht",
    ),
    "yourStatistics": MessageLookupByLibrary.simpleMessage("Deine Statistiken"),
  };
}
