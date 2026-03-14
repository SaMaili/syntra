// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Get reminded about daily challenges`
  String get notificationsSubtitle {
    return Intl.message(
      'Get reminded about daily challenges',
      name: 'notificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Switch to dark theme`
  String get darkModeSubtitle {
    return Intl.message(
      'Switch to dark theme',
      name: 'darkModeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effects`
  String get soundEffects {
    return Intl.message(
      'Sound Effects',
      name: 'soundEffects',
      desc: '',
      args: [],
    );
  }

  /// `Play sounds for interactions`
  String get soundEffectsSubtitle {
    return Intl.message(
      'Play sounds for interactions',
      name: 'soundEffectsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Choose your preferred language`
  String get languageSubtitle {
    return Intl.message(
      'Choose your preferred language',
      name: 'languageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `App version and information`
  String get aboutSubtitle {
    return Intl.message(
      'App version and information',
      name: 'aboutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Debug Delete`
  String get debugDeleteTooltip {
    return Intl.message(
      'Debug Delete',
      name: 'debugDeleteTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Next Motivation 1: {time}`
  String nextMotivation1(String time) {
    return Intl.message(
      'Next Motivation 1: $time',
      name: 'nextMotivation1',
      desc: '',
      args: [time],
    );
  }

  /// `Next Motivation 2: {time}`
  String nextMotivation2(String time) {
    return Intl.message(
      'Next Motivation 2: $time',
      name: 'nextMotivation2',
      desc: '',
      args: [time],
    );
  }

  /// `English`
  String get languageEnglish {
    return Intl.message('English', name: 'languageEnglish', desc: '', args: []);
  }

  /// `Deutsch`
  String get languageGerman {
    return Intl.message('Deutsch', name: 'languageGerman', desc: '', args: []);
  }

  /// `日本語`
  String get languageJapanese {
    return Intl.message('日本語', name: 'languageJapanese', desc: '', args: []);
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Challenge`
  String get navChallenge {
    return Intl.message('Challenge', name: 'navChallenge', desc: '', args: []);
  }

  /// `Daily`
  String get navDaily {
    return Intl.message('Daily', name: 'navDaily', desc: '', args: []);
  }

  /// `Stats`
  String get navStats {
    return Intl.message('Stats', name: 'navStats', desc: '', args: []);
  }

  /// `Settings`
  String get navSettings {
    return Intl.message('Settings', name: 'navSettings', desc: '', args: []);
  }

  /// `Time Remaining`
  String get timeRemaining {
    return Intl.message(
      'Time Remaining',
      name: 'timeRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Not sure what to say?`
  String get notSureWhatToSay {
    return Intl.message(
      'Not sure what to say?',
      name: 'notSureWhatToSay',
      desc: '',
      args: [],
    );
  }

  /// `DONE! 😎`
  String get doneExcited {
    return Intl.message('DONE! 😎', name: 'doneExcited', desc: '', args: []);
  }

  /// `Blocked {seconds} seconds`
  String stillSecondsLeft(String seconds) {
    return Intl.message(
      'Blocked $seconds seconds',
      name: 'stillSecondsLeft',
      desc: '',
      args: [seconds],
    );
  }

  /// `Not today 🙈`
  String get notToday {
    return Intl.message('Not today 🙈', name: 'notToday', desc: '', args: []);
  }

  /// `Challenge completed!`
  String get challengeCompleted {
    return Intl.message(
      'Challenge completed!',
      name: 'challengeCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Challenge aborted`
  String get challengeAborted {
    return Intl.message(
      'Challenge aborted',
      name: 'challengeAborted',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! You completed the challenge.`
  String get congratulations {
    return Intl.message(
      'Congratulations! You completed the challenge.',
      name: 'congratulations',
      desc: '',
      args: [],
    );
  }

  /// `Too bad! You aborted the challenge.`
  String get tooBad {
    return Intl.message(
      'Too bad! You aborted the challenge.',
      name: 'tooBad',
      desc: '',
      args: [],
    );
  }

  /// `Aura`
  String get auraPoints {
    return Intl.message('Aura', name: 'auraPoints', desc: '', args: []);
  }

  /// `How did you feel?`
  String get howDidYouFeel {
    return Intl.message(
      'How did you feel?',
      name: 'howDidYouFeel',
      desc: '',
      args: [],
    );
  }

  /// `How do you think you were perceived?`
  String get howPerceivedQuestion {
    return Intl.message(
      'How do you think you were perceived?',
      name: 'howPerceivedQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Notes:`
  String get notes {
    return Intl.message('Notes:', name: 'notes', desc: '', args: []);
  }

  /// `Your thoughts, observations, ...`
  String get notesPlaceholder {
    return Intl.message(
      'Your thoughts, observations, ...',
      name: 'notesPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your feedback!`
  String get thankYouFeedback {
    return Intl.message(
      'Thank you for your feedback!',
      name: 'thankYouFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Back to Home`
  String get backToHome {
    return Intl.message('Back to Home', name: 'backToHome', desc: '', args: []);
  }

  /// `Challenge aborted!`
  String get challengeAbortedSnackbar {
    return Intl.message(
      'Challenge aborted!',
      name: 'challengeAbortedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Challenge completed! Logbook entry saved.`
  String get challengeCompletedSnackbar {
    return Intl.message(
      'Challenge completed! Logbook entry saved.',
      name: 'challengeCompletedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Well done! Keep it up!`
  String get wellDone {
    return Intl.message(
      'Well done! Keep it up!',
      name: 'wellDone',
      desc: '',
      args: [],
    );
  }

  /// `Try again next time!`
  String get tryAgainNextTime {
    return Intl.message(
      'Try again next time!',
      name: 'tryAgainNextTime',
      desc: '',
      args: [],
    );
  }

  /// `No challenges found`
  String get noChalllengesFound {
    return Intl.message(
      'No challenges found',
      name: 'noChalllengesFound',
      desc: '',
      args: [],
    );
  }

  /// `Challenges shuffled!`
  String get challengesShuffled {
    return Intl.message(
      'Challenges shuffled!',
      name: 'challengesShuffled',
      desc: '',
      args: [],
    );
  }

  /// `Challenge completed!`
  String get challengeCompletedGeneric {
    return Intl.message(
      'Challenge completed!',
      name: 'challengeCompletedGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Score:`
  String get score {
    return Intl.message('Score:', name: 'score', desc: '', args: []);
  }

  /// `shuffle challenges`
  String get shuffleTooltip {
    return Intl.message(
      'shuffle challenges',
      name: 'shuffleTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Solo`
  String get solo {
    return Intl.message('Solo', name: 'solo', desc: '', args: []);
  }

  /// `Group`
  String get group {
    return Intl.message('Group', name: 'group', desc: '', args: []);
  }

  /// `Daily Challenge`
  String get dailyChallenge {
    return Intl.message(
      'Daily Challenge',
      name: 'dailyChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Start challenge?`
  String get challengeStartQuestion {
    return Intl.message(
      'Start challenge?',
      name: 'challengeStartQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to do today's challenge now?`
  String get startChallengeQuestion {
    return Intl.message(
      'Do you really want to do today\'s challenge now?',
      name: 'startChallengeQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Yes, I completed it`
  String get yesChallengeStart {
    return Intl.message(
      'Yes, I completed it',
      name: 'yesChallengeStart',
      desc: '',
      args: [],
    );
  }

  /// `Accept Challenge`
  String get acceptChallenge {
    return Intl.message(
      'Accept Challenge',
      name: 'acceptChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Challenge completed!`
  String get challengeCompletedDaily {
    return Intl.message(
      'Challenge completed!',
      name: 'challengeCompletedDaily',
      desc: '',
      args: [],
    );
  }

  /// `Great job! You have mastered today's challenge.`
  String get greatJobDaily {
    return Intl.message(
      'Great job! You have mastered today\'s challenge.',
      name: 'greatJobDaily',
      desc: '',
      args: [],
    );
  }

  /// `Your Statistics`
  String get yourStatistics {
    return Intl.message(
      'Your Statistics',
      name: 'yourStatistics',
      desc: '',
      args: [],
    );
  }

  /// `Challenge Logbook`
  String get challengeLogbook {
    return Intl.message(
      'Challenge Logbook',
      name: 'challengeLogbook',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Aura`
  String get weeklyXpProgress {
    return Intl.message(
      'Weekly Aura',
      name: 'weeklyXpProgress',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Challenges`
  String get weeklyChallenges {
    return Intl.message(
      'Weekly Challenges',
      name: 'weeklyChallenges',
      desc: '',
      args: [],
    );
  }

  /// `DB Debug: Show all logbook table`
  String get dbDebugShow {
    return Intl.message(
      'DB Debug: Show all logbook table',
      name: 'dbDebugShow',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Streak`
  String get streak {
    return Intl.message('Streak', name: 'streak', desc: '', args: []);
  }

  /// `Logbook`
  String get logbook {
    return Intl.message('Logbook', name: 'logbook', desc: '', args: []);
  }

  /// `Add Custom Challenge`
  String get addCustomChallenge {
    return Intl.message(
      'Add Custom Challenge',
      name: 'addCustomChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Logbook Entry`
  String get logbookEntry {
    return Intl.message(
      'Logbook Entry',
      name: 'logbookEntry',
      desc: '',
      args: [],
    );
  }

  /// `Challenge`
  String get challenge {
    return Intl.message('Challenge', name: 'challenge', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `XP`
  String get xp {
    return Intl.message('XP', name: 'xp', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Feeling`
  String get feeling {
    return Intl.message('Feeling', name: 'feeling', desc: '', args: []);
  }

  /// `Perception`
  String get perception {
    return Intl.message('Perception', name: 'perception', desc: '', args: []);
  }

  /// `Challenge ID`
  String get challengeId {
    return Intl.message(
      'Challenge ID',
      name: 'challengeId',
      desc: '',
      args: [],
    );
  }

  /// `Delete Entry`
  String get deleteEntry {
    return Intl.message(
      'Delete Entry',
      name: 'deleteEntry',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this entry?`
  String get deleteEntryQuestion {
    return Intl.message(
      'Are you sure you want to delete this entry?',
      name: 'deleteEntryQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Entry deleted`
  String get entryDeleted {
    return Intl.message(
      'Entry deleted',
      name: 'entryDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Add Custom Challenge`
  String get addCustomChallengeTitle {
    return Intl.message(
      'Add Custom Challenge',
      name: 'addCustomChallengeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Challenge already exists?`
  String get challengeAlreadyExists {
    return Intl.message(
      'Challenge already exists?',
      name: 'challengeAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Search Challenge`
  String get searchChallenge {
    return Intl.message(
      'Search Challenge',
      name: 'searchChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Challenge Name`
  String get challengeName {
    return Intl.message(
      'Challenge Name',
      name: 'challengeName',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Enter a name`
  String get enterName {
    return Intl.message('Enter a name', name: 'enterName', desc: '', args: []);
  }

  /// `Enter a description`
  String get enterDescription {
    return Intl.message(
      'Enter a description',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `How do you feel?`
  String get howDoYouFeel {
    return Intl.message(
      'How do you feel?',
      name: 'howDoYouFeel',
      desc: '',
      args: [],
    );
  }

  /// `How do you think you will be perceived?`
  String get howPerceivedThink {
    return Intl.message(
      'How do you think you will be perceived?',
      name: 'howPerceivedThink',
      desc: '',
      args: [],
    );
  }

  /// `Save Entry`
  String get saveEntry {
    return Intl.message('Save Entry', name: 'saveEntry', desc: '', args: []);
  }

  /// `Logbook entry saved`
  String get logbookEntrySaved {
    return Intl.message(
      'Logbook entry saved',
      name: 'logbookEntrySaved',
      desc: '',
      args: [],
    );
  }

  /// `Very bad`
  String get veryBad {
    return Intl.message('Very bad', name: 'veryBad', desc: '', args: []);
  }

  /// `Bad`
  String get bad {
    return Intl.message('Bad', name: 'bad', desc: '', args: []);
  }

  /// `Neutral`
  String get neutral {
    return Intl.message('Neutral', name: 'neutral', desc: '', args: []);
  }

  /// `Good`
  String get good {
    return Intl.message('Good', name: 'good', desc: '', args: []);
  }

  /// `Very good`
  String get veryGood {
    return Intl.message('Very good', name: 'veryGood', desc: '', args: []);
  }

  /// `Very negative`
  String get veryNegative {
    return Intl.message(
      'Very negative',
      name: 'veryNegative',
      desc: '',
      args: [],
    );
  }

  /// `Negative`
  String get negative {
    return Intl.message('Negative', name: 'negative', desc: '', args: []);
  }

  /// `Positive`
  String get positive {
    return Intl.message('Positive', name: 'positive', desc: '', args: []);
  }

  /// `Very positive`
  String get veryPositive {
    return Intl.message(
      'Very positive',
      name: 'veryPositive',
      desc: '',
      args: [],
    );
  }

  /// `Mindset & Growth`
  String get mindsetGrowth {
    return Intl.message(
      'Mindset & Growth',
      name: 'mindsetGrowth',
      desc: '',
      args: [],
    );
  }

  /// `Your mindset shapes your reality.`
  String get mindsetShapesReality {
    return Intl.message(
      'Your mindset shapes your reality.',
      name: 'mindsetShapesReality',
      desc: '',
      args: [],
    );
  }

  /// `Growth starts with a decision: courage, openness, and positivity.`
  String get growthStartsDecision {
    return Intl.message(
      'Growth starts with a decision: courage, openness, and positivity.',
      name: 'growthStartsDecision',
      desc: '',
      args: [],
    );
  }

  /// `Every day is a new chance to grow and surpass yourself.`
  String get everyDayNewChance {
    return Intl.message(
      'Every day is a new chance to grow and surpass yourself.',
      name: 'everyDayNewChance',
      desc: '',
      args: [],
    );
  }

  /// `Mindset Tips`
  String get mindsetTips {
    return Intl.message(
      'Mindset Tips',
      name: 'mindsetTips',
      desc: '',
      args: [],
    );
  }

  /// `Embrace challenges as opportunities`
  String get embraceChallenges {
    return Intl.message(
      'Embrace challenges as opportunities',
      name: 'embraceChallenges',
      desc: '',
      args: [],
    );
  }

  /// `Focus on progress, not perfection`
  String get focusProgress {
    return Intl.message(
      'Focus on progress, not perfection',
      name: 'focusProgress',
      desc: '',
      args: [],
    );
  }

  /// `Celebrate small wins daily`
  String get celebrateSmallWins {
    return Intl.message(
      'Celebrate small wins daily',
      name: 'celebrateSmallWins',
      desc: '',
      args: [],
    );
  }

  /// `Learn from setbacks`
  String get learnSetbacks {
    return Intl.message(
      'Learn from setbacks',
      name: 'learnSetbacks',
      desc: '',
      args: [],
    );
  }

  /// `Stay curious and open-minded`
  String get stayCurious {
    return Intl.message(
      'Stay curious and open-minded',
      name: 'stayCurious',
      desc: '',
      args: [],
    );
  }

  /// `"The only limit to our realization of tomorrow will be our doubts of today."`
  String get motivationalQuote {
    return Intl.message(
      '"The only limit to our realization of tomorrow will be our doubts of today."',
      name: 'motivationalQuote',
      desc: '',
      args: [],
    );
  }

  /// `Ready for a new challenge? Let's go!`
  String get motivationMessage1 {
    return Intl.message(
      'Ready for a new challenge? Let\'s go!',
      name: 'motivationMessage1',
      desc: '',
      args: [],
    );
  }

  /// `Keep up the great work! Try a challenge today!`
  String get motivationMessage2 {
    return Intl.message(
      'Keep up the great work! Try a challenge today!',
      name: 'motivationMessage2',
      desc: '',
      args: [],
    );
  }

  /// `Your next win is waiting. Take on a challenge!`
  String get motivationMessage3 {
    return Intl.message(
      'Your next win is waiting. Take on a challenge!',
      name: 'motivationMessage3',
      desc: '',
      args: [],
    );
  }

  /// `Small steps, big results. Do a challenge!`
  String get motivationMessage4 {
    return Intl.message(
      'Small steps, big results. Do a challenge!',
      name: 'motivationMessage4',
      desc: '',
      args: [],
    );
  }

  /// `Stay motivated! Complete a challenge now!`
  String get motivationMessage5 {
    return Intl.message(
      'Stay motivated! Complete a challenge now!',
      name: 'motivationMessage5',
      desc: '',
      args: [],
    );
  }

  /// `You are the sun! But what is the sun if it can't shine?\nDo a challenge!`
  String get motivationMessage6 {
    return Intl.message(
      'You are the sun! But what is the sun if it can\'t shine?\nDo a challenge!',
      name: 'motivationMessage6',
      desc: '',
      args: [],
    );
  }

  /// `Are you outside? Then you should do a challenge!`
  String get motivationMessage7 {
    return Intl.message(
      'Are you outside? Then you should do a challenge!',
      name: 'motivationMessage7',
      desc: '',
      args: [],
    );
  }

  /// `It takes only 5 minutes to do a challenge!\nWhat are you waiting for?`
  String get motivationMessage8 {
    return Intl.message(
      'It takes only 5 minutes to do a challenge!\nWhat are you waiting for?',
      name: 'motivationMessage8',
      desc: '',
      args: [],
    );
  }

  /// `Get New Motivation`
  String get getNewMotivation {
    return Intl.message(
      'Get New Motivation',
      name: 'getNewMotivation',
      desc: '',
      args: [],
    );
  }

  /// `Allow Exact Alarms`
  String get allowExactAlarms {
    return Intl.message(
      'Allow Exact Alarms',
      name: 'allowExactAlarms',
      desc: '',
      args: [],
    );
  }

  /// `To ensure accurate challenge timers, please allow exact alarms in your device settings.`
  String get exactAlarmsDescription {
    return Intl.message(
      'To ensure accurate challenge timers, please allow exact alarms in your device settings.',
      name: 'exactAlarmsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Go to Settings`
  String get goToSettings {
    return Intl.message(
      'Go to Settings',
      name: 'goToSettings',
      desc: '',
      args: [],
    );
  }

  /// `Important Notification Settings`
  String get importantNotificationHints {
    return Intl.message(
      'Important Notification Settings',
      name: 'importantNotificationHints',
      desc: '',
      args: [],
    );
  }

  /// `For reliable notifications, please disable battery optimization for this app and check your autostart/background app settings.`
  String get notificationPermissionsDescription {
    return Intl.message(
      'For reliable notifications, please disable battery optimization for this app and check your autostart/background app settings.',
      name: 'notificationPermissionsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Open Battery Settings`
  String get openBatteryOptimization {
    return Intl.message(
      'Open Battery Settings',
      name: 'openBatteryOptimization',
      desc: '',
      args: [],
    );
  }

  /// `Time's up!`
  String get timeUpNotificationTitle {
    return Intl.message(
      'Time\'s up!',
      name: 'timeUpNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your challenge time is over! Time for action! 💪`
  String get timeUpNotificationBody {
    return Intl.message(
      'Your challenge time is over! Time for action! 💪',
      name: 'timeUpNotificationBody',
      desc: '',
      args: [],
    );
  }

  /// `Start Challenge?`
  String get challengeConfirmTitle {
    return Intl.message(
      'Start Challenge?',
      name: 'challengeConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ready to take on: {challengeTitle}?`
  String challengeConfirmMessage(String challengeTitle) {
    return Intl.message(
      'Ready to take on: $challengeTitle?',
      name: 'challengeConfirmMessage',
      desc: '',
      args: [challengeTitle],
    );
  }

  /// `I'd prefer another challenge`
  String get preferAnotherChallenge {
    return Intl.message(
      'I\'d prefer another challenge',
      name: 'preferAnotherChallenge',
      desc: '',
      args: [],
    );
  }

  /// `LET'S GO!`
  String get letsGo {
    return Intl.message('LET\'S GO!', name: 'letsGo', desc: '', args: []);
  }

  /// `🎉 Timer Complete!`
  String get challengeTimerCompleteTitle {
    return Intl.message(
      '🎉 Timer Complete!',
      name: 'challengeTimerCompleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your challenge "{challengeTitle}" just finished! 🏆`
  String challengeTimerCompleteBody(String challengeTitle) {
    return Intl.message(
      'Your challenge "$challengeTitle" just finished! 🏆',
      name: 'challengeTimerCompleteBody',
      desc: '',
      args: [challengeTitle],
    );
  }

  /// `Challenge Description`
  String get challengeDescriptionTitle {
    return Intl.message(
      'Challenge Description',
      name: 'challengeDescriptionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeDialog {
    return Intl.message('Close', name: 'closeDialog', desc: '', args: []);
  }

  /// `Lost for words?`
  String get lostForWords {
    return Intl.message(
      'Lost for words?',
      name: 'lostForWords',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get okayButton {
    return Intl.message('Okay', name: 'okayButton', desc: '', args: []);
  }

  /// `You have already completed this challenge!`
  String get challengeAlreadyCompleted {
    return Intl.message(
      'You have already completed this challenge!',
      name: 'challengeAlreadyCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Last note:`
  String get lastNote {
    return Intl.message('Last note:', name: 'lastNote', desc: '', args: []);
  }

  /// `Last completed:`
  String get lastCompleted {
    return Intl.message(
      'Last completed:',
      name: 'lastCompleted',
      desc: '',
      args: [],
    );
  }

  /// `You can repeat this challenge as often as you like!`
  String get repeatChallengeInfo {
    return Intl.message(
      'You can repeat this challenge as often as you like!',
      name: 'repeatChallengeInfo',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any notes for this challenge yet.`
  String get noNotesYet {
    return Intl.message(
      'You don\'t have any notes for this challenge yet.',
      name: 'noNotesYet',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Failed`
  String get failed {
    return Intl.message('Failed', name: 'failed', desc: '', args: []);
  }

  /// `Challenge Type`
  String get challengeType {
    return Intl.message(
      'Challenge Type',
      name: 'challengeType',
      desc: '',
      args: [],
    );
  }

  /// `Existing Challenge`
  String get existingChallenge {
    return Intl.message(
      'Existing Challenge',
      name: 'existingChallenge',
      desc: '',
      args: [],
    );
  }

  /// `New Challenge`
  String get newChallenge {
    return Intl.message(
      'New Challenge',
      name: 'newChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Search for a challenge...`
  String get searchForChallenge {
    return Intl.message(
      'Search for a challenge...',
      name: 'searchForChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Challenge Details`
  String get challengeDetails {
    return Intl.message(
      'Challenge Details',
      name: 'challengeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Enter your notes here...`
  String get enterYourNotes {
    return Intl.message(
      'Enter your notes here...',
      name: 'enterYourNotes',
      desc: '',
      args: [],
    );
  }

  /// `Daily Reminders`
  String get dailyReminders {
    return Intl.message(
      'Daily Reminders',
      name: 'dailyReminders',
      desc: '',
      args: [],
    );
  }

  /// `Get reminded to complete challenges`
  String get dailyRemindersSubtitle {
    return Intl.message(
      'Get reminded to complete challenges',
      name: 'dailyRemindersSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `✅ Notifications enabled`
  String get notificationsEnabled {
    return Intl.message(
      '✅ Notifications enabled',
      name: 'notificationsEnabled',
      desc: '',
      args: [],
    );
  }

  /// `🔕 Notifications disabled`
  String get notificationsDisabled {
    return Intl.message(
      '🔕 Notifications disabled',
      name: 'notificationsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `⏰ {period} reminder updated to {time}`
  String reminderUpdated(String period, String time) {
    return Intl.message(
      '⏰ $period reminder updated to $time',
      name: 'reminderUpdated',
      desc: '',
      args: [period, time],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message('Morning', name: 'morning', desc: '', args: []);
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message('Afternoon', name: 'afternoon', desc: '', args: []);
  }

  /// `Evening`
  String get evening {
    return Intl.message('Evening', name: 'evening', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
