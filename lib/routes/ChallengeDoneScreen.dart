// ChallengeDoneScreen.dart
// This file defines the ChallengeDoneScreen widget, which displays the result of a completed or aborted challenge.
// It separates UI and logic, and includes a feedback survey for the user.

import 'package:flutter/material.dart';

import '../Challenge.dart';
import '../database/challenge_database.dart';

// Main screen shown after a challenge is completed or aborted.
class ChallengeDoneScreen extends StatelessWidget {
  final Challenge challenge;
  final double rewardFactor;
  final ValueChanged<double>? onDone;
  final GlobalKey<_SurveyWidgetState> _surveyKey;

  ChallengeDoneScreen({
    super.key,
    required this.challenge,
    this.rewardFactor = 1.0,
    this.onDone,
  }) : _surveyKey = GlobalKey<_SurveyWidgetState>();

  @override
  Widget build(BuildContext context) {
    // Use logic class to determine UI state
    final ChallengeDoneScreenLogic logic = ChallengeDoneScreenLogic(
      rewardFactor,
    );
    final isAborted = logic.isAborted;
    final title = logic.title;
    final icon = logic.icon;
    final iconColor = logic.iconColor;
    final message = logic.message;
    final xpColor = logic.xpColor;
    final encouragement = logic.encouragement;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final encouragementColor = isDark ? Colors.greenAccent : Colors.green;
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon and message for challenge result
                  Icon(icon, color: iconColor, size: 80),
                  SizedBox(height: 24),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  // XP/Aura reward display
                  Text(
                    '${(challenge.xp * rewardFactor).round() >= 0 ? '+' : ''}${(challenge.xp * rewardFactor).round()} Aura',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: xpColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Feedback survey (only if not aborted)
                  if (!isAborted) _SurveyWidget(key: _surveyKey),
                  Text(
                    encouragement,
                    style: TextStyle(fontSize: 18, color: encouragementColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 80), // Space for Floating Button
                ],
              ),
            ),
          ),
          // Button to return to home and save logbook entry
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 4,
                ),
                icon: Icon(Icons.home, size: 28),
                label: Text('Back to Home'),
                onPressed: () async {
                  // Collect survey results if available
                  final surveyState = _surveyKey.currentState;
                  int? feeling;
                  int? perception;
                  String? notes;
                  if (surveyState != null) {
                    if (!surveyState.submitted) surveyState.submit();
                    feeling = surveyState.feeling;
                    perception = surveyState.perceived;
                    notes = surveyState.notes;
                  } else {
                    feeling = null;
                    perception = null;
                    notes = null;
                  }
                  // Save logbook entry
                  await ChallengeDatabase.instance.addLogbookEntry({
                    'user_id': null, // TODO: adjust if user IDs are used
                    'challenge_id': challenge.id,
                    'earned': (challenge.xp * rewardFactor).round(),
                    'timestamp': DateTime.now().toIso8601String(),
                    'status': rewardFactor < 0 ? 'failed' : 'success',
                    'feeling': feeling,
                    'perception': perception,
                    'notes': notes,
                  });
                  if (onDone != null) {
                    onDone!(rewardFactor); // Score-Update Callback
                  }
                  Navigator.of(context).pop(rewardFactor); // Return result
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Logic class for ChallengeDoneScreen: determines UI state based on rewardFactor
class ChallengeDoneScreenLogic {
  final double rewardFactor;

  ChallengeDoneScreenLogic(this.rewardFactor);

  bool get isAborted => rewardFactor < 0;

  String get title => isAborted ? 'Challenge aborted' : 'Challenge completed!';

  IconData get icon =>
      isAborted ? Icons.sentiment_dissatisfied : Icons.emoji_events;

  Color get iconColor => isAborted ? Colors.red : Colors.green;

  String get message => isAborted
      ? 'Too bad! You aborted the challenge.'
      : 'Congratulations! You completed the challenge.';

  Color get xpColor => isAborted ? Colors.red : Colors.green;

  String get encouragement =>
      isAborted ? 'Try again next time!' : 'Well done! Keep it up!';
}

// Widget for user feedback survey after challenge
class _SurveyWidget extends StatefulWidget {
  const _SurveyWidget({super.key});

  @override
  State<_SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<_SurveyWidget> {
  // User's self-reported feeling (0-4, default neutral)
  int _feeling = 2;

  // User's perceived impression (0-4, default neutral)
  int _perceived = 2;

  // Whether the survey has been submitted
  bool _submitted = false;

  // Controller for notes text field
  final TextEditingController _notesController = TextEditingController();

  // Icons and colors for smiley ratings
  final List<IconData> _smileys = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  final List<Color> _smileyColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    if (_submitted) {
      // Thank you message after submission
      return Column(
        children: [
          Text(
            'Thank you for your feedback!',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
          SizedBox(height: 16),
        ],
      );
    }
    // Survey UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did you feel?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                _smileys[i],
                color: _feeling == i ? _smileyColors[i] : Colors.grey,
                size: 36,
              ),
              onPressed: () {
                setState(() => _feeling = i);
              },
              tooltip: ["Very bad", "Bad", "Neutral", "Good", "Very good"][i],
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'How do you think you were perceived?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                _smileys[i],
                color: _perceived == i ? _smileyColors[i] : Colors.grey,
                size: 36,
              ),
              onPressed: () {
                setState(() => _perceived = i);
              },
              tooltip: [
                "Very negative",
                "Negative",
                "Neutral",
                "Positive",
                "Very positive",
              ][i],
            ),
          ),
        ),
        SizedBox(height: 20),
        Text('Notes:', style: TextStyle(fontSize: 16, color: textColor)),
        SizedBox(height: 4),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Your thoughts, observations, ...',
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Getters for survey results
  bool get submitted => _submitted;

  int get feeling => _feeling;

  int get perceived => _perceived;

  String get notes => _notesController.text;

  // Mark survey as submitted
  void submit() {
    setState(() => _submitted = true);
  }
}
