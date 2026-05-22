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

  static String m0(n) => "${n} aktiv";

  static String m1(threshold) => "≥${threshold} Aura";

  static String m2(total, goal) => "${total} / ${goal} Ziel";

  static String m3(level) =>
      "Erreiche Level ${level} auf deiner Komfortzonen-Reise.";

  static String m4(challengeTitle) => "Bereit für: ${challengeTitle}?";

  static String m5(id) => "Challenge #${id}";

  static String m6(challengeTitle) =>
      "Deine Challenge \"${challengeTitle}\" ist gerade beendet! 🏆";

  static String m7(done, needed, next) =>
      "${done} / ${needed} Abschlüsse bis Level ${next}";

  static String m8(level) => "Auf Level ${level} herabstufen";

  static String m9(streak) => "Woche ${streak}, bleib dran.";

  static String m10(n) => "letzte ${n}";

  static String m11(level) => "Level ${level}";

  static String m12(level) => "Level ${level} freigeschaltet!";

  static String m13(n) => "${n} Einträge";

  static String m14(pct) => "Stimmung ${pct}%";

  static String m15(n) => "vor ${n}";

  static String m16(anchor) => "Eher ${anchor}";

  static String m17(time) => "Nächste Motivation 1: ${time}";

  static String m18(time) => "Nächste Motivation 2: ${time}";

  static String m19(n) => "${n} Versuche";

  static String m20(earned, total) => "${earned} / ${total}";

  static String m21(n) => "${n} Einträge";

  static String m22(period, time) =>
      "⏰ ${period} Erinnerung aktualisiert auf ${time}";

  static String m23(aura) => "Verfügbar: ${aura} Aura";

  static String m24(price) => "Kaufen für ${price} Aura";

  static String m25(price) => "Streak Freeze für ${price} Aura kaufen?";

  static String m26(count, max) => "${count} / ${max} im Inventar";

  static String m27(seconds) => "In ${seconds} Sekunden verfügbar";

  static String m28(kilo) =>
      "${kilo}k Aura verdient. Du baust etwas Echtes auf.";

  static String m29(aura) => "${aura} Aura durch echtes Handeln verdient.";

  static String m30(minutes) => "${minutes} Minuten mutig gewesen.";

  static String m31(count) =>
      "Du bist ${count} Mal aus deiner Komfortzone herausgetreten.";

  static String m32(days) =>
      "Du bist auf einem ${days}-Tage-Streak. Bleib dran!";

  static String m33(n) => "${n}-Wochen-Streak lebt";

  static String m34(days) => "Du bist seit ${days} Wochen dabei. Weiter so.";

  static String m35(days) => "${days}-Wochen-Serie!";

  static String m36(n, time, aura) =>
      "${n} Challenges · ~${time} · +${aura} Aura";

  static String m37(vibe) => "Für ${vibe}";

  static String m38(n, time, aura) =>
      "${n} Challenges · ~${time} · +${aura} Aura · zum Neuordnen ziehen";

  static String m39(title) => "Als Nächstes: ${title}";

  static String m40(n, total) => "Warm-up ${n}/${total}";

  static String m41(vibe) => "${vibe} Warm-up";

  static String m42(n) => "vor ${n} Wochen";

  static String m43(done, goal) => "${done} von ${goal} Challenges diese Woche";

  static String m44(n) =>
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
    "activeBack": MessageLookupByLibrary.simpleMessage("Zurück"),
    "activeBail": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "activeGotIt": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "activeHideStarters": MessageLookupByLibrary.simpleMessage(
      "Einstiegssätze ausblenden",
    ),
    "activeImGoing": MessageLookupByLibrary.simpleMessage("Ich mach\'s"),
    "activeLast10Caption": MessageLookupByLibrary.simpleMessage(
      "Gleich geschafft. Hat\'s gezählt?",
    ),
    "activeLastAttempt": MessageLookupByLibrary.simpleMessage(
      "Letzter Versuch",
    ),
    "activeLockHint": MessageLookupByLibrary.simpleMessage(
      "Schaltet frei, sobald du dir wirklich einen Moment Zeit gelassen hast.",
    ),
    "activeNeedStarter": MessageLookupByLibrary.simpleMessage(
      "Brauchst du einen Einstieg?",
    ),
    "activeSeeLastNote": MessageLookupByLibrary.simpleMessage(
      "Letzte Notiz ansehen",
    ),
    "activeStayWithIt": MessageLookupByLibrary.simpleMessage("Bleib dran"),
    "activeWeeksCount": m0,
    "activeYourNote": MessageLookupByLibrary.simpleMessage("Deine Notiz"),
    "activity": MessageLookupByLibrary.simpleMessage("Aktivität"),
    "activityLegendActive": m1,
    "activityLegendFreeze": MessageLookupByLibrary.simpleMessage(
      "Streak-Schutz",
    ),
    "activityLegendQuiet": MessageLookupByLibrary.simpleMessage("Ruhig"),
    "activitySubtitle": MessageLookupByLibrary.simpleMessage(
      "jedes Quadrat ist ein Tag",
    ),
    "addANote": MessageLookupByLibrary.simpleMessage("Notiz hinzufügen"),
    "addCustomChallenge": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "addCustomChallengeTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge hinzufügen",
    ),
    "afterLabel": MessageLookupByLibrary.simpleMessage("Nachher"),
    "afternoon": MessageLookupByLibrary.simpleMessage("Nachmittag"),
    "allBadgesTitle": MessageLookupByLibrary.simpleMessage("Alle Badges"),
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
    "aura": MessageLookupByLibrary.simpleMessage("Aura"),
    "auraEarnedLabel": MessageLookupByLibrary.simpleMessage("Aura verdient"),
    "auraEarnedThisWeek": MessageLookupByLibrary.simpleMessage(
      "Aura diese Woche",
    ),
    "auraPoints": MessageLookupByLibrary.simpleMessage("Aura"),
    "auraWalletLabel": MessageLookupByLibrary.simpleMessage("Deine Aura"),
    "auraWeekRight": m2,
    "avgMoodEmpty": MessageLookupByLibrary.simpleMessage(
      "Bewerte dein Gefühl nach jeder Challenge, um deinen Stimmungsverlauf zu sehen.",
    ),
    "avgMoodSubtitle": MessageLookupByLibrary.simpleMessage(
      "Basierend auf deiner Bewertung nach jeder abgeschlossenen Challenge",
    ),
    "avgMoodTitle": MessageLookupByLibrary.simpleMessage(
      "Stimmungsverlauf (letzte 20 Einträge)",
    ),
    "backToHome": MessageLookupByLibrary.simpleMessage("Zurück zum Hauptmenü"),
    "bad": MessageLookupByLibrary.simpleMessage("Schlecht"),
    "badgeBraveMinutes": MessageLookupByLibrary.simpleMessage("60 Min. mutig"),
    "badgeBraveMinutesDesc": MessageLookupByLibrary.simpleMessage(
      "Verbringe 60 Minuten mutig",
    ),
    "badgeCenturyAura": MessageLookupByLibrary.simpleMessage("100-Aura-Club"),
    "badgeCenturyAuraDesc": MessageLookupByLibrary.simpleMessage(
      "Verdiene 100 Aura-Punkte",
    ),
    "badgeFiftyChallenges": MessageLookupByLibrary.simpleMessage(
      "50 Challenges",
    ),
    "badgeFiftyChallengesDesc": MessageLookupByLibrary.simpleMessage(
      "Schließe 50 Challenges ab",
    ),
    "badgeFirstStep": MessageLookupByLibrary.simpleMessage("Erster Schritt"),
    "badgeFirstStepDesc": MessageLookupByLibrary.simpleMessage(
      "Schließe deine erste Challenge ab",
    ),
    "badgeFiveHundredAura": MessageLookupByLibrary.simpleMessage(
      "500-Aura-Legende",
    ),
    "badgeFiveHundredAuraDesc": MessageLookupByLibrary.simpleMessage(
      "Verdiene 500 Aura-Punkte",
    ),
    "badgeLevelDesc": m3,
    "badgeLocked": MessageLookupByLibrary.simpleMessage("Gesperrt"),
    "badgeOpted": MessageLookupByLibrary.simpleMessage("Geschafft"),
    "badgeSevenWeekStreak": MessageLookupByLibrary.simpleMessage(
      "7-Wochen-Streak",
    ),
    "badgeSevenWeekStreakDesc": MessageLookupByLibrary.simpleMessage(
      "Baue einen 7-Wochen-Streak auf",
    ),
    "badgeTenChallenges": MessageLookupByLibrary.simpleMessage("10 Challenges"),
    "badgeTenChallengesDesc": MessageLookupByLibrary.simpleMessage(
      "Schließe 10 Challenges ab",
    ),
    "badgeThreeWeekStreak": MessageLookupByLibrary.simpleMessage(
      "3-Wochen-Streak",
    ),
    "badgeThreeWeekStreakDesc": MessageLookupByLibrary.simpleMessage(
      "Baue einen 3-Wochen-Streak auf",
    ),
    "badgesAllUnlocked": MessageLookupByLibrary.simpleMessage(
      "Du hast alle Badges freigeschaltet. Unglaublich!",
    ),
    "badgesEarnedSection": MessageLookupByLibrary.simpleMessage("Geschafft"),
    "badgesLocked": MessageLookupByLibrary.simpleMessage(
      "Weiter so, um mehr freizuschalten!",
    ),
    "badgesLockedSection": MessageLookupByLibrary.simpleMessage("Gesperrt"),
    "badgesTitle": MessageLookupByLibrary.simpleMessage("Abzeichen"),
    "bailBody": MessageLookupByLibrary.simpleMessage(
      "Kein Streak-Verlust. Hinzugehen ist die halbe Miete, und das hast du schon geschafft.",
    ),
    "bailKeepGoing": MessageLookupByLibrary.simpleMessage("Weitermachen"),
    "bailSaveForLater": MessageLookupByLibrary.simpleMessage(
      "Für später speichern",
    ),
    "bailTitle": MessageLookupByLibrary.simpleMessage("Für später speichern?"),
    "basicNotifications": MessageLookupByLibrary.simpleMessage(
      "Basis-Benachrichtigungen",
    ),
    "beforeLabel": MessageLookupByLibrary.simpleMessage("Vorher"),
    "bestStreak": MessageLookupByLibrary.simpleMessage("Rekord"),
    "boldMove": MessageLookupByLibrary.simpleMessage("Mutiger Schritt"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "celebrateEyebrow": MessageLookupByLibrary.simpleMessage(
      "Challenge geschafft",
    ),
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
    "challengeConfirmMessage": m4,
    "challengeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge starten?",
    ),
    "challengeDescriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge-Beschreibung",
    ),
    "challengeDetails": MessageLookupByLibrary.simpleMessage(
      "Challenge-Details",
    ),
    "challengeHintsTitle": MessageLookupByLibrary.simpleMessage("Sprachlos?"),
    "challengeId": MessageLookupByLibrary.simpleMessage("Challenge-ID"),
    "challengeInformation": MessageLookupByLibrary.simpleMessage(
      "Challenge-Information",
    ),
    "challengeLogbook": MessageLookupByLibrary.simpleMessage(
      "Challenge-Logbuch",
    ),
    "challengeName": MessageLookupByLibrary.simpleMessage("Challenge-Name"),
    "challengeNumber": m5,
    "challengeStartQuestion": MessageLookupByLibrary.simpleMessage(
      "Challenge starten?",
    ),
    "challengeTimerCompleteBody": m6,
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
    "coachBreath": MessageLookupByLibrary.simpleMessage("Atme tief durch."),
    "coachMoment": MessageLookupByLibrary.simpleMessage("Wähle deinen Moment."),
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
    "coachNoRush": MessageLookupByLibrary.simpleMessage(
      "Keine Eile. Geh, wenn\'s sich richtig anfühlt.",
    ),
    "coachWantsToo": MessageLookupByLibrary.simpleMessage(
      "Sie wollen auch angesprochen werden.",
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
    "completionsToLevel": m7,
    "congratulations": MessageLookupByLibrary.simpleMessage(
      "Glückwunsch! Du hast die Challenge abgeschlossen.",
    ),
    "coop": MessageLookupByLibrary.simpleMessage("Coop"),
    "couldNotOpenLink": MessageLookupByLibrary.simpleMessage(
      "Link konnte nicht geöffnet werden",
    ),
    "dailyBonus": MessageLookupByLibrary.simpleMessage("Tages-Bonus"),
    "dailyChallenge": MessageLookupByLibrary.simpleMessage(
      "Tägliche Challenge",
    ),
    "dailyReminderLabel": MessageLookupByLibrary.simpleMessage(
      "Tägliche Erinnerung",
    ),
    "dailyReminderSublabel": MessageLookupByLibrary.simpleMessage(
      "Ein Anstoß für deine tägliche Challenge",
    ),
    "dailyReminders": MessageLookupByLibrary.simpleMessage(
      "Tägliche Erinnerungen",
    ),
    "dailyRemindersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Lass dich daran erinnern, Herausforderungen zu meistern",
    ),
    "dare": MessageLookupByLibrary.simpleMessage("Dare"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Design"),
    "darkModeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wähle dein bevorzugtes Erscheinungsbild",
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
    "doneExcited": MessageLookupByLibrary.simpleMessage("GESCHAFFT!"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Heute"),
    "downgradeToLevel": m8,
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
      "Die war schwer. Aufzutauchen und es zu versuchen: darum geht\'s.",
    ),
    "failureNotesHint": MessageLookupByLibrary.simpleMessage(
      "Was ist passiert? Was würdest du anders machen? (Auch ein einziges Wort ist ein Gewinn.)",
    ),
    "feeling": MessageLookupByLibrary.simpleMessage("Gefühl"),
    "feelingScaleHigh": MessageLookupByLibrary.simpleMessage("Großartig"),
    "feelingScaleLow": MessageLookupByLibrary.simpleMessage("Mies"),
    "filterAll": MessageLookupByLibrary.simpleMessage("Alle"),
    "filterAuraHigh": MessageLookupByLibrary.simpleMessage("Hoch"),
    "filterAuraLabel": MessageLookupByLibrary.simpleMessage("Aura"),
    "filterAuraLow": MessageLookupByLibrary.simpleMessage("Niedrig"),
    "filterAuraMedium": MessageLookupByLibrary.simpleMessage("Mittel"),
    "filterCompletionAll": MessageLookupByLibrary.simpleMessage("Alle"),
    "filterCompletionDone": MessageLookupByLibrary.simpleMessage(
      "Abgeschlossen",
    ),
    "filterCompletionLabel": MessageLookupByLibrary.simpleMessage("Abschluss"),
    "filterCompletionNotDone": MessageLookupByLibrary.simpleMessage("Nur neue"),
    "filterEnvCafe": MessageLookupByLibrary.simpleMessage("☕ Café"),
    "filterEnvEvent": MessageLookupByLibrary.simpleMessage("🎉 Event"),
    "filterEnvLabel": MessageLookupByLibrary.simpleMessage("Ort"),
    "filterEnvStreet": MessageLookupByLibrary.simpleMessage("🚶 Straße"),
    "filterEnvTransit": MessageLookupByLibrary.simpleMessage("🚌 Transit"),
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
    "filterOrderAuraAsc": MessageLookupByLibrary.simpleMessage(
      "Aura: Niedrig → Hoch",
    ),
    "filterOrderAuraDesc": MessageLookupByLibrary.simpleMessage(
      "Aura: Hoch → Niedrig",
    ),
    "filterOrderCompletionLabel": MessageLookupByLibrary.simpleMessage(
      "Abschluss",
    ),
    "filterOrderCompletionNewest": MessageLookupByLibrary.simpleMessage(
      "Neueste zuerst",
    ),
    "filterOrderCompletionNone": MessageLookupByLibrary.simpleMessage("Egal"),
    "filterOrderCompletionOldest": MessageLookupByLibrary.simpleMessage(
      "Älteste zuerst",
    ),
    "filterOrderDefault": MessageLookupByLibrary.simpleMessage("Standard"),
    "filterOrderLabel": MessageLookupByLibrary.simpleMessage("Reihenfolge"),
    "filterReset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "filterSortBy": MessageLookupByLibrary.simpleMessage("Sortieren nach"),
    "filterSortEasiest": MessageLookupByLibrary.simpleMessage(
      "Einfachste zuerst",
    ),
    "filterSortPopular": MessageLookupByLibrary.simpleMessage("Beliebt"),
    "filterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
    "filterTypeLabel": MessageLookupByLibrary.simpleMessage("Challenge-Typ"),
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
    "gapNegative": MessageLookupByLibrary.simpleMessage(
      "Es war schwieriger als erwartet. Das ist okay.",
    ),
    "gapNeutral": MessageLookupByLibrary.simpleMessage(
      "Deine Erwartung hat gestimmt.",
    ),
    "gapPositive": MessageLookupByLibrary.simpleMessage(
      "Du hast dich besser gefühlt als erwartet.",
    ),
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
    "greetingLongTime": MessageLookupByLibrary.simpleMessage(
      "Lange nicht gesehen. Keine Sorge, dein Fortschritt ist noch da.",
    ),
    "greetingStreak": m9,
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
    "howNervousQuestion": MessageLookupByLibrary.simpleMessage(
      "Wie nervös warst du vorher?",
    ),
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
    "lastNCount": m10,
    "lastNote": MessageLookupByLibrary.simpleMessage("Letzte Notiz:"),
    "lastNoteTitle": MessageLookupByLibrary.simpleMessage("Letzte Notiz"),
    "learnSetbacks": MessageLookupByLibrary.simpleMessage(
      "Lerne aus Rückschlägen",
    ),
    "legendCompleted": MessageLookupByLibrary.simpleMessage("Geschafft"),
    "legendTried": MessageLookupByLibrary.simpleMessage("Versucht"),
    "less": MessageLookupByLibrary.simpleMessage("Weniger"),
    "lessLabel": MessageLookupByLibrary.simpleMessage("Weniger"),
    "letsGo": MessageLookupByLibrary.simpleMessage("LOS GEHT\'S!"),
    "letsGoButton": MessageLookupByLibrary.simpleMessage("Los geht\'s"),
    "levelDesc1": MessageLookupByLibrary.simpleMessage(
      "Das Unbehagen ist rein innerlich: Ego, Selbstbewusstsein, die Angst, gesehen zu werden. Keine Worte nötig. Klein von außen, echt von innen.",
    ),
    "levelDesc10": MessageLookupByLibrary.simpleMessage(
      "Für Dinge, die sich gerade außerhalb des Akzeptablen anfühlen. Nicht gefährlich, nicht schädlich, nicht illegal. Aber die Art von Ding, die einen Passanten zweimal hinschauen lässt. Du spürst das Gewicht davon. Du gehst trotzdem.",
    ),
    "levelDesc2": MessageLookupByLibrary.simpleMessage(
      "Ein Satz, ein Fremder: jemand, der bereits dort ist und in gewisser Weise eine Interaktion erwartet (Kassiererin, Barista, Rezeptionist). Du initiierst, aber das soziale Skript ist vertraut. Das Unbehagen liegt darin, zuerst zu sprechen.",
    ),
    "levelDesc3": MessageLookupByLibrary.simpleMessage(
      "Du sprichst jemanden an, der keinen besonderen Grund hat, dich zu erwarten. Kurz, aber echt: 2 bis 3 Austausche. Du beginnst und hältst mindestens einen weiteren Austausch aufrecht. Das Unbehagen liegt darin, präsent zu bleiben, wenn der Einstieg geklappt hat.",
    ),
    "levelDesc4": MessageLookupByLibrary.simpleMessage(
      "Du bringst etwas von dir in die Interaktion ein: ein echtes Kompliment, eine persönliche Meinung, einen kleinen Akt der Selbstbehauptung. Das Unbehagen liegt darin, etwas zu sagen, das zeigt, was du bemerkst oder denkst.",
    ),
    "levelDesc5": MessageLookupByLibrary.simpleMessage(
      "Du sprichst jemanden ohne soziale Absicherung an: keinen Grund, keinen Servicekontext. Ablehnung ist möglich und sichtbar. Eine anhaltende Interaktion oder ein mutiger Einstieg, der echtes Selbstvertrauen erfordert.",
    ),
    "levelDesc6": MessageLookupByLibrary.simpleMessage(
      "Mehr Augen, höhere Einsätze. Du sprichst eine Gruppe an oder führst die Interaktion: mehrere Personen befragen, eine ungewöhnliche Bitte stellen. Das Unbehagen liegt darin, derjenige zu sein, der sichtbar etwas gestartet hat.",
    ),
    "levelDesc7": MessageLookupByLibrary.simpleMessage(
      "Du erklärst etwas über dich selbst oder dein Interesse an einer anderen Person: direkt, klar, ohne es zu verwässern. Oder du tust etwas, das die Aufmerksamkeit mehrerer Menschen auf einmal zieht. Verletzlich und öffentlich.",
    ),
    "levelDesc8": MessageLookupByLibrary.simpleMessage(
      "Du tust etwas, das echten Mut braucht. Körperliche Kühnheit, bewusste Unbeholfenheit vollständig gelebt oder tiefe persönliche Offenbarung gegenüber einem Fremden. Ein kontrollierter, selbstbewusster Schritt in Unbehagen.",
    ),
    "levelDesc9": MessageLookupByLibrary.simpleMessage(
      "Du wirst zum Spektakel. Du tust etwas, das ein anhaltendes Publikum anzieht oder erfordert, laut zu sprechen, aufzutreten oder dich so zu verhalten, dass Fremde sich umdrehen. Der Kern ist die Exposition: angeschaut werden und jeden Moment davon besitzen.",
    ),
    "levelDownBody": MessageLookupByLibrary.simpleMessage(
      "Du kannst nur manuell runterleveln. Wieder hochzukommen erfordert erneut Abschlüsse zu sammeln.",
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
    "levelN": m11,
    "levelName1": MessageLookupByLibrary.simpleMessage("Aufwärmen"),
    "levelName10": MessageLookupByLibrary.simpleMessage("Unberührbar"),
    "levelName2": MessageLookupByLibrary.simpleMessage("Das Eis brechen"),
    "levelName3": MessageLookupByLibrary.simpleMessage("Im Mittelpunkt stehen"),
    "levelName4": MessageLookupByLibrary.simpleMessage("Risiken eingehen"),
    "levelName5": MessageLookupByLibrary.simpleMessage("Die mutige Zone"),
    "levelName6": MessageLookupByLibrary.simpleMessage("Eine Stufe höher"),
    "levelName7": MessageLookupByLibrary.simpleMessage("Den Raum beherrschen"),
    "levelName8": MessageLookupByLibrary.simpleMessage("Sozialer Athlet"),
    "levelName9": MessageLookupByLibrary.simpleMessage("Furchtlos"),
    "levelUnlocked": m12,
    "logbook": MessageLookupByLibrary.simpleMessage("Logbuch"),
    "logbookChallengesPlural": MessageLookupByLibrary.simpleMessage(
      "Challenges",
    ),
    "logbookEightWksAgo": MessageLookupByLibrary.simpleMessage("vor 8 Wo."),
    "logbookEntriesCount": m13,
    "logbookEntry": MessageLookupByLibrary.simpleMessage("Logbuch-Eintrag"),
    "logbookEntrySaved": MessageLookupByLibrary.simpleMessage(
      "Logbuch-Eintrag gespeichert",
    ),
    "logbookFilterAll": MessageLookupByLibrary.simpleMessage("Alle"),
    "logbookFilterCompleted": MessageLookupByLibrary.simpleMessage(
      "Abgeschlossen",
    ),
    "logbookFilterTried": MessageLookupByLibrary.simpleMessage("Versucht"),
    "logbookInsightBetter": MessageLookupByLibrary.simpleMessage(
      "Du hast dich besser gefühlt als erwartet.",
    ),
    "logbookInsightEyebrow": MessageLookupByLibrary.simpleMessage("Erkenntnis"),
    "logbookInsightMatched": MessageLookupByLibrary.simpleMessage(
      "Deine Vorhersage hat gestimmt.",
    ),
    "logbookInsightWorse": MessageLookupByLibrary.simpleMessage(
      "Es war schwerer als erwartet.",
    ),
    "logbookMoodDelta": m14,
    "logbookMoodTrendEyebrow": MessageLookupByLibrary.simpleMessage(
      "Stimmungsverlauf",
    ),
    "logbookNoteEyebrow": MessageLookupByLibrary.simpleMessage("Notiz"),
    "logbookNow": MessageLookupByLibrary.simpleMessage("Jetzt"),
    "logbookReflectionEyebrow": MessageLookupByLibrary.simpleMessage(
      "Reflexion",
    ),
    "logbookSearchHint": MessageLookupByLibrary.simpleMessage(
      "Nach Challenge-ID suchen…",
    ),
    "logbookThisMonth": MessageLookupByLibrary.simpleMessage("Dieser Monat"),
    "lostForWords": MessageLookupByLibrary.simpleMessage("Sprachlos?"),
    "mindsetGrowth": MessageLookupByLibrary.simpleMessage("Mindset & Wachstum"),
    "mindsetShapesReality": MessageLookupByLibrary.simpleMessage(
      "Deine Denkweise formt deine Realität.",
    ),
    "mindsetTips": MessageLookupByLibrary.simpleMessage("Mindset-Tipps"),
    "minutesBrave": MessageLookupByLibrary.simpleMessage("Min. mutig"),
    "mon": MessageLookupByLibrary.simpleMessage("Mo"),
    "monthAprShort": MessageLookupByLibrary.simpleMessage("Apr"),
    "monthAugShort": MessageLookupByLibrary.simpleMessage("Aug"),
    "monthDecShort": MessageLookupByLibrary.simpleMessage("Dez"),
    "monthFebShort": MessageLookupByLibrary.simpleMessage("Feb"),
    "monthJanShort": MessageLookupByLibrary.simpleMessage("Jan"),
    "monthJulShort": MessageLookupByLibrary.simpleMessage("Jul"),
    "monthJunShort": MessageLookupByLibrary.simpleMessage("Jun"),
    "monthMarShort": MessageLookupByLibrary.simpleMessage("Mär"),
    "monthMayShort": MessageLookupByLibrary.simpleMessage("Mai"),
    "monthNovShort": MessageLookupByLibrary.simpleMessage("Nov"),
    "monthOctShort": MessageLookupByLibrary.simpleMessage("Okt"),
    "monthSepShort": MessageLookupByLibrary.simpleMessage("Sep"),
    "moodAgoLabel": m15,
    "moodTodayLabel": MessageLookupByLibrary.simpleMessage("Heute"),
    "moodTrend": MessageLookupByLibrary.simpleMessage("Stimmungsverlauf"),
    "more": MessageLookupByLibrary.simpleMessage("Mehr"),
    "morning": MessageLookupByLibrary.simpleMessage("Morgen"),
    "mostlyX": m16,
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
    "navDaily": MessageLookupByLibrary.simpleMessage("Warm-ups"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "navSettings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "negative": MessageLookupByLibrary.simpleMessage("Negativ"),
    "neutral": MessageLookupByLibrary.simpleMessage("Neutral"),
    "newChallenge": MessageLookupByLibrary.simpleMessage("Neu"),
    "newChallengesAvailable": MessageLookupByLibrary.simpleMessage(
      "Neue Challenges sind jetzt in deinem Katalog verfügbar.",
    ),
    "nextMotivation1": m17,
    "nextMotivation2": m18,
    "noChallengesFound": MessageLookupByLibrary.simpleMessage(
      "Keine Challenges gefunden",
    ),
    "noEntriesYet": MessageLookupByLibrary.simpleMessage("Noch keine Einträge"),
    "noNotesYet": MessageLookupByLibrary.simpleMessage(
      "Du hast noch keine Notizen für diese Challenge.",
    ),
    "notNervousAtAll": MessageLookupByLibrary.simpleMessage("Gar nicht"),
    "notNow": MessageLookupByLibrary.simpleMessage("Nicht jetzt"),
    "notSureWhatToSay": MessageLookupByLibrary.simpleMessage(
      "Nicht sicher was du sagen sollst?",
    ),
    "notToday": MessageLookupByLibrary.simpleMessage("Heute nicht 🙈"),
    "notePrompt1": MessageLookupByLibrary.simpleMessage(
      "Was hat dich überrascht, wie es lief?",
    ),
    "notePrompt10": MessageLookupByLibrary.simpleMessage(
      "Wie fühlst du dich gerade, ehrlich?",
    ),
    "notePrompt2": MessageLookupByLibrary.simpleMessage(
      "Was hast du während der Challenge in deinem Körper gespürt?",
    ),
    "notePrompt3": MessageLookupByLibrary.simpleMessage(
      "Welche Geschichte hast du dir vorher erzählt?",
    ),
    "notePrompt4": MessageLookupByLibrary.simpleMessage(
      "Welcher Moment blieb dir am meisten in Erinnerung?",
    ),
    "notePrompt5": MessageLookupByLibrary.simpleMessage(
      "Würdest du es wieder machen? Was würdest du ändern?",
    ),
    "notePrompt6": MessageLookupByLibrary.simpleMessage(
      "Was sagt es über dich aus, dass du das getan hast?",
    ),
    "notePrompt7": MessageLookupByLibrary.simpleMessage(
      "Wie war die Realität im Vergleich zu deiner Befürchtung?",
    ),
    "notePrompt8": MessageLookupByLibrary.simpleMessage(
      "Welche Reaktion hat dich überrascht?",
    ),
    "notePrompt9": MessageLookupByLibrary.simpleMessage(
      "Was würdest du einem Freund sagen, der das versuchen will?",
    ),
    "notePromptAwkward": MessageLookupByLibrary.simpleMessage(
      "Komisch, aber wert",
    ),
    "notePromptEasier": MessageLookupByLibrary.simpleMessage(
      "Leichter als gedacht",
    ),
    "notePromptPowerful": MessageLookupByLibrary.simpleMessage(
      "Hat sich stark angefühlt",
    ),
    "notePromptSmiled": MessageLookupByLibrary.simpleMessage(
      "Sie haben zurückgelächelt",
    ),
    "notes": MessageLookupByLibrary.simpleMessage("Notizen:"),
    "notesEyebrow": MessageLookupByLibrary.simpleMessage("Eine letzte Sache"),
    "notesHelper": MessageLookupByLibrary.simpleMessage(
      "Eine Zeile für dein Zukunfts-Ich. Überspringen, wenn nichts hängen geblieben ist.",
    ),
    "notesPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Deine Gedanken, Beobachtungen, ...",
    ),
    "notesQuestion": MessageLookupByLibrary.simpleMessage(
      "Etwas zum Festhalten?",
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
    "notificationsMasterLabel": MessageLookupByLibrary.simpleMessage(
      "Alle Benachrichtigungen",
    ),
    "notificationsMasterSublabel": MessageLookupByLibrary.simpleMessage(
      "Hauptschalter · alles ausschalten",
    ),
    "notificationsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Lass dich an tägliche Herausforderungen erinnern",
    ),
    "okayButton": MessageLookupByLibrary.simpleMessage("Okay"),
    "onboarding1Button": MessageLookupByLibrary.simpleMessage(
      "So funktioniert\'s",
    ),
    "onboarding1Headline": MessageLookupByLibrary.simpleMessage(
      "Soziale Sicherheit ist eine Fähigkeit.\nFähigkeiten kann man trainieren.",
    ),
    "onboarding1Subtext": MessageLookupByLibrary.simpleMessage(
      "Syntra gibt dir jeden Tag kleine, reale Herausforderungen zum Üben. Keine Kurse. Keine Skripte. Nur du, draußen in der Welt.",
    ),
    "onboarding2Button": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "onboarding2Headline": MessageLookupByLibrary.simpleMessage(
      "Eine Challenge nach der anderen.",
    ),
    "onboarding2Step1": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Challenge",
    ),
    "onboarding2Step1Desc": MessageLookupByLibrary.simpleMessage(
      "Eine Challenge, die dich anstupst, nicht überfordert.",
    ),
    "onboarding2Step2": MessageLookupByLibrary.simpleMessage(
      "Mach sie, der Timer hilft",
    ),
    "onboarding2Step2Desc": MessageLookupByLibrary.simpleMessage(
      "Draußen in der echten Welt. Ein Timer hält dich ehrlich.",
    ),
    "onboarding2Step3": MessageLookupByLibrary.simpleMessage(
      "Protokolliere dein Ergebnis",
    ),
    "onboarding2Step3Desc": MessageLookupByLibrary.simpleMessage(
      "Wie es lief. Wie es sich anfühlte. Sieh die Lücke schrumpfen.",
    ),
    "onboarding2Subtext": MessageLookupByLibrary.simpleMessage(
      "Jede ist so gestaltet, dass sie dich leicht aus deiner Komfortzone schiebt. Du entscheidest, wie weit.",
    ),
    "onboarding3Button": MessageLookupByLibrary.simpleMessage("Ich bin dabei"),
    "onboarding3Headline": MessageLookupByLibrary.simpleMessage(
      "Es ist okay, nervös zu sein.\nDarum geht es ja.",
    ),
    "onboarding3Subtext": MessageLookupByLibrary.simpleMessage(
      "Jede Challenge in dieser App ist sicher. Nichts Extremes, nichts Peinliches. Das unangenehme Gefühl ist genau das, was mit der Zeit Selbstvertrauen aufbaut.\n\nDie meisten fühlen es. Keiner stirbt daran.",
    ),
    "onboarding4Headline": MessageLookupByLibrary.simpleMessage(
      "Was klingt am ehesten wie du?",
    ),
    "onboarding4Level1Subtitle": MessageLookupByLibrary.simpleMessage(
      "Ich denke oft daran, etwas zu sagen, und tue es dann doch nicht",
    ),
    "onboarding4Level1Title": MessageLookupByLibrary.simpleMessage(
      "Ich mache selten den ersten Schritt",
    ),
    "onboarding4Level2Subtitle": MessageLookupByLibrary.simpleMessage(
      "Ich spreche Leute an, wenn ich muss. Aber neue Kontakte aufzubauen kostet mich Energie",
    ),
    "onboarding4Level2Title": MessageLookupByLibrary.simpleMessage(
      "Ich schaffe es, aber es kostet mich wirklich Mühe",
    ),
    "onboarding4Level3Subtitle": MessageLookupByLibrary.simpleMessage(
      "Ich blockiere selten. Ich will schwierigere soziale Situationen angehen",
    ),
    "onboarding4Level3Title": MessageLookupByLibrary.simpleMessage(
      "Ich bin über die Grundlagen hinaus",
    ),
    "onboarding4Subtext": MessageLookupByLibrary.simpleMessage(
      "Sei ehrlich: deine ersten Challenges werden darauf abgestimmt. Du kannst es jederzeit ändern.",
    ),
    "onboarding5Button": MessageLookupByLibrary.simpleMessage(
      "Erinnerung einstellen",
    ),
    "onboarding5Headline": MessageLookupByLibrary.simpleMessage(
      "5 Minuten am Tag reichen.",
    ),
    "onboarding5Stat1Label": MessageLookupByLibrary.simpleMessage("Versuche"),
    "onboarding5Stat1Value": MessageLookupByLibrary.simpleMessage("3"),
    "onboarding5Stat2Label": MessageLookupByLibrary.simpleMessage("pro Tag"),
    "onboarding5Stat2Value": MessageLookupByLibrary.simpleMessage("5 Min"),
    "onboarding5Stat3Label": MessageLookupByLibrary.simpleMessage("freiwillig"),
    "onboarding5Stat3Value": MessageLookupByLibrary.simpleMessage("100%"),
    "onboarding5Subtext": MessageLookupByLibrary.simpleMessage(
      "Die Wissenschaft zur Gewohnheitsbildung sagt: Regelmäßigkeit ist wichtiger als Intensität. Eine kleine Sache, jeden Tag, verändert dein Gehirn. Wortwörtlich.",
    ),
    "openBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Batterieeinstellungen öffnen",
    ),
    "perceivedScaleHigh": MessageLookupByLibrary.simpleMessage("Selbstsicher"),
    "perceivedScaleLow": MessageLookupByLibrary.simpleMessage("Unangenehm"),
    "perception": MessageLookupByLibrary.simpleMessage("Wahrnehmung"),
    "positive": MessageLookupByLibrary.simpleMessage("Positiv"),
    "predictionAttempts": MessageLookupByLibrary.simpleMessage("Versuche"),
    "predictionAttemptsCount": m19,
    "predictionAvgGap": MessageLookupByLibrary.simpleMessage("Ø Differenz"),
    "predictionCalmer": MessageLookupByLibrary.simpleMessage("Ruhiger"),
    "predictionEasier": MessageLookupByLibrary.simpleMessage("Leichter"),
    "predictionEasierAfter": MessageLookupByLibrary.simpleMessage(
      "an als erwartet",
    ),
    "predictionEasierBefore": MessageLookupByLibrary.simpleMessage(
      "Challenges fühlten sich",
    ),
    "predictionEasierKey": MessageLookupByLibrary.simpleMessage("leichter"),
    "predictionHarder": MessageLookupByLibrary.simpleMessage("Schwerer"),
    "predictionInsightAccurate": MessageLookupByLibrary.simpleMessage(
      "Deine Vorhersagen sind ziemlich genau",
    ),
    "predictionInsightCalm": MessageLookupByLibrary.simpleMessage(
      "Du fühlst dich meist ruhiger als erwartet",
    ),
    "predictionInsightNervous": MessageLookupByLibrary.simpleMessage(
      "Du fühlst dich nervöser als erwartet",
    ),
    "predictionInsightTough": MessageLookupByLibrary.simpleMessage(
      "Diese hier ist härter als du denkst",
    ),
    "predictionInsightVeryCalm": MessageLookupByLibrary.simpleMessage(
      "Du bist durchweg ruhiger als du denkst",
    ),
    "predictionRealityGapTitle": MessageLookupByLibrary.simpleMessage(
      "Nervosität vorher vs. Gefühl nachher",
    ),
    "predictionSame": MessageLookupByLibrary.simpleMessage("Gleich"),
    "predictionTakeawayAfter": MessageLookupByLibrary.simpleMessage(
      "der Fälle daneben.",
    ),
    "predictionTakeawayBefore": MessageLookupByLibrary.simpleMessage(
      "Dein Kopf sagt",
    ),
    "predictionTakeawayMiddle": MessageLookupByLibrary.simpleMessage(
      "und liegt in",
    ),
    "predictionTakeawayQuote": MessageLookupByLibrary.simpleMessage(
      "das wird furchtbar",
    ),
    "predictionVsRealitySubtitle": MessageLookupByLibrary.simpleMessage(
      "Wie nervös du erwartest vs wie du dich wirklich fühlst",
    ),
    "predictionVsRealityTitle": MessageLookupByLibrary.simpleMessage(
      "Erwartung vs Realität",
    ),
    "preferAnotherChallenge": MessageLookupByLibrary.simpleMessage(
      "Ich hätte lieber eine andere Challenge",
    ),
    "primingBack": MessageLookupByLibrary.simpleMessage("Zurück"),
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
      "Flirten ist einfach spielerische Kommunikation. Das Ergebnis ist egal. Auftauchen zählt.",
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
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzerklärung",
    ),
    "profileActivityTitle": MessageLookupByLibrary.simpleMessage("Aktivität"),
    "profileAuraWeekTitle": MessageLookupByLibrary.simpleMessage(
      "Aura diese Woche",
    ),
    "profileBadgesCount": m20,
    "profileBadgesLabel": MessageLookupByLibrary.simpleMessage("Badges"),
    "profileLogbookEntries": m21,
    "profileLogbookLabel": MessageLookupByLibrary.simpleMessage("Logbuch"),
    "profileMoodTitle": MessageLookupByLibrary.simpleMessage(
      "Stimmungsverlauf",
    ),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profil"),
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
    "reflectEyebrow": MessageLookupByLibrary.simpleMessage("Reflexion"),
    "reflectOnThis": MessageLookupByLibrary.simpleMessage(
      "Reflektiere darüber",
    ),
    "rememberOnMyOwn": MessageLookupByLibrary.simpleMessage(
      "Ich erinnere mich selbst →",
    ),
    "reminderExplanation": MessageLookupByLibrary.simpleMessage(
      "Wir senden dir einen Impuls am Tag, du wählst wann. Kein Spam. Du kannst es jederzeit in den Einstellungen abschalten.",
    ),
    "reminderTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Erinnerungszeit",
    ),
    "reminderUpdated": m22,
    "repeatChallengeInfo": MessageLookupByLibrary.simpleMessage(
      "Du kannst diese Challenge so oft wiederholen, wie du möchtest!",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Erforderlich"),
    "retryChallenge": MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "rewardFactor": MessageLookupByLibrary.simpleMessage("Belohnungsfaktor"),
    "sat": MessageLookupByLibrary.simpleMessage("Sa"),
    "saveEntry": MessageLookupByLibrary.simpleMessage("Eintrag speichern"),
    "saveReflection": MessageLookupByLibrary.simpleMessage(
      "Reflexion speichern",
    ),
    "savedBody": MessageLookupByLibrary.simpleMessage(
      "Diese gehört zu deiner Geschichte. Die nächste wird ein kleines Stück leichter.",
    ),
    "savedTitle": MessageLookupByLibrary.simpleMessage("Gespeichert."),
    "score": MessageLookupByLibrary.simpleMessage("Punkte:"),
    "searchChallenge": MessageLookupByLibrary.simpleMessage("Challenge suchen"),
    "searchChallengesHint": MessageLookupByLibrary.simpleMessage(
      "Challenges suchen…",
    ),
    "searchForChallenge": MessageLookupByLibrary.simpleMessage(
      "Nach einer Challenge suchen...",
    ),
    "sectionAbout": MessageLookupByLibrary.simpleMessage("Über"),
    "sectionAppearance": MessageLookupByLibrary.simpleMessage(
      "Erscheinungsbild",
    ),
    "sectionFeel": MessageLookupByLibrary.simpleMessage("Gefühl"),
    "sectionInventory": MessageLookupByLibrary.simpleMessage("Inventar"),
    "sectionNotifications": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen",
    ),
    "seeAllBadges": MessageLookupByLibrary.simpleMessage("Alle ansehen"),
    "setDifficultyManually": MessageLookupByLibrary.simpleMessage(
      "Schwierigkeit manuell setzen",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "shopAvailableAura": m23,
    "shopBuyFor": m24,
    "shopConfirmBody": m25,
    "shopConfirmTitle": MessageLookupByLibrary.simpleMessage("Kauf bestätigen"),
    "shopInInventory": m26,
    "shopMaxOwned": MessageLookupByLibrary.simpleMessage("Maximum erreicht"),
    "shopNotEnoughAura": MessageLookupByLibrary.simpleMessage(
      "Nicht genug Aura",
    ),
    "shopPurchased": MessageLookupByLibrary.simpleMessage("Gekauft!"),
    "shopStreakFreezeDesc": MessageLookupByLibrary.simpleMessage(
      "Schütze eine Woche, wenn du das Ziel nicht erreichst.",
    ),
    "shopTitle": MessageLookupByLibrary.simpleMessage("Shop"),
    "showReminderNotifications": MessageLookupByLibrary.simpleMessage(
      "Erinnerungsbenachrichtigungen anzeigen",
    ),
    "shuffleTooltip": MessageLookupByLibrary.simpleMessage(
      "Challenges mischen",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "skipForNow": MessageLookupByLibrary.simpleMessage("Erstmal überspringen"),
    "skipSaveTheWin": MessageLookupByLibrary.simpleMessage(
      "Überspringen und Sieg behalten",
    ),
    "skipThisQuestion": MessageLookupByLibrary.simpleMessage(
      "Frage überspringen",
    ),
    "solo": MessageLookupByLibrary.simpleMessage("Solo"),
    "somePermissionsMissing": MessageLookupByLibrary.simpleMessage(
      "Einige Berechtigungen fehlen noch. Bitte aktiviere sie manuell.",
    ),
    "somewhereInTheMiddle": MessageLookupByLibrary.simpleMessage(
      "Irgendwo dazwischen",
    ),
    "sortAuraDesc": MessageLookupByLibrary.simpleMessage(
      "Aura ↓ (meiste Belohnung)",
    ),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sortieren nach"),
    "sortLevelAsc": MessageLookupByLibrary.simpleMessage(
      "Level ↑ (leicht zuerst)",
    ),
    "sortLevelDesc": MessageLookupByLibrary.simpleMessage(
      "Level ↓ (schwer zuerst)",
    ),
    "sortRecommended": MessageLookupByLibrary.simpleMessage("Empfohlen"),
    "sortTimeAsc": MessageLookupByLibrary.simpleMessage("Zeit ↑ (kürzeste)"),
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
    "stillSecondsLeft": m27,
    "storyAuraKilo": m28,
    "storyAuraSmall": m29,
    "storyFirstChallenge": MessageLookupByLibrary.simpleMessage(
      "Deine Geschichte beginnt mit der ersten Challenge, die du abschließt.",
    ),
    "storyMinutesBrave": m30,
    "storyNTimes": m31,
    "storyOnce": MessageLookupByLibrary.simpleMessage(
      "Du bist einmal aus deiner Komfortzone herausgetreten. Das erfordert Mut.",
    ),
    "storyStreakMany": m32,
    "storyStreakOne": MessageLookupByLibrary.simpleMessage(
      "Tag 1 eines neuen Streaks. Jeder große Streak hat hier angefangen.",
    ),
    "streak": MessageLookupByLibrary.simpleMessage("Serie"),
    "streakAliveN": m33,
    "streakFreezeName": MessageLookupByLibrary.simpleMessage("Streak-Schutz"),
    "streakMilestone100": MessageLookupByLibrary.simpleMessage(
      "100 Wochen. Du hast etwas Außergewöhnliches aufgebaut. Respekt.",
    ),
    "streakMilestone14": MessageLookupByLibrary.simpleMessage(
      "14 Wochen durchgezogen. Du bist nicht mehr die gleiche Person wie vor 14 Wochen.",
    ),
    "streakMilestone3": MessageLookupByLibrary.simpleMessage(
      "3 Wochen am Stück. Du baust eine Gewohnheit auf.",
    ),
    "streakMilestone30": MessageLookupByLibrary.simpleMessage(
      "30 Wochen. Über ein halbes Jahr. Das ist selten. Das ist stark.",
    ),
    "streakMilestone60": MessageLookupByLibrary.simpleMessage(
      "60 Wochen. Die meisten geben nach zwei Monaten auf. Du nicht.",
    ),
    "streakMilestone7": MessageLookupByLibrary.simpleMessage(
      "7 Wochen! Fast zwei Monate drangeblieben. Deine Komfortzone ist gewachsen.",
    ),
    "streakMilestoneGeneric": m34,
    "streakMilestoneTitle": m35,
    "sun": MessageLookupByLibrary.simpleMessage("So"),
    "tabDone": MessageLookupByLibrary.simpleMessage("Erledigt"),
    "tabFlirt": MessageLookupByLibrary.simpleMessage("Flirt"),
    "tabForYou": MessageLookupByLibrary.simpleMessage("Für dich"),
    "tabSaved": MessageLookupByLibrary.simpleMessage("Gespeichert"),
    "thankYouFeedback": MessageLookupByLibrary.simpleMessage(
      "Danke für dein Feedback!",
    ),
    "themeDark": MessageLookupByLibrary.simpleMessage("Dunkel"),
    "themeLight": MessageLookupByLibrary.simpleMessage("Hell"),
    "themeSystem": MessageLookupByLibrary.simpleMessage("System"),
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
    "timerCustomLabel": MessageLookupByLibrary.simpleMessage("Timer setzen:"),
    "timesTried": MessageLookupByLibrary.simpleMessage("Versucht"),
    "today": MessageLookupByLibrary.simpleMessage("Heute"),
    "todaysMissions": MessageLookupByLibrary.simpleMessage("Heutige Missionen"),
    "tooBad": MessageLookupByLibrary.simpleMessage(
      "Schade! Du hast die Challenge abgebrochen.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "totalAura": MessageLookupByLibrary.simpleMessage("Gesamt-Aura"),
    "tryAgainNextTime": MessageLookupByLibrary.simpleMessage(
      "Versuch es beim nächsten Mal!",
    ),
    "tue": MessageLookupByLibrary.simpleMessage("Di"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "veryBad": MessageLookupByLibrary.simpleMessage("Sehr schlecht"),
    "veryGood": MessageLookupByLibrary.simpleMessage("Sehr gut"),
    "veryNegative": MessageLookupByLibrary.simpleMessage("Sehr negativ"),
    "veryNervous": MessageLookupByLibrary.simpleMessage("Sehr nervös"),
    "veryPositive": MessageLookupByLibrary.simpleMessage("Sehr positiv"),
    "wantReminders": MessageLookupByLibrary.simpleMessage(
      "Sollen wir dich erinnern?",
    ),
    "warmupAddMore": MessageLookupByLibrary.simpleMessage(
      "Challenge-Liste öffnen, um weitere zu speichern",
    ),
    "warmupCardSummary": m36,
    "warmupCompleteBody": MessageLookupByLibrary.simpleMessage(
      "Du hast die ganze Leiter geschafft. Das ist echter Schwung. Nimm ihn mit.",
    ),
    "warmupCompleteTitle": MessageLookupByLibrary.simpleMessage(
      "Warm-up abgeschlossen",
    ),
    "warmupContinue": MessageLookupByLibrary.simpleMessage(
      "Warm-up fortsetzen",
    ),
    "warmupForVibe": m37,
    "warmupJustOne": MessageLookupByLibrary.simpleMessage(
      "Nur eine schnelle Challenge",
    ),
    "warmupLength10": MessageLookupByLibrary.simpleMessage("10 Min"),
    "warmupLength15": MessageLookupByLibrary.simpleMessage("15 Min"),
    "warmupLength5": MessageLookupByLibrary.simpleMessage("5 Min"),
    "warmupMyEmpty": MessageLookupByLibrary.simpleMessage(
      "Speichere Challenges aus der Challenge-Liste. Sie sammeln sich hier als dein eigenes Warm-up.",
    ),
    "warmupMySectionEyebrow": MessageLookupByLibrary.simpleMessage(
      "Deine Gespeicherten · individuell",
    ),
    "warmupMySummary": m38,
    "warmupMyTitle": MessageLookupByLibrary.simpleMessage("Mein Warm-up"),
    "warmupNextUp": m39,
    "warmupPickVibeHint": MessageLookupByLibrary.simpleMessage(
      "Wähle einen Vibe oder nutze unten Mein Warm-up.",
    ),
    "warmupProgress": m40,
    "warmupStart": MessageLookupByLibrary.simpleMessage("Warm-up starten"),
    "warmupStep1Eyebrow": MessageLookupByLibrary.simpleMessage("Schritt 1"),
    "warmupStep1Question": MessageLookupByLibrary.simpleMessage(
      "Wo gehst du hin?",
    ),
    "warmupStep1Subtitle": MessageLookupByLibrary.simpleMessage(
      "Wir bauen dir eine kurze Challenge-Leiter, die dich darauf einstimmt.",
    ),
    "warmupStep2Eyebrow": MessageLookupByLibrary.simpleMessage(
      "Schritt 2 · Wie lange?",
    ),
    "warmupTapToSwap": MessageLookupByLibrary.simpleMessage(
      "tippen zum Tauschen",
    ),
    "warmupTitle": MessageLookupByLibrary.simpleMessage("Warm-ups"),
    "warmupVibeAny": MessageLookupByLibrary.simpleMessage("Egal wo"),
    "warmupVibeCardTitle": m41,
    "warmupVibeCoffee": MessageLookupByLibrary.simpleMessage("Kaffee holen"),
    "warmupVibeErrands": MessageLookupByLibrary.simpleMessage("Besorgungen"),
    "warmupVibeMeeting": MessageLookupByLibrary.simpleMessage(
      "Vor dem Meeting",
    ),
    "warmupVibeNight": MessageLookupByLibrary.simpleMessage("Ausgehen"),
    "wed": MessageLookupByLibrary.simpleMessage("Mi"),
    "weekGroupAgoWeeks": m42,
    "weekGroupLast": MessageLookupByLibrary.simpleMessage("Letzte Woche"),
    "weekGroupThis": MessageLookupByLibrary.simpleMessage("Diese Woche"),
    "weekStreak": MessageLookupByLibrary.simpleMessage("Streak"),
    "weekdayShortFri": MessageLookupByLibrary.simpleMessage("Fr"),
    "weekdayShortMon": MessageLookupByLibrary.simpleMessage("Mo"),
    "weekdayShortSat": MessageLookupByLibrary.simpleMessage("Sa"),
    "weekdayShortSun": MessageLookupByLibrary.simpleMessage("So"),
    "weekdayShortThu": MessageLookupByLibrary.simpleMessage("Do"),
    "weekdayShortTue": MessageLookupByLibrary.simpleMessage("Di"),
    "weekdayShortWed": MessageLookupByLibrary.simpleMessage("Mi"),
    "weeklyAuraGoalReached": MessageLookupByLibrary.simpleMessage(
      "Ziel erreicht! Diese Woche zählt.",
    ),
    "weeklyAuraGoalTitle": MessageLookupByLibrary.simpleMessage(
      "Wöchentliches Aura-Ziel",
    ),
    "weeklyChallenges": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Challenges",
    ),
    "weeklyGoalProgress": m43,
    "weeklyGoalSetLabel": MessageLookupByLibrary.simpleMessage("Ziel setzen:"),
    "weeklyGoalTitle": MessageLookupByLibrary.simpleMessage("Wochenziel"),
    "weeklyRecapBody": m44,
    "weeklyRecapTitle": MessageLookupByLibrary.simpleMessage("Wochenrückblick"),
    "weeklyXpProgress": MessageLookupByLibrary.simpleMessage(
      "Wöchentliche Aura",
    ),
    "weeksShort": MessageLookupByLibrary.simpleMessage("Wochen"),
    "wellDone": MessageLookupByLibrary.simpleMessage(
      "Gut gemacht! Mach weiter so!",
    ),
    "yesChallengeStart": MessageLookupByLibrary.simpleMessage(
      "Ja, ich habe sie gemacht",
    ),
    "yourProgress": MessageLookupByLibrary.simpleMessage("Dein Fortschritt"),
    "yourStatistics": MessageLookupByLibrary.simpleMessage("Deine Statistiken"),
  };
}
