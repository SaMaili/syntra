// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(challengeTitle) => "Ready to take on: ${challengeTitle}?";

  static String m1(id) => "Challenge #${id}";

  static String m2(challengeTitle) =>
      "Your challenge \"${challengeTitle}\" just finished! 🏆";

  static String m3(done, needed, next) =>
      "${done} / ${needed} completions to Level ${next}";

  static String m4(streak) => "Day ${streak} — keep it going.";

  static String m5(level) => "Level ${level}";

  static String m6(level) => "Level ${level} Unlocked!";

  static String m7(time) => "Next Motivation 1: ${time}";

  static String m8(time) => "Next Motivation 2: ${time}";

  static String m9(period, time) => "⏰ ${period} reminder updated to ${time}";

  static String m10(seconds) => "Blocked ${seconds} seconds";

  static String m11(minutes) => "${minutes} minutes spent being brave.";

  static String m12(count) =>
      "You have stepped outside your comfort zone ${count} times.";

  static String m13(days) =>
      "You are on a ${days}-day streak. Keep the momentum going.";

  static String m14(kilo) =>
      "${kilo}k XP earned — you are building something real.";

  static String m15(xp) => "${xp} XP earned through genuine action.";

  static String m16(days) =>
      "You\'ve been showing up for ${days} days. Keep going.";

  static String m17(days) => "${days}-Day Streak!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutDescription": MessageLookupByLibrary.simpleMessage(
      "Syntra is an innovative app that helps users overcome social challenges and achieve their goals.",
    ),
    "aboutSubtitle": MessageLookupByLibrary.simpleMessage(
      "App version and information",
    ),
    "aboutTheApp": MessageLookupByLibrary.simpleMessage("About the App"),
    "acceptChallenge": MessageLookupByLibrary.simpleMessage("Accept Challenge"),
    "activity": MessageLookupByLibrary.simpleMessage("Activity"),
    "activitySubtitle": MessageLookupByLibrary.simpleMessage(
      "12 weeks — each square is one day",
    ),
    "addCustomChallenge": MessageLookupByLibrary.simpleMessage(
      "Add Custom Challenge",
    ),
    "addCustomChallengeTitle": MessageLookupByLibrary.simpleMessage(
      "Add Custom Challenge",
    ),
    "afternoon": MessageLookupByLibrary.simpleMessage("Afternoon"),
    "allPermissionsGranted": MessageLookupByLibrary.simpleMessage(
      "All permissions granted successfully!",
    ),
    "allRightsReserved": MessageLookupByLibrary.simpleMessage(
      "© 2025 Syntra. All rights reserved.",
    ),
    "allSet": MessageLookupByLibrary.simpleMessage("All Set!"),
    "allowExactAlarms": MessageLookupByLibrary.simpleMessage(
      "Allow Exact Alarms",
    ),
    "auraPoints": MessageLookupByLibrary.simpleMessage("Aura"),
    "backToHome": MessageLookupByLibrary.simpleMessage("Back to Home"),
    "bad": MessageLookupByLibrary.simpleMessage("Bad"),
    "basicNotifications": MessageLookupByLibrary.simpleMessage(
      "Basic Notifications",
    ),
    "bestStreak": MessageLookupByLibrary.simpleMessage("Best Streak"),
    "boldMove": MessageLookupByLibrary.simpleMessage("Bold Move"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "celebrateSmallWins": MessageLookupByLibrary.simpleMessage(
      "Celebrate small wins daily",
    ),
    "challenge": MessageLookupByLibrary.simpleMessage("Challenge"),
    "challengeAborted": MessageLookupByLibrary.simpleMessage(
      "Challenge aborted",
    ),
    "challengeAbortedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Challenge aborted!",
    ),
    "challengeAlreadyCompleted": MessageLookupByLibrary.simpleMessage(
      "You have already completed this challenge!",
    ),
    "challengeAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Challenge already exists?",
    ),
    "challengeCompleted": MessageLookupByLibrary.simpleMessage(
      "Challenge completed!",
    ),
    "challengeCompletedDaily": MessageLookupByLibrary.simpleMessage(
      "Challenge completed!",
    ),
    "challengeCompletedGeneric": MessageLookupByLibrary.simpleMessage(
      "Challenge completed!",
    ),
    "challengeCompletedSnackbar": MessageLookupByLibrary.simpleMessage(
      "Challenge completed! Logbook entry saved.",
    ),
    "challengeConfirmMessage": m0,
    "challengeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Start Challenge?",
    ),
    "challengeDescriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Challenge Description",
    ),
    "challengeDetails": MessageLookupByLibrary.simpleMessage(
      "Challenge Details",
    ),
    "challengeId": MessageLookupByLibrary.simpleMessage("Challenge ID"),
    "challengeInformation": MessageLookupByLibrary.simpleMessage(
      "Challenge Information",
    ),
    "challengeLogbook": MessageLookupByLibrary.simpleMessage(
      "Challenge Logbook",
    ),
    "challengeName": MessageLookupByLibrary.simpleMessage("Challenge Name"),
    "challengeNumber": m1,
    "challengeStartQuestion": MessageLookupByLibrary.simpleMessage(
      "Start challenge?",
    ),
    "challengeTimerCompleteBody": m2,
    "challengeTimerCompleteTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Timer Complete!",
    ),
    "challengeType": MessageLookupByLibrary.simpleMessage("Challenge Type"),
    "challengesShuffled": MessageLookupByLibrary.simpleMessage(
      "Challenges shuffled!",
    ),
    "challengesThisWeek": MessageLookupByLibrary.simpleMessage(
      "Challenges This Week",
    ),
    "chartExplanation": MessageLookupByLibrary.simpleMessage(
      "Each bar is a day. Green = completed, orange = gave it a try.",
    ),
    "closeDialog": MessageLookupByLibrary.simpleMessage("Close"),
    "coachMsg1": MessageLookupByLibrary.simpleMessage(
      "You just did something most people never try. That took guts.",
    ),
    "coachMsg2": MessageLookupByLibrary.simpleMessage(
      "Every time you do this it gets 1% easier. Seriously.",
    ),
    "coachMsg3": MessageLookupByLibrary.simpleMessage(
      "Your nervous system just learned you survived. That matters.",
    ),
    "coachMsg4": MessageLookupByLibrary.simpleMessage(
      "Growth happens outside the comfort zone. You were just there.",
    ),
    "coachMsg5": MessageLookupByLibrary.simpleMessage(
      "Awkward is just bravery wearing the wrong shoes. You showed up.",
    ),
    "coachMsg6": MessageLookupByLibrary.simpleMessage(
      "One action at a time. You\'re building something real.",
    ),
    "coachMsg7": MessageLookupByLibrary.simpleMessage(
      "The version of you from six months ago would be proud.",
    ),
    "comfortZone": MessageLookupByLibrary.simpleMessage("Comfort Zone"),
    "comfortZoneLevel": MessageLookupByLibrary.simpleMessage(
      "Comfort Zone Level",
    ),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "completeChallengesToSee": MessageLookupByLibrary.simpleMessage(
      "Complete some challenges to see them here!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completionsToLevel": m3,
    "congratulations": MessageLookupByLibrary.simpleMessage(
      "Congratulations! You completed the challenge.",
    ),
    "couldNotOpenLink": MessageLookupByLibrary.simpleMessage(
      "Could not open link",
    ),
    "dailyBonus": MessageLookupByLibrary.simpleMessage("Daily Bonus"),
    "dailyChallenge": MessageLookupByLibrary.simpleMessage("Daily Challenge"),
    "dailyReminders": MessageLookupByLibrary.simpleMessage("Daily Reminders"),
    "dailyRemindersSubtitle": MessageLookupByLibrary.simpleMessage(
      "Get reminded to complete challenges",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "darkModeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Switch to dark theme",
    ),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Day Streak"),
    "dbDebugShow": MessageLookupByLibrary.simpleMessage(
      "DB Debug: Show all logbook table",
    ),
    "debugDeleteTooltip": MessageLookupByLibrary.simpleMessage("Debug Delete"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteEntry": MessageLookupByLibrary.simpleMessage("Delete Entry"),
    "deleteEntryConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this logbook entry? This action cannot be undone.",
    ),
    "deleteEntryQuestion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this entry?",
    ),
    "deliverAtPreciseTimes": MessageLookupByLibrary.simpleMessage(
      "Deliver notifications at precise times",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "detailsLabel": MessageLookupByLibrary.simpleMessage("Details"),
    "developerLabel": MessageLookupByLibrary.simpleMessage(
      "Developer: SaMaili",
    ),
    "doItLater": MessageLookupByLibrary.simpleMessage("Do it later"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "doneExcited": MessageLookupByLibrary.simpleMessage("DONE! 😎"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Done Today"),
    "embraceChallenges": MessageLookupByLibrary.simpleMessage(
      "Embrace challenges as opportunities",
    ),
    "enableNotifications": MessageLookupByLibrary.simpleMessage(
      "Enable Notifications",
    ),
    "enableReminders": MessageLookupByLibrary.simpleMessage("Enable reminders"),
    "enterDescription": MessageLookupByLibrary.simpleMessage(
      "Enter a description",
    ),
    "enterName": MessageLookupByLibrary.simpleMessage("Enter a name"),
    "enterYourNotes": MessageLookupByLibrary.simpleMessage(
      "Enter your notes here...",
    ),
    "entryDeleted": MessageLookupByLibrary.simpleMessage("Entry deleted"),
    "evening": MessageLookupByLibrary.simpleMessage("Evening"),
    "everyDayNewChance": MessageLookupByLibrary.simpleMessage(
      "Every day is a new chance to grow and surpass yourself.",
    ),
    "exactAlarmsDescription": MessageLookupByLibrary.simpleMessage(
      "To ensure accurate challenge timers, please allow exact alarms in your device settings.",
    ),
    "exactTiming": MessageLookupByLibrary.simpleMessage("Exact Timing"),
    "existingChallenge": MessageLookupByLibrary.simpleMessage(
      "Existing Challenge",
    ),
    "exploreAllChallenges": MessageLookupByLibrary.simpleMessage(
      "Explore all challenges",
    ),
    "failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "failureCopy": MessageLookupByLibrary.simpleMessage(
      "That one was hard. Showing up and trying is the whole game.",
    ),
    "failureNotesHint": MessageLookupByLibrary.simpleMessage(
      "What happened? What would you do differently? (Even writing one word is a win.)",
    ),
    "feeling": MessageLookupByLibrary.simpleMessage("Feeling"),
    "filterAll": MessageLookupByLibrary.simpleMessage("All"),
    "filterFlirtExclude": MessageLookupByLibrary.simpleMessage("No flirt"),
    "filterFlirtLabel": MessageLookupByLibrary.simpleMessage(
      "Flirt challenges",
    ),
    "filterFlirtOnly": MessageLookupByLibrary.simpleMessage("Flirt only"),
    "filterNewOnly": MessageLookupByLibrary.simpleMessage(
      "Only show new challenges",
    ),
    "filterNewOnlySubtitle": MessageLookupByLibrary.simpleMessage(
      "Hide challenges you\'ve already completed",
    ),
    "filterReset": MessageLookupByLibrary.simpleMessage("Reset"),
    "filterSortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
    "filterSortEasiest": MessageLookupByLibrary.simpleMessage("Easiest first"),
    "filterSortPopular": MessageLookupByLibrary.simpleMessage("Popular"),
    "filterTitle": MessageLookupByLibrary.simpleMessage("Filters"),
    "firstChallengeDesc": MessageLookupByLibrary.simpleMessage(
      "It\'ll take about 2 minutes. Or save it for later.",
    ),
    "flirtTagExplanation": MessageLookupByLibrary.simpleMessage(
      "💘 Flirt challenges focus on playful, social interactions to build romantic confidence.",
    ),
    "focusProgress": MessageLookupByLibrary.simpleMessage(
      "Focus on progress, not perfection",
    ),
    "forBestExperience": MessageLookupByLibrary.simpleMessage(
      "For the best experience",
    ),
    "fri": MessageLookupByLibrary.simpleMessage("F"),
    "getNewMotivation": MessageLookupByLibrary.simpleMessage(
      "Get New Motivation",
    ),
    "githubLabel": MessageLookupByLibrary.simpleMessage("GitHub: "),
    "giveMeOneTooltip": MessageLookupByLibrary.simpleMessage("Give me one!"),
    "goToSettings": MessageLookupByLibrary.simpleMessage("Go to Settings"),
    "good": MessageLookupByLibrary.simpleMessage("Good"),
    "greatJobDaily": MessageLookupByLibrary.simpleMessage(
      "Great job! You have mastered today\'s challenge.",
    ),
    "greetingFresh": MessageLookupByLibrary.simpleMessage(
      "Welcome back. Ready to start fresh today?",
    ),
    "greetingLongTime": MessageLookupByLibrary.simpleMessage(
      "Long time. No worries — your progress is still here.",
    ),
    "greetingStreak": m4,
    "group": MessageLookupByLibrary.simpleMessage("Group"),
    "growthStartsDecision": MessageLookupByLibrary.simpleMessage(
      "Growth starts with a decision: courage, openness, and positivity.",
    ),
    "growthZone": MessageLookupByLibrary.simpleMessage("Growth Zone"),
    "heresYourFirst": MessageLookupByLibrary.simpleMessage(
      "Here\'s your first one.",
    ),
    "howDidYouFeel": MessageLookupByLibrary.simpleMessage("How did you feel?"),
    "howDidYouFeelQuestion": MessageLookupByLibrary.simpleMessage(
      "How did you feel?",
    ),
    "howDoYouFeel": MessageLookupByLibrary.simpleMessage("How do you feel?"),
    "howPerceivedByOthers": MessageLookupByLibrary.simpleMessage(
      "How were you perceived?",
    ),
    "howPerceivedQuestion": MessageLookupByLibrary.simpleMessage(
      "How do you think you were perceived?",
    ),
    "howPerceivedThink": MessageLookupByLibrary.simpleMessage(
      "How do you think you will be perceived?",
    ),
    "imReady": MessageLookupByLibrary.simpleMessage("I\'m Ready"),
    "importantNotificationHints": MessageLookupByLibrary.simpleMessage(
      "Important Notification Settings",
    ),
    "keepGoing": MessageLookupByLibrary.simpleMessage("Keep going"),
    "keepItUp": MessageLookupByLibrary.simpleMessage("Keep it up"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageGerman": MessageLookupByLibrary.simpleMessage("Deutsch"),
    "languageJapanese": MessageLookupByLibrary.simpleMessage("日本語"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose your preferred language",
    ),
    "lastCompleted": MessageLookupByLibrary.simpleMessage("Last completed:"),
    "lastNote": MessageLookupByLibrary.simpleMessage("Last note:"),
    "learnSetbacks": MessageLookupByLibrary.simpleMessage(
      "Learn from setbacks",
    ),
    "legendCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "legendTried": MessageLookupByLibrary.simpleMessage("Tried"),
    "less": MessageLookupByLibrary.simpleMessage("Less"),
    "lessLabel": MessageLookupByLibrary.simpleMessage("Less"),
    "letsGo": MessageLookupByLibrary.simpleMessage("LET\'S GO!"),
    "letsGoButton": MessageLookupByLibrary.simpleMessage("Let\'s go"),
    "levelDownBody": MessageLookupByLibrary.simpleMessage(
      "You can only level down manually — going back up requires grinding through completions again.",
    ),
    "levelDownCancel": MessageLookupByLibrary.simpleMessage("Stay where I am"),
    "levelDownConfirm": MessageLookupByLibrary.simpleMessage("Yes, step back"),
    "levelDownTitle": MessageLookupByLibrary.simpleMessage("Take a step back?"),
    "levelN": m5,
    "levelUnlocked": m6,
    "logbook": MessageLookupByLibrary.simpleMessage("Logbook"),
    "logbookEntry": MessageLookupByLibrary.simpleMessage("Logbook Entry"),
    "logbookEntrySaved": MessageLookupByLibrary.simpleMessage(
      "Logbook entry saved",
    ),
    "lostForWords": MessageLookupByLibrary.simpleMessage("Lost for words?"),
    "mindsetGrowth": MessageLookupByLibrary.simpleMessage("Mindset & Growth"),
    "mindsetShapesReality": MessageLookupByLibrary.simpleMessage(
      "Your mindset shapes your reality.",
    ),
    "mindsetTips": MessageLookupByLibrary.simpleMessage("Mindset Tips"),
    "minutesBrave": MessageLookupByLibrary.simpleMessage("Min. Brave"),
    "mon": MessageLookupByLibrary.simpleMessage("M"),
    "moodTrend": MessageLookupByLibrary.simpleMessage("Mood Trend"),
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "morning": MessageLookupByLibrary.simpleMessage("Morning"),
    "motivationMessage1": MessageLookupByLibrary.simpleMessage(
      "Ready for a new challenge? Let\'s go!",
    ),
    "motivationMessage2": MessageLookupByLibrary.simpleMessage(
      "Keep up the great work! Try a challenge today!",
    ),
    "motivationMessage3": MessageLookupByLibrary.simpleMessage(
      "Your next win is waiting. Take on a challenge!",
    ),
    "motivationMessage4": MessageLookupByLibrary.simpleMessage(
      "Small steps, big results. Do a challenge!",
    ),
    "motivationMessage5": MessageLookupByLibrary.simpleMessage(
      "Stay motivated! Complete a challenge now!",
    ),
    "motivationMessage6": MessageLookupByLibrary.simpleMessage(
      "You are the sun! But what is the sun if it can\'t shine?\nDo a challenge!",
    ),
    "motivationMessage7": MessageLookupByLibrary.simpleMessage(
      "Are you outside? Then you should do a challenge!",
    ),
    "motivationMessage8": MessageLookupByLibrary.simpleMessage(
      "It takes only 5 minutes to do a challenge!\nWhat are you waiting for?",
    ),
    "motivationalQuote": MessageLookupByLibrary.simpleMessage(
      "\"The only limit to our realization of tomorrow will be our doubts of today.\"",
    ),
    "navChallenge": MessageLookupByLibrary.simpleMessage("Challenge"),
    "navDaily": MessageLookupByLibrary.simpleMessage("Daily"),
    "navSettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "navStats": MessageLookupByLibrary.simpleMessage("Stats"),
    "negative": MessageLookupByLibrary.simpleMessage("Negative"),
    "neutral": MessageLookupByLibrary.simpleMessage("Neutral"),
    "newChallenge": MessageLookupByLibrary.simpleMessage("New Challenge"),
    "newChallengesAvailable": MessageLookupByLibrary.simpleMessage(
      "New challenges are now available in your catalog.",
    ),
    "nextMotivation1": m7,
    "nextMotivation2": m8,
    "noChalllengesFound": MessageLookupByLibrary.simpleMessage(
      "No challenges found",
    ),
    "noEntriesYet": MessageLookupByLibrary.simpleMessage("No Entries Yet"),
    "noNotesYet": MessageLookupByLibrary.simpleMessage(
      "You don\'t have any notes for this challenge yet.",
    ),
    "notNow": MessageLookupByLibrary.simpleMessage("Not now"),
    "notSureWhatToSay": MessageLookupByLibrary.simpleMessage(
      "Not sure what to say?",
    ),
    "notToday": MessageLookupByLibrary.simpleMessage("Not today 🙈"),
    "notes": MessageLookupByLibrary.simpleMessage("Notes:"),
    "notesPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Your thoughts, observations, ...",
    ),
    "notificationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Syntra needs notification permissions to remind you about your challenges and deliver important updates.",
    ),
    "notificationPermissionsDescription": MessageLookupByLibrary.simpleMessage(
      "For reliable notifications, please disable battery optimization for this app and check your autostart/background app settings.",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationsDisabled": MessageLookupByLibrary.simpleMessage(
      "🔕 Notifications disabled",
    ),
    "notificationsEnabled": MessageLookupByLibrary.simpleMessage(
      "✅ Notifications enabled",
    ),
    "notificationsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Get reminded about daily challenges",
    ),
    "okayButton": MessageLookupByLibrary.simpleMessage("Okay"),
    "onboarding1Button": MessageLookupByLibrary.simpleMessage(
      "Let\'s see how it works →",
    ),
    "onboarding1Headline": MessageLookupByLibrary.simpleMessage(
      "Social confidence is a skill.\nSkills can be trained.",
    ),
    "onboarding1Subtext": MessageLookupByLibrary.simpleMessage(
      "Syntra gives you small, real-world challenges to practice every day. No classes. No scripts. Just you, out in the world.",
    ),
    "onboarding2Button": MessageLookupByLibrary.simpleMessage("Got it →"),
    "onboarding2Headline": MessageLookupByLibrary.simpleMessage(
      "One challenge at a time.",
    ),
    "onboarding2Step1": MessageLookupByLibrary.simpleMessage(
      "Pick a challenge",
    ),
    "onboarding2Step2": MessageLookupByLibrary.simpleMessage(
      "Go do it — timer helps",
    ),
    "onboarding2Step3": MessageLookupByLibrary.simpleMessage("Log your result"),
    "onboarding2Subtext": MessageLookupByLibrary.simpleMessage(
      "Each one is designed to push you just slightly past your comfort zone. You choose how hard to go.",
    ),
    "onboarding3Button": MessageLookupByLibrary.simpleMessage("I\'m in →"),
    "onboarding3Headline": MessageLookupByLibrary.simpleMessage(
      "It\'s okay to feel nervous.\nThat\'s kind of the point.",
    ),
    "onboarding3Subtext": MessageLookupByLibrary.simpleMessage(
      "Every challenge in this app is designed to be safe. Nothing extreme, nothing embarrassing. The awkward feeling you get is exactly what builds confidence over time.\n\nMost people feel it. Nobody dies from it.",
    ),
    "onboarding4Headline": MessageLookupByLibrary.simpleMessage(
      "Where are you starting from?",
    ),
    "onboarding4Level1Subtitle": MessageLookupByLibrary.simpleMessage(
      "Social situations often feel uncomfortable",
    ),
    "onboarding4Level1Title": MessageLookupByLibrary.simpleMessage(
      "Just getting started",
    ),
    "onboarding4Level2Subtitle": MessageLookupByLibrary.simpleMessage(
      "I try, but sometimes freeze up",
    ),
    "onboarding4Level2Title": MessageLookupByLibrary.simpleMessage(
      "Some experience",
    ),
    "onboarding4Level3Subtitle": MessageLookupByLibrary.simpleMessage(
      "I want to level up, not start from scratch",
    ),
    "onboarding4Level3Title": MessageLookupByLibrary.simpleMessage(
      "Ready to push harder",
    ),
    "onboarding4Subtext": MessageLookupByLibrary.simpleMessage(
      "We\'ll show you challenges that fit where you are right now.",
    ),
    "onboarding5Button": MessageLookupByLibrary.simpleMessage(
      "Set my reminder →",
    ),
    "onboarding5Headline": MessageLookupByLibrary.simpleMessage(
      "5 minutes a day is enough.",
    ),
    "onboarding5Subtext": MessageLookupByLibrary.simpleMessage(
      "The science on habit formation says consistency matters more than intensity. One small thing, every day, changes your brain. Literally.",
    ),
    "openBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Open Battery Settings",
    ),
    "perception": MessageLookupByLibrary.simpleMessage("Perception"),
    "positive": MessageLookupByLibrary.simpleMessage("Positive"),
    "preferAnotherChallenge": MessageLookupByLibrary.simpleMessage(
      "I\'d prefer another challenge",
    ),
    "primingHeadlineDefault": MessageLookupByLibrary.simpleMessage(
      "Take a breath.\nYou\'ve got this.",
    ),
    "primingHeadlineFlirt": MessageLookupByLibrary.simpleMessage(
      "Confidence is attractive.",
    ),
    "primingHeadlineGroup": MessageLookupByLibrary.simpleMessage(
      "You\'re about to connect with someone real.",
    ),
    "primingHeadlineHard": MessageLookupByLibrary.simpleMessage(
      "This one takes courage.\nYou have it.",
    ),
    "primingHeadlineQuick": MessageLookupByLibrary.simpleMessage(
      "One small step. That\'s all this is.",
    ),
    "primingSubDefault": MessageLookupByLibrary.simpleMessage(
      "Every time you do this, it gets a little easier. Your future self is already grateful.",
    ),
    "primingSubFlirt": MessageLookupByLibrary.simpleMessage(
      "Flirting is just playful communication. The outcome doesn\'t matter — showing up does.",
    ),
    "primingSubGroup": MessageLookupByLibrary.simpleMessage(
      "Most people are friendlier than you expect. One interaction can shift your whole day.",
    ),
    "primingSubHard": MessageLookupByLibrary.simpleMessage(
      "The challenges that scare you most are the ones that grow you the most. This is one of those.",
    ),
    "primingSubQuick": MessageLookupByLibrary.simpleMessage(
      "Under a minute of action. The discomfort fades faster than you think.",
    ),
    "quote1": MessageLookupByLibrary.simpleMessage(
      "\"The only limit to our realization of tomorrow will be our doubts of today.\"",
    ),
    "quote2": MessageLookupByLibrary.simpleMessage(
      "\"Courage is not the absence of fear, but the triumph over it.\"",
    ),
    "quote3": MessageLookupByLibrary.simpleMessage(
      "\"Do one thing every day that scares you.\"",
    ),
    "quote4": MessageLookupByLibrary.simpleMessage(
      "\"Life begins at the end of your comfort zone.\"",
    ),
    "quote5": MessageLookupByLibrary.simpleMessage(
      "\"The cave you fear to enter holds the treasure you seek.\"",
    ),
    "quote6": MessageLookupByLibrary.simpleMessage(
      "\"What would you attempt to do if you knew you could not fail?\"",
    ),
    "quote7": MessageLookupByLibrary.simpleMessage(
      "\"Everything you\'ve ever wanted is on the other side of fear.\"",
    ),
    "quote8": MessageLookupByLibrary.simpleMessage(
      "\"You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.\"",
    ),
    "reachedTheTop": MessageLookupByLibrary.simpleMessage(
      "You\'ve reached the top. Keep going.",
    ),
    "rememberOnMyOwn": MessageLookupByLibrary.simpleMessage(
      "I\'ll remember on my own →",
    ),
    "reminderExplanation": MessageLookupByLibrary.simpleMessage(
      "We\'ll send you one nudge a day — your choice when. No spam. You can turn it off any time in Settings.",
    ),
    "reminderUpdated": m9,
    "repeatChallengeInfo": MessageLookupByLibrary.simpleMessage(
      "You can repeat this challenge as often as you like!",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "retryChallenge": MessageLookupByLibrary.simpleMessage("Try Again"),
    "rewardFactor": MessageLookupByLibrary.simpleMessage("Reward Factor"),
    "sat": MessageLookupByLibrary.simpleMessage("S"),
    "saveEntry": MessageLookupByLibrary.simpleMessage("Save Entry"),
    "score": MessageLookupByLibrary.simpleMessage("Score:"),
    "searchChallenge": MessageLookupByLibrary.simpleMessage("Search Challenge"),
    "searchForChallenge": MessageLookupByLibrary.simpleMessage(
      "Search for a challenge...",
    ),
    "setDifficultyManually": MessageLookupByLibrary.simpleMessage(
      "Set difficulty manually",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "showReminderNotifications": MessageLookupByLibrary.simpleMessage(
      "Show reminder notifications",
    ),
    "shuffleTooltip": MessageLookupByLibrary.simpleMessage(
      "shuffle challenges",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "skipForNow": MessageLookupByLibrary.simpleMessage("Skip for now"),
    "solo": MessageLookupByLibrary.simpleMessage("Solo"),
    "somePermissionsMissing": MessageLookupByLibrary.simpleMessage(
      "Some permissions are still missing. Please enable them manually.",
    ),
    "soundEffects": MessageLookupByLibrary.simpleMessage("Sound Effects"),
    "soundEffectsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Play sounds for interactions",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startChallengeQuestion": MessageLookupByLibrary.simpleMessage(
      "Do you really want to do today\'s challenge now?",
    ),
    "startNow": MessageLookupByLibrary.simpleMessage("Start Now"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusSuccess": MessageLookupByLibrary.simpleMessage("Completed"),
    "statusTried": MessageLookupByLibrary.simpleMessage("Gave it a try"),
    "stayCurious": MessageLookupByLibrary.simpleMessage(
      "Stay curious and open-minded",
    ),
    "stillSecondsLeft": m10,
    "storyFirstChallenge": MessageLookupByLibrary.simpleMessage(
      "Your story starts with the first challenge you complete.",
    ),
    "storyMinutesBrave": m11,
    "storyNTimes": m12,
    "storyOnce": MessageLookupByLibrary.simpleMessage(
      "You have stepped outside your comfort zone once. That takes courage.",
    ),
    "storyStreakMany": m13,
    "storyStreakOne": MessageLookupByLibrary.simpleMessage(
      "Day 1 of a new streak. Every big streak started here.",
    ),
    "storyXpKilo": m14,
    "storyXpSmall": m15,
    "streak": MessageLookupByLibrary.simpleMessage("Streak"),
    "streakMilestone100": MessageLookupByLibrary.simpleMessage(
      "100 days. You\'ve built something extraordinary. Respect.",
    ),
    "streakMilestone14": MessageLookupByLibrary.simpleMessage(
      "Two weeks straight. You\'re not the same person you were 14 days ago.",
    ),
    "streakMilestone3": MessageLookupByLibrary.simpleMessage(
      "Three days in a row. You\'re building a habit.",
    ),
    "streakMilestone30": MessageLookupByLibrary.simpleMessage(
      "30 days. A whole month of showing up. That\'s rare. That\'s powerful.",
    ),
    "streakMilestone60": MessageLookupByLibrary.simpleMessage(
      "60 days. Most people quit after a week. You didn\'t.",
    ),
    "streakMilestone7": MessageLookupByLibrary.simpleMessage(
      "A full week! Your comfort zone just got bigger.",
    ),
    "streakMilestoneGeneric": m16,
    "streakMilestoneTitle": m17,
    "sun": MessageLookupByLibrary.simpleMessage("S"),
    "thankYouFeedback": MessageLookupByLibrary.simpleMessage(
      "Thank you for your feedback!",
    ),
    "threeChallengesTodo": MessageLookupByLibrary.simpleMessage(
      "Three challenges. Any order. All count.",
    ),
    "thu": MessageLookupByLibrary.simpleMessage("T"),
    "timeRemaining": MessageLookupByLibrary.simpleMessage("Time Remaining"),
    "timeUpNotificationBody": MessageLookupByLibrary.simpleMessage(
      "Your challenge time is over! Time for action! 💪",
    ),
    "timeUpNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "Time\'s up!",
    ),
    "timesTried": MessageLookupByLibrary.simpleMessage("Times Tried"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "todaysMissions": MessageLookupByLibrary.simpleMessage("Today\'s Missions"),
    "tooBad": MessageLookupByLibrary.simpleMessage(
      "Too bad! You aborted the challenge.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalXp": MessageLookupByLibrary.simpleMessage("Total XP"),
    "tryAgainNextTime": MessageLookupByLibrary.simpleMessage(
      "Try again next time!",
    ),
    "tue": MessageLookupByLibrary.simpleMessage("T"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "veryBad": MessageLookupByLibrary.simpleMessage("Very bad"),
    "veryGood": MessageLookupByLibrary.simpleMessage("Very good"),
    "veryNegative": MessageLookupByLibrary.simpleMessage("Very negative"),
    "veryPositive": MessageLookupByLibrary.simpleMessage("Very positive"),
    "wantReminders": MessageLookupByLibrary.simpleMessage(
      "Want us to remind you?",
    ),
    "wed": MessageLookupByLibrary.simpleMessage("W"),
    "weeklyChallenges": MessageLookupByLibrary.simpleMessage(
      "Weekly Challenges",
    ),
    "weeklyXpProgress": MessageLookupByLibrary.simpleMessage("Weekly Aura"),
    "wellDone": MessageLookupByLibrary.simpleMessage("Well done! Keep it up!"),
    "xp": MessageLookupByLibrary.simpleMessage("XP"),
    "xpEarnedThisWeek": MessageLookupByLibrary.simpleMessage(
      "XP Earned This Week",
    ),
    "yesChallengeStart": MessageLookupByLibrary.simpleMessage(
      "Yes, I completed it",
    ),
    "yourProgress": MessageLookupByLibrary.simpleMessage("Your Progress"),
    "yourStatistics": MessageLookupByLibrary.simpleMessage("Your Statistics"),
  };
}
