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

  /// `DONE!`
  String get doneExcited {
    return Intl.message('DONE!', name: 'doneExcited', desc: '', args: []);
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

  /// `Daily Bonus`
  String get dailyBonus {
    return Intl.message('Daily Bonus', name: 'dailyBonus', desc: '', args: []);
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

  /// `Try Again`
  String get retryChallenge {
    return Intl.message(
      'Try Again',
      name: 'retryChallenge',
      desc: '',
      args: [],
    );
  }

  /// `Mood Trend`
  String get moodTrend {
    return Intl.message('Mood Trend', name: 'moodTrend', desc: '', args: []);
  }

  /// `Mood Trend (last 20 entries)`
  String get avgMoodTitle {
    return Intl.message(
      'Mood Trend (last 20 entries)',
      name: 'avgMoodTitle',
      desc: '',
      args: [],
    );
  }

  /// `Rate how you feel after each challenge to see your mood trend here.`
  String get avgMoodEmpty {
    return Intl.message(
      'Rate how you feel after each challenge to see your mood trend here.',
      name: 'avgMoodEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Based on how you rated each completed challenge`
  String get avgMoodSubtitle {
    return Intl.message(
      'Based on how you rated each completed challenge',
      name: 'avgMoodSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `🚶 Street`
  String get filterEnvStreet {
    return Intl.message(
      '🚶 Street',
      name: 'filterEnvStreet',
      desc: '',
      args: [],
    );
  }

  /// `🚌 Transit`
  String get filterEnvTransit {
    return Intl.message(
      '🚌 Transit',
      name: 'filterEnvTransit',
      desc: '',
      args: [],
    );
  }

  /// `☕ Café`
  String get filterEnvCafe {
    return Intl.message('☕ Café', name: 'filterEnvCafe', desc: '', args: []);
  }

  /// `🎉 Event`
  String get filterEnvEvent {
    return Intl.message('🎉 Event', name: 'filterEnvEvent', desc: '', args: []);
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
  String get noChallengesFound {
    return Intl.message(
      'No challenges found',
      name: 'noChallengesFound',
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

  /// `Search by challenge ID…`
  String get logbookSearchHint {
    return Intl.message(
      'Search by challenge ID…',
      name: 'logbookSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get logbookFilterAll {
    return Intl.message('All', name: 'logbookFilterAll', desc: '', args: []);
  }

  /// `Completed`
  String get logbookFilterCompleted {
    return Intl.message(
      'Completed',
      name: 'logbookFilterCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Tried`
  String get logbookFilterTried {
    return Intl.message(
      'Tried',
      name: 'logbookFilterTried',
      desc: '',
      args: [],
    );
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

  /// `"The only limit to our realization of tomorrow will be our doubts of today."`
  String get quote1 {
    return Intl.message(
      '"The only limit to our realization of tomorrow will be our doubts of today."',
      name: 'quote1',
      desc: '',
      args: [],
    );
  }

  /// `"Courage is not the absence of fear, but the triumph over it."`
  String get quote2 {
    return Intl.message(
      '"Courage is not the absence of fear, but the triumph over it."',
      name: 'quote2',
      desc: '',
      args: [],
    );
  }

  /// `"Do one thing every day that scares you."`
  String get quote3 {
    return Intl.message(
      '"Do one thing every day that scares you."',
      name: 'quote3',
      desc: '',
      args: [],
    );
  }

  /// `"Life begins at the end of your comfort zone."`
  String get quote4 {
    return Intl.message(
      '"Life begins at the end of your comfort zone."',
      name: 'quote4',
      desc: '',
      args: [],
    );
  }

  /// `"The cave you fear to enter holds the treasure you seek."`
  String get quote5 {
    return Intl.message(
      '"The cave you fear to enter holds the treasure you seek."',
      name: 'quote5',
      desc: '',
      args: [],
    );
  }

  /// `"What would you attempt to do if you knew you could not fail?"`
  String get quote6 {
    return Intl.message(
      '"What would you attempt to do if you knew you could not fail?"',
      name: 'quote6',
      desc: '',
      args: [],
    );
  }

  /// `"Everything you've ever wanted is on the other side of fear."`
  String get quote7 {
    return Intl.message(
      '"Everything you\'ve ever wanted is on the other side of fear."',
      name: 'quote7',
      desc: '',
      args: [],
    );
  }

  /// `"You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face."`
  String get quote8 {
    return Intl.message(
      '"You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face."',
      name: 'quote8',
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

  /// `Explore all challenges`
  String get exploreAllChallenges {
    return Intl.message(
      'Explore all challenges',
      name: 'exploreAllChallenges',
      desc: '',
      args: [],
    );
  }

  /// `No Entries Yet`
  String get noEntriesYet {
    return Intl.message(
      'No Entries Yet',
      name: 'noEntriesYet',
      desc: '',
      args: [],
    );
  }

  /// `Complete some challenges to see them here!`
  String get completeChallengesToSee {
    return Intl.message(
      'Complete some challenges to see them here!',
      name: 'completeChallengesToSee',
      desc: '',
      args: [],
    );
  }

  /// `Challenge #{id}`
  String challengeNumber(String id) {
    return Intl.message(
      'Challenge #$id',
      name: 'challengeNumber',
      desc: '',
      args: [id],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Reward Factor`
  String get rewardFactor {
    return Intl.message(
      'Reward Factor',
      name: 'rewardFactor',
      desc: '',
      args: [],
    );
  }

  /// `How did you feel?`
  String get howDidYouFeelQuestion {
    return Intl.message(
      'How did you feel?',
      name: 'howDidYouFeelQuestion',
      desc: '',
      args: [],
    );
  }

  /// `How were you perceived?`
  String get howPerceivedByOthers {
    return Intl.message(
      'How were you perceived?',
      name: 'howPerceivedByOthers',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this logbook entry? This action cannot be undone.`
  String get deleteEntryConfirm {
    return Intl.message(
      'Are you sure you want to delete this logbook entry? This action cannot be undone.',
      name: 'deleteEntryConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get statusSuccess {
    return Intl.message('Completed', name: 'statusSuccess', desc: '', args: []);
  }

  /// `Gave it a try`
  String get statusTried {
    return Intl.message(
      'Gave it a try',
      name: 'statusTried',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Your Progress`
  String get yourProgress {
    return Intl.message(
      'Your Progress',
      name: 'yourProgress',
      desc: '',
      args: [],
    );
  }

  /// `Your story starts with the first challenge you complete.`
  String get storyFirstChallenge {
    return Intl.message(
      'Your story starts with the first challenge you complete.',
      name: 'storyFirstChallenge',
      desc: '',
      args: [],
    );
  }

  /// `You have stepped outside your comfort zone once. That takes courage.`
  String get storyOnce {
    return Intl.message(
      'You have stepped outside your comfort zone once. That takes courage.',
      name: 'storyOnce',
      desc: '',
      args: [],
    );
  }

  /// `You have stepped outside your comfort zone {count} times.`
  String storyNTimes(int count) {
    return Intl.message(
      'You have stepped outside your comfort zone $count times.',
      name: 'storyNTimes',
      desc: '',
      args: [count],
    );
  }

  /// `You are on a {days}-day streak. Keep the momentum going.`
  String storyStreakMany(int days) {
    return Intl.message(
      'You are on a $days-day streak. Keep the momentum going.',
      name: 'storyStreakMany',
      desc: '',
      args: [days],
    );
  }

  /// `Day 1 of a new streak. Every big streak started here.`
  String get storyStreakOne {
    return Intl.message(
      'Day 1 of a new streak. Every big streak started here.',
      name: 'storyStreakOne',
      desc: '',
      args: [],
    );
  }

  /// `{kilo}k XP earned — you are building something real.`
  String storyXpKilo(String kilo) {
    return Intl.message(
      '${kilo}k XP earned — you are building something real.',
      name: 'storyXpKilo',
      desc: '',
      args: [kilo],
    );
  }

  /// `{xp} XP earned through genuine action.`
  String storyXpSmall(int xp) {
    return Intl.message(
      '$xp XP earned through genuine action.',
      name: 'storyXpSmall',
      desc: '',
      args: [xp],
    );
  }

  /// `Challenges This Week`
  String get challengesThisWeek {
    return Intl.message(
      'Challenges This Week',
      name: 'challengesThisWeek',
      desc: '',
      args: [],
    );
  }

  /// `Each bar is a day. Green = completed, orange = gave it a try.`
  String get chartExplanation {
    return Intl.message(
      'Each bar is a day. Green = completed, orange = gave it a try.',
      name: 'chartExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get legendCompleted {
    return Intl.message(
      'Completed',
      name: 'legendCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Tried`
  String get legendTried {
    return Intl.message('Tried', name: 'legendTried', desc: '', args: []);
  }

  /// `Aura Earned This Week`
  String get xpEarnedThisWeek {
    return Intl.message(
      'Aura Earned This Week',
      name: 'xpEarnedThisWeek',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activity {
    return Intl.message('Activity', name: 'activity', desc: '', args: []);
  }

  /// `each square is one day`
  String get activitySubtitle {
    return Intl.message(
      'each square is one day',
      name: 'activitySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Less`
  String get less {
    return Intl.message('Less', name: 'less', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Total Aura`
  String get totalXp {
    return Intl.message('Total Aura', name: 'totalXp', desc: '', args: []);
  }

  /// `Day Streak`
  String get dayStreak {
    return Intl.message('Day Streak', name: 'dayStreak', desc: '', args: []);
  }

  /// `Times Tried`
  String get timesTried {
    return Intl.message('Times Tried', name: 'timesTried', desc: '', args: []);
  }

  /// `Min. Brave`
  String get minutesBrave {
    return Intl.message('Min. Brave', name: 'minutesBrave', desc: '', args: []);
  }

  /// `Best Streak`
  String get bestStreak {
    return Intl.message('Best Streak', name: 'bestStreak', desc: '', args: []);
  }

  /// `Done Today`
  String get doneToday {
    return Intl.message('Done Today', name: 'doneToday', desc: '', args: []);
  }

  /// `{minutes} minutes spent being brave.`
  String storyMinutesBrave(int minutes) {
    return Intl.message(
      '$minutes minutes spent being brave.',
      name: 'storyMinutesBrave',
      desc: '',
      args: [minutes],
    );
  }

  /// `M`
  String get mon {
    return Intl.message('M', name: 'mon', desc: '', args: []);
  }

  /// `T`
  String get tue {
    return Intl.message('T', name: 'tue', desc: '', args: []);
  }

  /// `W`
  String get wed {
    return Intl.message('W', name: 'wed', desc: '', args: []);
  }

  /// `T`
  String get thu {
    return Intl.message('T', name: 'thu', desc: '', args: []);
  }

  /// `F`
  String get fri {
    return Intl.message('F', name: 'fri', desc: '', args: []);
  }

  /// `S`
  String get sat {
    return Intl.message('S', name: 'sat', desc: '', args: []);
  }

  /// `S`
  String get sun {
    return Intl.message('S', name: 'sun', desc: '', args: []);
  }

  /// `Long time. No worries — your progress is still here.`
  String get greetingLongTime {
    return Intl.message(
      'Long time. No worries — your progress is still here.',
      name: 'greetingLongTime',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back. Ready to start fresh today?`
  String get greetingFresh {
    return Intl.message(
      'Welcome back. Ready to start fresh today?',
      name: 'greetingFresh',
      desc: '',
      args: [],
    );
  }

  /// `Day {streak} — keep it going.`
  String greetingStreak(int streak) {
    return Intl.message(
      'Day $streak — keep it going.',
      name: 'greetingStreak',
      desc: '',
      args: [streak],
    );
  }

  /// `Today's Missions`
  String get todaysMissions {
    return Intl.message(
      'Today\'s Missions',
      name: 'todaysMissions',
      desc: '',
      args: [],
    );
  }

  /// `Three challenges. Any order. All count.`
  String get threeChallengesTodo {
    return Intl.message(
      'Three challenges. Any order. All count.',
      name: 'threeChallengesTodo',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Keep going`
  String get keepGoing {
    return Intl.message('Keep going', name: 'keepGoing', desc: '', args: []);
  }

  /// `Let's go`
  String get letsGoButton {
    return Intl.message('Let\'s go', name: 'letsGoButton', desc: '', args: []);
  }

  /// `About the App`
  String get aboutTheApp {
    return Intl.message(
      'About the App',
      name: 'aboutTheApp',
      desc: '',
      args: [],
    );
  }

  /// `Syntra is an innovative app that helps users overcome social challenges and achieve their goals.`
  String get aboutDescription {
    return Intl.message(
      'Syntra is an innovative app that helps users overcome social challenges and achieve their goals.',
      name: 'aboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Developer: SaMaili`
  String get developerLabel {
    return Intl.message(
      'Developer: SaMaili',
      name: 'developerLabel',
      desc: '',
      args: [],
    );
  }

  /// `GitHub: `
  String get githubLabel {
    return Intl.message('GitHub: ', name: 'githubLabel', desc: '', args: []);
  }

  /// `Could not open link`
  String get couldNotOpenLink {
    return Intl.message(
      'Could not open link',
      name: 'couldNotOpenLink',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 Syntra. All rights reserved.`
  String get allRightsReserved {
    return Intl.message(
      '© 2025 Syntra. All rights reserved.',
      name: 'allRightsReserved',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get filterAll {
    return Intl.message('All', name: 'filterAll', desc: '', args: []);
  }

  /// `Enable Notifications`
  String get enableNotifications {
    return Intl.message(
      'Enable Notifications',
      name: 'enableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `For the best experience`
  String get forBestExperience {
    return Intl.message(
      'For the best experience',
      name: 'forBestExperience',
      desc: '',
      args: [],
    );
  }

  /// `Syntra needs notification permissions to remind you about your challenges and deliver important updates.`
  String get notificationPermissionDesc {
    return Intl.message(
      'Syntra needs notification permissions to remind you about your challenges and deliver important updates.',
      name: 'notificationPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Basic Notifications`
  String get basicNotifications {
    return Intl.message(
      'Basic Notifications',
      name: 'basicNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Show reminder notifications`
  String get showReminderNotifications {
    return Intl.message(
      'Show reminder notifications',
      name: 'showReminderNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Exact Timing`
  String get exactTiming {
    return Intl.message(
      'Exact Timing',
      name: 'exactTiming',
      desc: '',
      args: [],
    );
  }

  /// `Deliver notifications at precise times`
  String get deliverAtPreciseTimes {
    return Intl.message(
      'Deliver notifications at precise times',
      name: 'deliverAtPreciseTimes',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `All Set!`
  String get allSet {
    return Intl.message('All Set!', name: 'allSet', desc: '', args: []);
  }

  /// `Skip for now`
  String get skipForNow {
    return Intl.message('Skip for now', name: 'skipForNow', desc: '', args: []);
  }

  /// `Want us to remind you?`
  String get wantReminders {
    return Intl.message(
      'Want us to remind you?',
      name: 'wantReminders',
      desc: '',
      args: [],
    );
  }

  /// `We'll send you one nudge a day — your choice when. No spam. You can turn it off any time in Settings.`
  String get reminderExplanation {
    return Intl.message(
      'We\'ll send you one nudge a day — your choice when. No spam. You can turn it off any time in Settings.',
      name: 'reminderExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Enable reminders`
  String get enableReminders {
    return Intl.message(
      'Enable reminders',
      name: 'enableReminders',
      desc: '',
      args: [],
    );
  }

  /// `I'll remember on my own →`
  String get rememberOnMyOwn {
    return Intl.message(
      'I\'ll remember on my own →',
      name: 'rememberOnMyOwn',
      desc: '',
      args: [],
    );
  }

  /// `Here's your first one.`
  String get heresYourFirst {
    return Intl.message(
      'Here\'s your first one.',
      name: 'heresYourFirst',
      desc: '',
      args: [],
    );
  }

  /// `It'll take about 2 minutes. Or save it for later.`
  String get firstChallengeDesc {
    return Intl.message(
      'It\'ll take about 2 minutes. Or save it for later.',
      name: 'firstChallengeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Start Now`
  String get startNow {
    return Intl.message('Start Now', name: 'startNow', desc: '', args: []);
  }

  /// `Do it later`
  String get doItLater {
    return Intl.message('Do it later', name: 'doItLater', desc: '', args: []);
  }

  /// `{days}-Day Streak!`
  String streakMilestoneTitle(int days) {
    return Intl.message(
      '$days-Day Streak!',
      name: 'streakMilestoneTitle',
      desc: '',
      args: [days],
    );
  }

  /// `Three days in a row. You're building a habit.`
  String get streakMilestone3 {
    return Intl.message(
      'Three days in a row. You\'re building a habit.',
      name: 'streakMilestone3',
      desc: '',
      args: [],
    );
  }

  /// `A full week! Your comfort zone just got bigger.`
  String get streakMilestone7 {
    return Intl.message(
      'A full week! Your comfort zone just got bigger.',
      name: 'streakMilestone7',
      desc: '',
      args: [],
    );
  }

  /// `Two weeks straight. You're not the same person you were 14 days ago.`
  String get streakMilestone14 {
    return Intl.message(
      'Two weeks straight. You\'re not the same person you were 14 days ago.',
      name: 'streakMilestone14',
      desc: '',
      args: [],
    );
  }

  /// `30 days. A whole month of showing up. That's rare. That's powerful.`
  String get streakMilestone30 {
    return Intl.message(
      '30 days. A whole month of showing up. That\'s rare. That\'s powerful.',
      name: 'streakMilestone30',
      desc: '',
      args: [],
    );
  }

  /// `60 days. Most people quit after a week. You didn't.`
  String get streakMilestone60 {
    return Intl.message(
      '60 days. Most people quit after a week. You didn\'t.',
      name: 'streakMilestone60',
      desc: '',
      args: [],
    );
  }

  /// `100 days. You've built something extraordinary. Respect.`
  String get streakMilestone100 {
    return Intl.message(
      '100 days. You\'ve built something extraordinary. Respect.',
      name: 'streakMilestone100',
      desc: '',
      args: [],
    );
  }

  /// `You've been showing up for {days} days. Keep going.`
  String streakMilestoneGeneric(int days) {
    return Intl.message(
      'You\'ve been showing up for $days days. Keep going.',
      name: 'streakMilestoneGeneric',
      desc: '',
      args: [days],
    );
  }

  /// `Keep it up`
  String get keepItUp {
    return Intl.message('Keep it up', name: 'keepItUp', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Social confidence is a skill.\nSkills can be trained.`
  String get onboarding1Headline {
    return Intl.message(
      'Social confidence is a skill.\nSkills can be trained.',
      name: 'onboarding1Headline',
      desc: '',
      args: [],
    );
  }

  /// `Syntra gives you small, real-world challenges to practice every day. No classes. No scripts. Just you, out in the world.`
  String get onboarding1Subtext {
    return Intl.message(
      'Syntra gives you small, real-world challenges to practice every day. No classes. No scripts. Just you, out in the world.',
      name: 'onboarding1Subtext',
      desc: '',
      args: [],
    );
  }

  /// `Let's see how it works →`
  String get onboarding1Button {
    return Intl.message(
      'Let\'s see how it works →',
      name: 'onboarding1Button',
      desc: '',
      args: [],
    );
  }

  /// `One challenge at a time.`
  String get onboarding2Headline {
    return Intl.message(
      'One challenge at a time.',
      name: 'onboarding2Headline',
      desc: '',
      args: [],
    );
  }

  /// `Each one is designed to push you just slightly past your comfort zone. You choose how hard to go.`
  String get onboarding2Subtext {
    return Intl.message(
      'Each one is designed to push you just slightly past your comfort zone. You choose how hard to go.',
      name: 'onboarding2Subtext',
      desc: '',
      args: [],
    );
  }

  /// `Pick a challenge`
  String get onboarding2Step1 {
    return Intl.message(
      'Pick a challenge',
      name: 'onboarding2Step1',
      desc: '',
      args: [],
    );
  }

  /// `Go do it — timer helps`
  String get onboarding2Step2 {
    return Intl.message(
      'Go do it — timer helps',
      name: 'onboarding2Step2',
      desc: '',
      args: [],
    );
  }

  /// `Log your result`
  String get onboarding2Step3 {
    return Intl.message(
      'Log your result',
      name: 'onboarding2Step3',
      desc: '',
      args: [],
    );
  }

  /// `Got it →`
  String get onboarding2Button {
    return Intl.message(
      'Got it →',
      name: 'onboarding2Button',
      desc: '',
      args: [],
    );
  }

  /// `It's okay to feel nervous.\nThat's kind of the point.`
  String get onboarding3Headline {
    return Intl.message(
      'It\'s okay to feel nervous.\nThat\'s kind of the point.',
      name: 'onboarding3Headline',
      desc: '',
      args: [],
    );
  }

  /// `Every challenge in this app is designed to be safe. Nothing extreme, nothing embarrassing. The awkward feeling you get is exactly what builds confidence over time.\n\nMost people feel it. Nobody dies from it.`
  String get onboarding3Subtext {
    return Intl.message(
      'Every challenge in this app is designed to be safe. Nothing extreme, nothing embarrassing. The awkward feeling you get is exactly what builds confidence over time.\n\nMost people feel it. Nobody dies from it.',
      name: 'onboarding3Subtext',
      desc: '',
      args: [],
    );
  }

  /// `I'm in →`
  String get onboarding3Button {
    return Intl.message(
      'I\'m in →',
      name: 'onboarding3Button',
      desc: '',
      args: [],
    );
  }

  /// `Where are you starting from?`
  String get onboarding4Headline {
    return Intl.message(
      'Where are you starting from?',
      name: 'onboarding4Headline',
      desc: '',
      args: [],
    );
  }

  /// `We'll show you challenges that fit where you are right now.`
  String get onboarding4Subtext {
    return Intl.message(
      'We\'ll show you challenges that fit where you are right now.',
      name: 'onboarding4Subtext',
      desc: '',
      args: [],
    );
  }

  /// `Just getting started`
  String get onboarding4Level1Title {
    return Intl.message(
      'Just getting started',
      name: 'onboarding4Level1Title',
      desc: '',
      args: [],
    );
  }

  /// `Social situations often feel uncomfortable`
  String get onboarding4Level1Subtitle {
    return Intl.message(
      'Social situations often feel uncomfortable',
      name: 'onboarding4Level1Subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Some experience`
  String get onboarding4Level2Title {
    return Intl.message(
      'Some experience',
      name: 'onboarding4Level2Title',
      desc: '',
      args: [],
    );
  }

  /// `I try, but sometimes freeze up`
  String get onboarding4Level2Subtitle {
    return Intl.message(
      'I try, but sometimes freeze up',
      name: 'onboarding4Level2Subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Ready to push harder`
  String get onboarding4Level3Title {
    return Intl.message(
      'Ready to push harder',
      name: 'onboarding4Level3Title',
      desc: '',
      args: [],
    );
  }

  /// `I want to level up, not start from scratch`
  String get onboarding4Level3Subtitle {
    return Intl.message(
      'I want to level up, not start from scratch',
      name: 'onboarding4Level3Subtitle',
      desc: '',
      args: [],
    );
  }

  /// `5 minutes a day is enough.`
  String get onboarding5Headline {
    return Intl.message(
      '5 minutes a day is enough.',
      name: 'onboarding5Headline',
      desc: '',
      args: [],
    );
  }

  /// `The science on habit formation says consistency matters more than intensity. One small thing, every day, changes your brain. Literally.`
  String get onboarding5Subtext {
    return Intl.message(
      'The science on habit formation says consistency matters more than intensity. One small thing, every day, changes your brain. Literally.',
      name: 'onboarding5Subtext',
      desc: '',
      args: [],
    );
  }

  /// `Set my reminder →`
  String get onboarding5Button {
    return Intl.message(
      'Set my reminder →',
      name: 'onboarding5Button',
      desc: '',
      args: [],
    );
  }

  /// `You just did something most people never try. That took guts.`
  String get coachMsg1 {
    return Intl.message(
      'You just did something most people never try. That took guts.',
      name: 'coachMsg1',
      desc: '',
      args: [],
    );
  }

  /// `Every time you do this it gets 1% easier. Seriously.`
  String get coachMsg2 {
    return Intl.message(
      'Every time you do this it gets 1% easier. Seriously.',
      name: 'coachMsg2',
      desc: '',
      args: [],
    );
  }

  /// `Your nervous system just learned you survived. That matters.`
  String get coachMsg3 {
    return Intl.message(
      'Your nervous system just learned you survived. That matters.',
      name: 'coachMsg3',
      desc: '',
      args: [],
    );
  }

  /// `Growth happens outside the comfort zone. You were just there.`
  String get coachMsg4 {
    return Intl.message(
      'Growth happens outside the comfort zone. You were just there.',
      name: 'coachMsg4',
      desc: '',
      args: [],
    );
  }

  /// `Awkward is just bravery wearing the wrong shoes. You showed up.`
  String get coachMsg5 {
    return Intl.message(
      'Awkward is just bravery wearing the wrong shoes. You showed up.',
      name: 'coachMsg5',
      desc: '',
      args: [],
    );
  }

  /// `One action at a time. You're building something real.`
  String get coachMsg6 {
    return Intl.message(
      'One action at a time. You\'re building something real.',
      name: 'coachMsg6',
      desc: '',
      args: [],
    );
  }

  /// `The version of you from six months ago would be proud.`
  String get coachMsg7 {
    return Intl.message(
      'The version of you from six months ago would be proud.',
      name: 'coachMsg7',
      desc: '',
      args: [],
    );
  }

  /// `That one was hard. Showing up and trying is the whole game.`
  String get failureCopy {
    return Intl.message(
      'That one was hard. Showing up and trying is the whole game.',
      name: 'failureCopy',
      desc: '',
      args: [],
    );
  }

  /// `What happened? What would you do differently? (Even writing one word is a win.)`
  String get failureNotesHint {
    return Intl.message(
      'What happened? What would you do differently? (Even writing one word is a win.)',
      name: 'failureNotesHint',
      desc: '',
      args: [],
    );
  }

  /// `Level {level} Unlocked!`
  String levelUnlocked(int level) {
    return Intl.message(
      'Level $level Unlocked!',
      name: 'levelUnlocked',
      desc: '',
      args: [level],
    );
  }

  /// `New challenges are now available in your catalog.`
  String get newChallengesAvailable {
    return Intl.message(
      'New challenges are now available in your catalog.',
      name: 'newChallengesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Confidence is attractive.`
  String get primingHeadlineFlirt {
    return Intl.message(
      'Confidence is attractive.',
      name: 'primingHeadlineFlirt',
      desc: '',
      args: [],
    );
  }

  /// `You're about to connect with someone real.`
  String get primingHeadlineGroup {
    return Intl.message(
      'You\'re about to connect with someone real.',
      name: 'primingHeadlineGroup',
      desc: '',
      args: [],
    );
  }

  /// `One small step. That's all this is.`
  String get primingHeadlineQuick {
    return Intl.message(
      'One small step. That\'s all this is.',
      name: 'primingHeadlineQuick',
      desc: '',
      args: [],
    );
  }

  /// `This one takes courage.\nYou have it.`
  String get primingHeadlineHard {
    return Intl.message(
      'This one takes courage.\nYou have it.',
      name: 'primingHeadlineHard',
      desc: '',
      args: [],
    );
  }

  /// `Take a breath.\nYou've got this.`
  String get primingHeadlineDefault {
    return Intl.message(
      'Take a breath.\nYou\'ve got this.',
      name: 'primingHeadlineDefault',
      desc: '',
      args: [],
    );
  }

  /// `Flirting is just playful communication. The outcome doesn't matter — showing up does.`
  String get primingSubFlirt {
    return Intl.message(
      'Flirting is just playful communication. The outcome doesn\'t matter — showing up does.',
      name: 'primingSubFlirt',
      desc: '',
      args: [],
    );
  }

  /// `Most people are friendlier than you expect. One interaction can shift your whole day.`
  String get primingSubGroup {
    return Intl.message(
      'Most people are friendlier than you expect. One interaction can shift your whole day.',
      name: 'primingSubGroup',
      desc: '',
      args: [],
    );
  }

  /// `Under a minute of action. The discomfort fades faster than you think.`
  String get primingSubQuick {
    return Intl.message(
      'Under a minute of action. The discomfort fades faster than you think.',
      name: 'primingSubQuick',
      desc: '',
      args: [],
    );
  }

  /// `The challenges that scare you most are the ones that grow you the most. This is one of those.`
  String get primingSubHard {
    return Intl.message(
      'The challenges that scare you most are the ones that grow you the most. This is one of those.',
      name: 'primingSubHard',
      desc: '',
      args: [],
    );
  }

  /// `Every time you do this, it gets a little easier. Your future self is already grateful.`
  String get primingSubDefault {
    return Intl.message(
      'Every time you do this, it gets a little easier. Your future self is already grateful.',
      name: 'primingSubDefault',
      desc: '',
      args: [],
    );
  }

  /// `I'm Ready`
  String get imReady {
    return Intl.message('I\'m Ready', name: 'imReady', desc: '', args: []);
  }

  /// `Set timer:`
  String get timerCustomLabel {
    return Intl.message(
      'Set timer:',
      name: 'timerCustomLabel',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get notNow {
    return Intl.message('Not now', name: 'notNow', desc: '', args: []);
  }

  /// `Comfort Zone`
  String get comfortZone {
    return Intl.message(
      'Comfort Zone',
      name: 'comfortZone',
      desc: '',
      args: [],
    );
  }

  /// `Growth Zone`
  String get growthZone {
    return Intl.message('Growth Zone', name: 'growthZone', desc: '', args: []);
  }

  /// `Bold Move`
  String get boldMove {
    return Intl.message('Bold Move', name: 'boldMove', desc: '', args: []);
  }

  /// `Details`
  String get detailsLabel {
    return Intl.message('Details', name: 'detailsLabel', desc: '', args: []);
  }

  /// `Less`
  String get lessLabel {
    return Intl.message('Less', name: 'lessLabel', desc: '', args: []);
  }

  /// `Comfort Zone Level`
  String get comfortZoneLevel {
    return Intl.message(
      'Comfort Zone Level',
      name: 'comfortZoneLevel',
      desc: '',
      args: [],
    );
  }

  /// `Level {level}`
  String levelN(int level) {
    return Intl.message(
      'Level $level',
      name: 'levelN',
      desc: '',
      args: [level],
    );
  }

  /// `{done} / {needed} completions to Level {next}`
  String completionsToLevel(int done, int needed, int next) {
    return Intl.message(
      '$done / $needed completions to Level $next',
      name: 'completionsToLevel',
      desc: '',
      args: [done, needed, next],
    );
  }

  /// `You've reached the top. Keep going.`
  String get reachedTheTop {
    return Intl.message(
      'You\'ve reached the top. Keep going.',
      name: 'reachedTheTop',
      desc: '',
      args: [],
    );
  }

  /// `Set difficulty manually`
  String get setDifficultyManually {
    return Intl.message(
      'Set difficulty manually',
      name: 'setDifficultyManually',
      desc: '',
      args: [],
    );
  }

  /// `Take a step back?`
  String get levelDownTitle {
    return Intl.message(
      'Take a step back?',
      name: 'levelDownTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can only level down manually — going back up requires grinding through completions again.`
  String get levelDownBody {
    return Intl.message(
      'You can only level down manually — going back up requires grinding through completions again.',
      name: 'levelDownBody',
      desc: '',
      args: [],
    );
  }

  /// `Yes, step back`
  String get levelDownConfirm {
    return Intl.message(
      'Yes, step back',
      name: 'levelDownConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Stay where I am`
  String get levelDownCancel {
    return Intl.message(
      'Stay where I am',
      name: 'levelDownCancel',
      desc: '',
      args: [],
    );
  }

  /// `Challenge Information`
  String get challengeInformation {
    return Intl.message(
      'Challenge Information',
      name: 'challengeInformation',
      desc: '',
      args: [],
    );
  }

  /// `All permissions granted successfully!`
  String get allPermissionsGranted {
    return Intl.message(
      'All permissions granted successfully!',
      name: 'allPermissionsGranted',
      desc: '',
      args: [],
    );
  }

  /// `Some permissions are still missing. Please enable them manually.`
  String get somePermissionsMissing {
    return Intl.message(
      'Some permissions are still missing. Please enable them manually.',
      name: 'somePermissionsMissing',
      desc: '',
      args: [],
    );
  }

  /// `💘 Flirt challenges focus on playful, social interactions to build romantic confidence.`
  String get flirtTagExplanation {
    return Intl.message(
      '💘 Flirt challenges focus on playful, social interactions to build romantic confidence.',
      name: 'flirtTagExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Coop`
  String get coop {
    return Intl.message('Coop', name: 'coop', desc: '', args: []);
  }

  /// `Dare`
  String get dare {
    return Intl.message('Dare', name: 'dare', desc: '', args: []);
  }

  /// `Filters`
  String get filterTitle {
    return Intl.message('Filters', name: 'filterTitle', desc: '', args: []);
  }

  /// `Reset`
  String get filterReset {
    return Intl.message('Reset', name: 'filterReset', desc: '', args: []);
  }

  /// `Challenge Type`
  String get filterTypeLabel {
    return Intl.message(
      'Challenge Type',
      name: 'filterTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get filterEnvLabel {
    return Intl.message('Location', name: 'filterEnvLabel', desc: '', args: []);
  }

  /// `Flirt challenges`
  String get filterFlirtLabel {
    return Intl.message(
      'Flirt challenges',
      name: 'filterFlirtLabel',
      desc: '',
      args: [],
    );
  }

  /// `Flirt only`
  String get filterFlirtOnly {
    return Intl.message(
      'Flirt only',
      name: 'filterFlirtOnly',
      desc: '',
      args: [],
    );
  }

  /// `No flirt`
  String get filterFlirtExclude {
    return Intl.message(
      'No flirt',
      name: 'filterFlirtExclude',
      desc: '',
      args: [],
    );
  }

  /// `Only show new challenges`
  String get filterNewOnly {
    return Intl.message(
      'Only show new challenges',
      name: 'filterNewOnly',
      desc: '',
      args: [],
    );
  }

  /// `Hide challenges you've already completed`
  String get filterNewOnlySubtitle {
    return Intl.message(
      'Hide challenges you\'ve already completed',
      name: 'filterNewOnlySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get filterSortBy {
    return Intl.message('Sort by', name: 'filterSortBy', desc: '', args: []);
  }

  /// `Popular`
  String get filterSortPopular {
    return Intl.message(
      'Popular',
      name: 'filterSortPopular',
      desc: '',
      args: [],
    );
  }

  /// `Easiest first`
  String get filterSortEasiest {
    return Intl.message(
      'Easiest first',
      name: 'filterSortEasiest',
      desc: '',
      args: [],
    );
  }

  /// `Give me one!`
  String get giveMeOneTooltip {
    return Intl.message(
      'Give me one!',
      name: 'giveMeOneTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Badges`
  String get badgesTitle {
    return Intl.message('Badges', name: 'badgesTitle', desc: '', args: []);
  }

  /// `Keep going to unlock more!`
  String get badgesLocked {
    return Intl.message(
      'Keep going to unlock more!',
      name: 'badgesLocked',
      desc: '',
      args: [],
    );
  }

  /// `First Step`
  String get badgeFirstStep {
    return Intl.message(
      'First Step',
      name: 'badgeFirstStep',
      desc: '',
      args: [],
    );
  }

  /// `10 Challenges`
  String get badgeTenChallenges {
    return Intl.message(
      '10 Challenges',
      name: 'badgeTenChallenges',
      desc: '',
      args: [],
    );
  }

  /// `50 Challenges`
  String get badgeFiftyChallenges {
    return Intl.message(
      '50 Challenges',
      name: 'badgeFiftyChallenges',
      desc: '',
      args: [],
    );
  }

  /// `3-Day Streak`
  String get badgeThreeDayStreak {
    return Intl.message(
      '3-Day Streak',
      name: 'badgeThreeDayStreak',
      desc: '',
      args: [],
    );
  }

  /// `7-Day Streak`
  String get badgeSevenDayStreak {
    return Intl.message(
      '7-Day Streak',
      name: 'badgeSevenDayStreak',
      desc: '',
      args: [],
    );
  }

  /// `100 XP Club`
  String get badgeCenturyXp {
    return Intl.message(
      '100 XP Club',
      name: 'badgeCenturyXp',
      desc: '',
      args: [],
    );
  }

  /// `500 XP Legend`
  String get badgeFiveHundredXp {
    return Intl.message(
      '500 XP Legend',
      name: 'badgeFiveHundredXp',
      desc: '',
      args: [],
    );
  }

  /// `60 Min. Brave`
  String get badgeBraveMinutes {
    return Intl.message(
      '60 Min. Brave',
      name: 'badgeBraveMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Goal`
  String get weeklyGoalTitle {
    return Intl.message(
      'Weekly Goal',
      name: 'weeklyGoalTitle',
      desc: '',
      args: [],
    );
  }

  /// `{done} of {goal} challenges this week`
  String weeklyGoalProgress(int done, int goal) {
    return Intl.message(
      '$done of $goal challenges this week',
      name: 'weeklyGoalProgress',
      desc: '',
      args: [done, goal],
    );
  }

  /// `Set goal:`
  String get weeklyGoalSetLabel {
    return Intl.message(
      'Set goal:',
      name: 'weeklyGoalSetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Recap`
  String get weeklyRecapTitle {
    return Intl.message(
      'Weekly Recap',
      name: 'weeklyRecapTitle',
      desc: '',
      args: [],
    );
  }

  /// `This week you completed {n} challenges. Keep up the great work!`
  String weeklyRecapBody(int n) {
    return Intl.message(
      'This week you completed $n challenges. Keep up the great work!',
      name: 'weeklyRecapBody',
      desc: '',
      args: [n],
    );
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
