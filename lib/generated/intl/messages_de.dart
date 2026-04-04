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

  static String m1(id) => "Challenge #${id}";

  static String m2(challengeTitle) =>
      "Deine Challenge \"${challengeTitle}\" ist gerade beendet! 🏆";

  static String m3(done, needed, next) =>
      "${done} / ${needed} Abschlüsse bis Level ${next}";

  static String m4(streak) => "Tag ${streak} — bleib dran.";

  static String m5(level) => "Level ${level}";

  static String m6(level) => "Level ${level} freigeschaltet!";

  static String m7(time) => "Nächste Motivation 1: ${time}";

  static String m8(time) => "Nächste Motivation 2: ${time}";

  static String m9(period, time) =>
      "⏰ ${period} Erinnerung aktualisiert auf ${time}";

  static String m10(seconds) => "In ${seconds} Sekunden verfügbar";

  static String m11(minutes) => "${minutes} Minuten mutig gewesen.";

  static String m12(count) =>
      "Du bist ${count} Mal aus deiner Komfortzone herausgetreten.";

  static String m13(days) =>
      "Du bist auf einem ${days}-Tage-Streak. Bleib dran!";

  static String m14(kilo) =>
      "${kilo}k XP verdient — du baust etwas Echtes auf.";

  static String m15(xp) => "${xp} XP durch echtes Handeln verdient.";

  static String m16(days) => "Du bist seit ${days} Tagen dabei. Weiter so.";

  static String m17(days) => "${days}-Tage-Serie!";

  static String m18(done, goal) => "${done} von ${goal} Challenges diese Woche";

  static String m19(n) =>
      "Diese Woche hast du ${n} Challenges abgeschlossen. Weiter so!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Über"),
    "aboutDescription": MessageLookupByLibrary.simpleMessage(
      "Syntra ist eine innovative App, die Nutzern hilft, soziale Herausforderungen zu meistern und ihre Ziele zu erreichen.",
    ),
    "aboutSubtitle": MessageLookupByLibrary.simpleMessage(
      "App-Version und Informationen",
    ),
    "aboutTheApp": MessageLookupByLibrary.simpleMessage("Über die App"),
    "acceptChallenge": MessageLookupByLibrary.simpleMessage(
      "Challenge annehmen",
    ),
    "activity": MessageLookupByLibrary.simpleMessage("Aktivität"),
    "activitySubtitle": MessageLookupByLibrary.simpleMessage(
      "12 Wochen — jedes Quadrat ist ein Tag",
    ),
    "addCustomChallenge": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "addCustomChallengeTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "afternoon": MessageLookupByLibrary.simpleMessage("Nachmittag"),
    "allPermissionsGranted": MessageLookupByLibrary.simpleMessage(
      "Alle Berechtigungen erfolgreich erteilt!",
    ),
    "allRightsReserved": MessageLookupByLibrary.simpleMessage(
      "© 2025 Syntra. Alle Rechte vorbehalten.",
    ),
    "allSet": MessageLookupByLibrary.simpleMessage("Alles bereit!"),
    "allowExactAlarms": MessageLookupByLibrary.simpleMessage(
      "Genaue Alarme zulassen",
    ),
    "auraPoints": MessageLookupByLibrary.simpleMessage("Aura"),
    "backToHome": MessageLookupByLibrary.simpleMessage("Zurück zum Hauptmenü"),
    "bad": MessageLookupByLibrary.simpleMessage("Schlecht"),
    "badgeBraveMinutes": MessageLookupByLibrary.simpleMessage("60 Min. mutig"),
    "badgeCenturyXp": MessageLookupByLibrary.simpleMessage("100-XP-Club"),
    "badgeFiftyChallenges": MessageLookupByLibrary.simpleMessage(
      "50 Challenges",
    ),
    "badgeFirstStep": MessageLookupByLibrary.simpleMessage("Erster Schritt"),
    "badgeFiveHundredXp": MessageLookupByLibrary.simpleMessage(
      "500-XP-Legende",
    ),
    "badgeSevenDayStreak": MessageLookupByLibrary.simpleMessage(
      "7-Tage-Streak",
    ),
    "badgeTenChallenges": MessageLookupByLibrary.simpleMessage("10 Challenges"),
    "badgeThreeDayStreak": MessageLookupByLibrary.simpleMessage(
      "3-Tage-Streak",
    ),
    "badgesLocked": MessageLookupByLibrary.simpleMessage(
      "Weiter so, um mehr freizuschalten!",
    ),
    "badgesTitle": MessageLookupByLibrary.simpleMessage("Abzeichen"),
    "basicNotifications": MessageLookupByLibrary.simpleMessage(
      "Basis-Benachrichtigungen",
    ),
    "bestStreak": MessageLookupByLibrary.simpleMessage("Bester Streak"),
    "boldMove": MessageLookupByLibrary.simpleMessage("Mutiger Schritt"),
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
    "challengeInformation": MessageLookupByLibrary.simpleMessage(
      "Challenge-Information",
    ),
    "challengeLogbook": MessageLookupByLibrary.simpleMessage(
      "Challenge-Logbuch",
    ),
    "challengeName": MessageLookupByLibrary.simpleMessage("Challenge-Name"),
    "challengeNumber": m1,
    "challengeStartQuestion": MessageLookupByLibrary.simpleMessage(
      "Challenge starten?",
    ),
    "challengeTimerCompleteBody": m2,
    "challengeTimerCompleteTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Timer abgelaufen!",
    ),
    "challengeType": MessageLookupByLibrary.simpleMessage("Challenge-Typ"),
    "challengesShuffled": MessageLookupByLibrary.simpleMessage(
      "Challenges gemischt!",
    ),
    "challengesThisWeek": MessageLookupByLibrary.simpleMessage(
      "Challenges diese Woche",
    ),
    "chartExplanation": MessageLookupByLibrary.simpleMessage(
      "Jeder Balken ist ein Tag. Grün = geschafft, orange = versucht.",
    ),
    "closeDialog": MessageLookupByLibrary.simpleMessage("Schließen"),
    "coachMsg1": MessageLookupByLibrary.simpleMessage(
      "Du hast gerade etwas getan, was die meisten nie versuchen. Das erfordert Mut.",
    ),
    "coachMsg2": MessageLookupByLibrary.simpleMessage(
      "Jedes Mal wird es 1% leichter. Wirklich.",
    ),
    "coachMsg3": MessageLookupByLibrary.simpleMessage(
      "Dein Nervensystem hat gerade gelernt, dass du überlebt hast. Das zählt.",
    ),
    "coachMsg4": MessageLookupByLibrary.simpleMessage(
      "Wachstum passiert außerhalb der Komfortzone. Du warst gerade dort.",
    ),
    "coachMsg5": MessageLookupByLibrary.simpleMessage(
      "Unbeholfenheit ist nur Mut in den falschen Schuhen. Du warst da.",
    ),
    "coachMsg6": MessageLookupByLibrary.simpleMessage(
      "Eine Aktion nach der anderen. Du baust etwas Echtes auf.",
    ),
    "coachMsg7": MessageLookupByLibrary.simpleMessage(
      "Die Version von dir vor sechs Monaten wäre stolz.",
    ),
    "comfortZone": MessageLookupByLibrary.simpleMessage("Komfortzone"),
    "comfortZoneLevel": MessageLookupByLibrary.simpleMessage(
      "Komfortzonen-Level",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Kommt bald"),
    "completeChallengesToSee": MessageLookupByLibrary.simpleMessage(
      "Schließe ein paar Challenges ab, um sie hier zu sehen!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "completionsToLevel": m3,
    "congratulations": MessageLookupByLibrary.simpleMessage(
      "Glückwunsch! Du hast die Challenge abgeschlossen.",
    ),
    "couldNotOpenLink": MessageLookupByLibrary.simpleMessage(
      "Link konnte nicht geöffnet werden",
    ),
    "dailyBonus": MessageLookupByLibrary.simpleMessage("Tages-Bonus"),
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
    "dayStreak": MessageLookupByLibrary.simpleMessage("Tage-Streak"),
    "dbDebugShow": MessageLookupByLibrary.simpleMessage(
      "DB Debug: Zeige gesamte Logbuch-Tabelle",
    ),
    "debugDeleteTooltip": MessageLookupByLibrary.simpleMessage("Debug Löschen"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteEntry": MessageLookupByLibrary.simpleMessage("Eintrag löschen"),
    "deleteEntryConfirm": MessageLookupByLibrary.simpleMessage(
      "Möchtest du diesen Logbuch-Eintrag wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.",
    ),
    "deleteEntryQuestion": MessageLookupByLibrary.simpleMessage(
      "Bist du sicher, dass du diesen Eintrag löschen möchtest?",
    ),
    "deliverAtPreciseTimes": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen zur genauen Zeit zustellen",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Beschreibung"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "detailsLabel": MessageLookupByLibrary.simpleMessage("Details"),
    "developerLabel": MessageLookupByLibrary.simpleMessage(
      "Entwickler: SaMaili",
    ),
    "doItLater": MessageLookupByLibrary.simpleMessage("Später machen"),
    "done": MessageLookupByLibrary.simpleMessage("Erledigt"),
    "doneExcited": MessageLookupByLibrary.simpleMessage("GESCHAFFT! 😎"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Heute geschafft"),
    "embraceChallenges": MessageLookupByLibrary.simpleMessage(
      "Betrachte Herausforderungen als Chancen",
    ),
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen aktivieren",
    ),
    "enableReminders": MessageLookupByLibrary.simpleMessage(
      "Erinnerungen aktivieren",
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
    "exactTiming": MessageLookupByLibrary.simpleMessage("Genaue Zeitplanung"),
    "existingChallenge": MessageLookupByLibrary.simpleMessage("Bestehend"),
    "exploreAllChallenges": MessageLookupByLibrary.simpleMessage(
      "Alle Challenges erkunden",
    ),
    "failed": MessageLookupByLibrary.simpleMessage("Gescheitert"),
    "failureCopy": MessageLookupByLibrary.simpleMessage(
      "Die war schwer. Aufzutauchen und es zu versuchen — darum geht\'s.",
    ),
    "failureNotesHint": MessageLookupByLibrary.simpleMessage(
      "Was ist passiert? Was würdest du anders machen? (Auch ein einziges Wort ist ein Gewinn.)",
    ),
    "feeling": MessageLookupByLibrary.simpleMessage("Gefühl"),
    "filterAll": MessageLookupByLibrary.simpleMessage("Alle"),
    "filterFlirtExclude": MessageLookupByLibrary.simpleMessage("Kein Flirt"),
    "filterFlirtLabel": MessageLookupByLibrary.simpleMessage(
      "Flirt-Challenges",
    ),
    "filterFlirtOnly": MessageLookupByLibrary.simpleMessage("Nur Flirt"),
    "filterNewOnly": MessageLookupByLibrary.simpleMessage(
      "Nur neue Challenges",
    ),
    "filterNewOnlySubtitle": MessageLookupByLibrary.simpleMessage(
      "Bereits abgeschlossene Challenges ausblenden",
    ),
    "filterReset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "filterSortBy": MessageLookupByLibrary.simpleMessage("Sortieren nach"),
    "filterSortEasiest": MessageLookupByLibrary.simpleMessage(
      "Einfachste zuerst",
    ),
    "filterSortPopular": MessageLookupByLibrary.simpleMessage("Beliebt"),
    "filterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
    "firstChallengeDesc": MessageLookupByLibrary.simpleMessage(
      "Dauert etwa 2 Minuten. Oder heb sie für später auf.",
    ),
    "flirtTagExplanation": MessageLookupByLibrary.simpleMessage(
      "💘 Flirt-Challenges konzentrieren sich auf spielerische, soziale Interaktionen, um romantisches Selbstvertrauen aufzubauen.",
    ),
    "focusProgress": MessageLookupByLibrary.simpleMessage(
      "Fokussiere dich auf Fortschritt, nicht Perfektion",
    ),
    "forBestExperience": MessageLookupByLibrary.simpleMessage(
      "Für das beste Erlebnis",
    ),
    "fri": MessageLookupByLibrary.simpleMessage("Fr"),
    "getNewMotivation": MessageLookupByLibrary.simpleMessage(
      "Neue Motivation erhalten",
    ),
    "githubLabel": MessageLookupByLibrary.simpleMessage("GitHub: "),
    "giveMeOneTooltip": MessageLookupByLibrary.simpleMessage("Gib mir eine!"),
    "goToSettings": MessageLookupByLibrary.simpleMessage(
      "Zu den Einstellungen",
    ),
    "good": MessageLookupByLibrary.simpleMessage("Gut"),
    "greatJobDaily": MessageLookupByLibrary.simpleMessage(
      "Großartig! Du hast die heutige Challenge gemeistert.",
    ),
    "greetingFresh": MessageLookupByLibrary.simpleMessage(
      "Willkommen zurück. Bereit für einen neuen Start?",
    ),
    "greetingLongTime": MessageLookupByLibrary.simpleMessage(
      "Lange nicht gesehen. Keine Sorge — dein Fortschritt ist noch da.",
    ),
    "greetingStreak": m4,
    "group": MessageLookupByLibrary.simpleMessage("Gruppe"),
    "growthStartsDecision": MessageLookupByLibrary.simpleMessage(
      "Wachstum beginnt mit einer Entscheidung: Mut, Offenheit und Positivität.",
    ),
    "growthZone": MessageLookupByLibrary.simpleMessage("Wachstumszone"),
    "heresYourFirst": MessageLookupByLibrary.simpleMessage(
      "Hier ist deine erste.",
    ),
    "howDidYouFeel": MessageLookupByLibrary.simpleMessage(
      "Wie hast du dich gefühlt?",
    ),
    "howDidYouFeelQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie hast du dich gefühlt?",
    ),
    "howDoYouFeel": MessageLookupByLibrary.simpleMessage("Wie fühlst du dich?"),
    "howPerceivedByOthers": MessageLookupByLibrary.simpleMessage(
      "Wie wurdest du wahrgenommen?",
    ),
    "howPerceivedQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie denkst du, wurdest du wahrgenommen?",
    ),
    "howPerceivedThink": MessageLookupByLibrary.simpleMessage(
      "Wie denkst du, wirst du wahrgenommen?",
    ),
    "imReady": MessageLookupByLibrary.simpleMessage("Ich bin bereit"),
    "importantNotificationHints": MessageLookupByLibrary.simpleMessage(
      "Wichtige Benachrichtigungseinstellungen",
    ),
    "keepGoing": MessageLookupByLibrary.simpleMessage("Weiter so"),
    "keepItUp": MessageLookupByLibrary.simpleMessage("Weiter so"),
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
    "legendCompleted": MessageLookupByLibrary.simpleMessage("Geschafft"),
    "legendTried": MessageLookupByLibrary.simpleMessage("Versucht"),
    "less": MessageLookupByLibrary.simpleMessage("Weniger"),
    "lessLabel": MessageLookupByLibrary.simpleMessage("Weniger"),
    "letsGo": MessageLookupByLibrary.simpleMessage("LOS GEHT\'S!"),
    "letsGoButton": MessageLookupByLibrary.simpleMessage("Los geht\'s"),
    "levelDownBody": MessageLookupByLibrary.simpleMessage(
      "Du kannst nur manuell runterleveln — wieder hochzukommen erfordert erneut Abschlüsse zu sammeln.",
    ),
    "levelDownCancel": MessageLookupByLibrary.simpleMessage(
      "Bleibe wo ich bin",
    ),
    "levelDownConfirm": MessageLookupByLibrary.simpleMessage(
      "Ja, Schritt zurück",
    ),
    "levelDownTitle": MessageLookupByLibrary.simpleMessage(
      "Einen Schritt zurück?",
    ),
    "levelN": m5,
    "levelUnlocked": m6,
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
    "minutesBrave": MessageLookupByLibrary.simpleMessage("Min. mutig"),
    "mon": MessageLookupByLibrary.simpleMessage("Mo"),
    "moodTrend": MessageLookupByLibrary.simpleMessage("Stimmungsverlauf"),
    "more": MessageLookupByLibrary.simpleMessage("Mehr"),
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
    "newChallengesAvailable": MessageLookupByLibrary.simpleMessage(
      "Neue Challenges sind jetzt in deinem Katalog verfügbar.",
    ),
    "nextMotivation1": m7,
    "nextMotivation2": m8,
    "noChalllengesFound": MessageLookupByLibrary.simpleMessage(
      "Keine Challenges gefunden",
    ),
    "noEntriesYet": MessageLookupByLibrary.simpleMessage("Noch keine Einträge"),
    "noNotesYet": MessageLookupByLibrary.simpleMessage(
      "Du hast noch keine Notizen für diese Challenge.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Nicht jetzt"),
    "notSureWhatToSay": MessageLookupByLibrary.simpleMessage(
      "Nicht sicher was du sagen sollst?",
    ),
    "notToday": MessageLookupByLibrary.simpleMessage("Heute nicht 🙈"),
    "notes": MessageLookupByLibrary.simpleMessage("Notizen:"),
    "notesPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Deine Gedanken, Beobachtungen, ...",
    ),
    "notificationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Syntra benötigt Benachrichtigungsrechte, um dich an deine Challenges zu erinnern und wichtige Updates zu liefern.",
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
    "onboarding1Button": MessageLookupByLibrary.simpleMessage(
      "So funktioniert\'s →",
    ),
    "onboarding1Headline": MessageLookupByLibrary.simpleMessage(
      "Soziale Sicherheit ist eine Fähigkeit.\nFähigkeiten kann man trainieren.",
    ),
    "onboarding1Subtext": MessageLookupByLibrary.simpleMessage(
      "Syntra gibt dir jeden Tag kleine, reale Herausforderungen zum Üben. Keine Kurse. Keine Skripte. Nur du, draußen in der Welt.",
    ),
    "onboarding2Button": MessageLookupByLibrary.simpleMessage("Verstanden →"),
    "onboarding2Headline": MessageLookupByLibrary.simpleMessage(
      "Eine Challenge nach der anderen.",
    ),
    "onboarding2Step1": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Challenge",
    ),
    "onboarding2Step2": MessageLookupByLibrary.simpleMessage(
      "Mach sie — der Timer hilft",
    ),
    "onboarding2Step3": MessageLookupByLibrary.simpleMessage(
      "Protokolliere dein Ergebnis",
    ),
    "onboarding2Subtext": MessageLookupByLibrary.simpleMessage(
      "Jede ist so gestaltet, dass sie dich leicht aus deiner Komfortzone schiebt. Du entscheidest, wie weit.",
    ),
    "onboarding3Button": MessageLookupByLibrary.simpleMessage(
      "Ich bin dabei →",
    ),
    "onboarding3Headline": MessageLookupByLibrary.simpleMessage(
      "Es ist okay, nervös zu sein.\nDarum geht es ja.",
    ),
    "onboarding3Subtext": MessageLookupByLibrary.simpleMessage(
      "Jede Challenge in dieser App ist sicher. Nichts Extremes, nichts Peinliches. Das unangenehme Gefühl ist genau das, was mit der Zeit Selbstvertrauen aufbaut.\n\nDie meisten fühlen es. Keiner stirbt daran.",
    ),
    "onboarding4Headline": MessageLookupByLibrary.simpleMessage(
      "Wo stehst du gerade?",
    ),
    "onboarding4Level1Subtitle": MessageLookupByLibrary.simpleMessage(
      "Soziale Situationen fühlen sich oft unangenehm an",
    ),
    "onboarding4Level1Title": MessageLookupByLibrary.simpleMessage(
      "Ganz am Anfang",
    ),
    "onboarding4Level2Subtitle": MessageLookupByLibrary.simpleMessage(
      "Ich versuche es, aber manchmal blockiere ich",
    ),
    "onboarding4Level2Title": MessageLookupByLibrary.simpleMessage(
      "Etwas Erfahrung",
    ),
    "onboarding4Level3Subtitle": MessageLookupByLibrary.simpleMessage(
      "Ich will mich steigern, nicht bei null anfangen",
    ),
    "onboarding4Level3Title": MessageLookupByLibrary.simpleMessage(
      "Bereit für mehr",
    ),
    "onboarding4Subtext": MessageLookupByLibrary.simpleMessage(
      "Wir zeigen dir Challenges, die zu deinem aktuellen Stand passen.",
    ),
    "onboarding5Button": MessageLookupByLibrary.simpleMessage(
      "Erinnerung einstellen →",
    ),
    "onboarding5Headline": MessageLookupByLibrary.simpleMessage(
      "5 Minuten am Tag reichen.",
    ),
    "onboarding5Subtext": MessageLookupByLibrary.simpleMessage(
      "Die Wissenschaft zur Gewohnheitsbildung sagt: Regelmäßigkeit ist wichtiger als Intensität. Eine kleine Sache, jeden Tag, verändert dein Gehirn. Wortwörtlich.",
    ),
    "openBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Batterieeinstellungen öffnen",
    ),
    "perception": MessageLookupByLibrary.simpleMessage("Wahrnehmung"),
    "positive": MessageLookupByLibrary.simpleMessage("Positiv"),
    "preferAnotherChallenge": MessageLookupByLibrary.simpleMessage(
      "Ich hätte lieber eine andere Challenge",
    ),
    "primingHeadlineDefault": MessageLookupByLibrary.simpleMessage(
      "Atme durch.\nDu schaffst das.",
    ),
    "primingHeadlineFlirt": MessageLookupByLibrary.simpleMessage(
      "Selbstbewusstsein ist attraktiv.",
    ),
    "primingHeadlineGroup": MessageLookupByLibrary.simpleMessage(
      "Du bist dabei, dich mit jemandem echtem zu verbinden.",
    ),
    "primingHeadlineHard": MessageLookupByLibrary.simpleMessage(
      "Das hier erfordert Mut.\nDu hast ihn.",
    ),
    "primingHeadlineQuick": MessageLookupByLibrary.simpleMessage(
      "Ein kleiner Schritt. Mehr nicht.",
    ),
    "primingSubDefault": MessageLookupByLibrary.simpleMessage(
      "Jedes Mal wird es ein bisschen leichter. Dein zukünftiges Ich ist dir schon dankbar.",
    ),
    "primingSubFlirt": MessageLookupByLibrary.simpleMessage(
      "Flirten ist einfach spielerische Kommunikation. Das Ergebnis ist egal — Auftauchen zählt.",
    ),
    "primingSubGroup": MessageLookupByLibrary.simpleMessage(
      "Die meisten Menschen sind freundlicher als du erwartest. Eine Begegnung kann deinen ganzen Tag verändern.",
    ),
    "primingSubHard": MessageLookupByLibrary.simpleMessage(
      "Die Challenges, die dich am meisten einschüchtern, lassen dich am meisten wachsen. Das hier ist eine davon.",
    ),
    "primingSubQuick": MessageLookupByLibrary.simpleMessage(
      "Unter einer Minute Aktion. Das Unbehagen verfliegt schneller als du denkst.",
    ),
    "quote1": MessageLookupByLibrary.simpleMessage(
      "\"Die einzige Grenze für die Verwirklichung von morgen werden unsere Zweifel von heute sein.\"",
    ),
    "quote2": MessageLookupByLibrary.simpleMessage(
      "\"Mut ist nicht die Abwesenheit von Angst, sondern der Triumph darüber.\"",
    ),
    "quote3": MessageLookupByLibrary.simpleMessage(
      "\"Tu jeden Tag eine Sache, die dir Angst macht.\"",
    ),
    "quote4": MessageLookupByLibrary.simpleMessage(
      "\"Das Leben beginnt am Ende deiner Komfortzone.\"",
    ),
    "quote5": MessageLookupByLibrary.simpleMessage(
      "\"Die Höhle, die du fürchtest zu betreten, birgt den Schatz, den du suchst.\"",
    ),
    "quote6": MessageLookupByLibrary.simpleMessage(
      "\"Was würdest du versuchen, wenn du wüsstest, dass du nicht scheitern kannst?\"",
    ),
    "quote7": MessageLookupByLibrary.simpleMessage(
      "\"Alles, was du dir je gewünscht hast, ist auf der anderen Seite der Angst.\"",
    ),
    "quote8": MessageLookupByLibrary.simpleMessage(
      "\"Du gewinnst Stärke, Mut und Selbstvertrauen durch jede Erfahrung, in der du wirklich innehältst und der Angst ins Gesicht schaust.\"",
    ),
    "reachedTheTop": MessageLookupByLibrary.simpleMessage(
      "Du hast die Spitze erreicht. Mach weiter.",
    ),
    "rememberOnMyOwn": MessageLookupByLibrary.simpleMessage(
      "Ich erinnere mich selbst →",
    ),
    "reminderExplanation": MessageLookupByLibrary.simpleMessage(
      "Wir senden dir einen Impuls am Tag — du wählst wann. Kein Spam. Du kannst es jederzeit in den Einstellungen abschalten.",
    ),
    "reminderUpdated": m9,
    "repeatChallengeInfo": MessageLookupByLibrary.simpleMessage(
      "Du kannst diese Challenge so oft wiederholen, wie du möchtest!",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Erforderlich"),
    "retryChallenge": MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "rewardFactor": MessageLookupByLibrary.simpleMessage("Belohnungsfaktor"),
    "sat": MessageLookupByLibrary.simpleMessage("Sa"),
    "saveEntry": MessageLookupByLibrary.simpleMessage("Eintrag speichern"),
    "score": MessageLookupByLibrary.simpleMessage("Punkte:"),
    "searchChallenge": MessageLookupByLibrary.simpleMessage("Challenge suchen"),
    "searchForChallenge": MessageLookupByLibrary.simpleMessage(
      "Nach einer Challenge suchen...",
    ),
    "setDifficultyManually": MessageLookupByLibrary.simpleMessage(
      "Schwierigkeit manuell setzen",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "showReminderNotifications": MessageLookupByLibrary.simpleMessage(
      "Erinnerungsbenachrichtigungen anzeigen",
    ),
    "shuffleTooltip": MessageLookupByLibrary.simpleMessage(
      "Challenges mischen",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "skipForNow": MessageLookupByLibrary.simpleMessage("Erstmal überspringen"),
    "solo": MessageLookupByLibrary.simpleMessage("Solo"),
    "somePermissionsMissing": MessageLookupByLibrary.simpleMessage(
      "Einige Berechtigungen fehlen noch. Bitte aktiviere sie manuell.",
    ),
    "soundEffects": MessageLookupByLibrary.simpleMessage("Soundeffekte"),
    "soundEffectsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Spiele Töne für Interaktionen",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startChallengeQuestion": MessageLookupByLibrary.simpleMessage(
      "Hast du die heutige Challenge geschafft?",
    ),
    "startNow": MessageLookupByLibrary.simpleMessage("Jetzt starten"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusSuccess": MessageLookupByLibrary.simpleMessage("Geschafft"),
    "statusTried": MessageLookupByLibrary.simpleMessage("Versucht"),
    "stayCurious": MessageLookupByLibrary.simpleMessage(
      "Bleibe neugierig und aufgeschlossen",
    ),
    "stillSecondsLeft": m10,
    "storyFirstChallenge": MessageLookupByLibrary.simpleMessage(
      "Deine Geschichte beginnt mit der ersten Challenge, die du abschließt.",
    ),
    "storyMinutesBrave": m11,
    "storyNTimes": m12,
    "storyOnce": MessageLookupByLibrary.simpleMessage(
      "Du bist einmal aus deiner Komfortzone herausgetreten. Das erfordert Mut.",
    ),
    "storyStreakMany": m13,
    "storyStreakOne": MessageLookupByLibrary.simpleMessage(
      "Tag 1 eines neuen Streaks. Jeder große Streak hat hier angefangen.",
    ),
    "storyXpKilo": m14,
    "storyXpSmall": m15,
    "streak": MessageLookupByLibrary.simpleMessage("Serie"),
    "streakMilestone100": MessageLookupByLibrary.simpleMessage(
      "100 Tage. Du hast etwas Außergewöhnliches aufgebaut. Respekt.",
    ),
    "streakMilestone14": MessageLookupByLibrary.simpleMessage(
      "Zwei Wochen durchgezogen. Du bist nicht mehr die gleiche Person wie vor 14 Tagen.",
    ),
    "streakMilestone3": MessageLookupByLibrary.simpleMessage(
      "Drei Tage am Stück. Du baust eine Gewohnheit auf.",
    ),
    "streakMilestone30": MessageLookupByLibrary.simpleMessage(
      "30 Tage. Ein ganzer Monat dranbleiben. Das ist selten. Das ist stark.",
    ),
    "streakMilestone60": MessageLookupByLibrary.simpleMessage(
      "60 Tage. Die meisten geben nach einer Woche auf. Du nicht.",
    ),
    "streakMilestone7": MessageLookupByLibrary.simpleMessage(
      "Eine ganze Woche! Deine Komfortzone ist gerade gewachsen.",
    ),
    "streakMilestoneGeneric": m16,
    "streakMilestoneTitle": m17,
    "sun": MessageLookupByLibrary.simpleMessage("So"),
    "thankYouFeedback": MessageLookupByLibrary.simpleMessage(
      "Danke für dein Feedback!",
    ),
    "threeChallengesTodo": MessageLookupByLibrary.simpleMessage(
      "Drei Challenges. Beliebige Reihenfolge. Alle zählen.",
    ),
    "thu": MessageLookupByLibrary.simpleMessage("Do"),
    "timeRemaining": MessageLookupByLibrary.simpleMessage("Verbleibende Zeit"),
    "timeUpNotificationBody": MessageLookupByLibrary.simpleMessage(
      "Deine Challenge-Zeit ist vorbei! Zeit für Action! 💪",
    ),
    "timeUpNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "Zeit ist um!",
    ),
    "timesTried": MessageLookupByLibrary.simpleMessage("Mal versucht"),
    "today": MessageLookupByLibrary.simpleMessage("Heute"),
    "todaysMissions": MessageLookupByLibrary.simpleMessage("Heutige Missionen"),
    "tooBad": MessageLookupByLibrary.simpleMessage(
      "Schade! Du hast die Challenge abgebrochen.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "totalXp": MessageLookupByLibrary.simpleMessage("Gesamt-XP"),
    "tryAgainNextTime": MessageLookupByLibrary.simpleMessage(
      "Versuch es beim nächsten Mal!",
    ),
    "tue": MessageLookupByLibrary.simpleMessage("Di"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "veryBad": MessageLookupByLibrary.simpleMessage("Sehr schlecht"),
    "veryGood": MessageLookupByLibrary.simpleMessage("Sehr gut"),
    "veryNegative": MessageLookupByLibrary.simpleMessage("Sehr negativ"),
    "veryPositive": MessageLookupByLibrary.simpleMessage("Sehr positiv"),
    "wantReminders": MessageLookupByLibrary.simpleMessage(
      "Sollen wir dich erinnern?",
    ),
    "wed": MessageLookupByLibrary.simpleMessage("Mi"),
    "weeklyChallenges": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Challenges",
    ),
    "weeklyGoalProgress": m18,
    "weeklyGoalSetLabel": MessageLookupByLibrary.simpleMessage("Ziel setzen:"),
    "weeklyGoalTitle": MessageLookupByLibrary.simpleMessage("Wochenziel"),
    "weeklyRecapBody": m19,
    "weeklyRecapTitle": MessageLookupByLibrary.simpleMessage("Wochenrückblick"),
    "weeklyXpProgress": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Aura",
    ),
    "wellDone": MessageLookupByLibrary.simpleMessage(
      "Gut gemacht! Mach weiter so!",
    ),
    "xp": MessageLookupByLibrary.simpleMessage("XP"),
    "xpEarnedThisWeek": MessageLookupByLibrary.simpleMessage("XP diese Woche"),
    "yesChallengeStart": MessageLookupByLibrary.simpleMessage(
      "Ja, ich habe sie gemacht",
    ),
    "yourProgress": MessageLookupByLibrary.simpleMessage("Dein Fortschritt"),
    "yourStatistics": MessageLookupByLibrary.simpleMessage("Deine Statistiken"),
  };
}
