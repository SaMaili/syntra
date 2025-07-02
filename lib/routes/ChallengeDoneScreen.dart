import 'package:flutter/material.dart';

import '../Challenge.dart';
import '../database/challenge_database.dart';

class ChallengeDoneScreen extends StatelessWidget {
  final Challenge challenge;
  final double rewardFactor;
  final ValueChanged<double>? onDone;

  const ChallengeDoneScreen({
    super.key,
    required this.challenge,
    this.rewardFactor = 1.0,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isAborted = rewardFactor < 0;
    final title = isAborted
        ? 'Challenge aborted'
        : 'Challenge completed!';
    final icon = isAborted ? Icons.sentiment_dissatisfied : Icons.emoji_events;
    final iconColor = isAborted ? Colors.red : Colors.green;
    final message = isAborted
        ? 'Too bad! You aborted the challenge.'
        : 'Congratulations! You completed the challenge.';
    final xpColor = isAborted ? Colors.red : Colors.green;
    final encouragement = isAborted
        ? 'Try again next time!'
        : 'Well done! Keep it up!';

    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 80),
                  SizedBox(height: 24),
                  Text(
                    message,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Text(
                    '${(challenge.xp * rewardFactor).round() >= 0 ? '+' : ''}${(challenge.xp * rewardFactor).round()} Aura',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: xpColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (!isAborted) _SurveyWidget(),
                  Text(
                    encouragement,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 80), // Space for Floating Button
                ],
              ),
            ),
          ),
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
                  final surveyState = _SurveyWidget.of(context);
                  int? feeling;
                  int? perception;
                  String? notes;
                  if (surveyState != null) {
                    feeling = surveyState.feeling;
                    perception = surveyState.perceived;
                    notes = surveyState.notes;
                    if (!surveyState.submitted) surveyState.submit();
                    // Korrigiere: Wenn Werte nicht gesetzt wurden, auf null setzen
                    if (feeling == null || feeling < 0 || feeling > 4) feeling = null;
                    if (perception == null || perception < 0 || perception > 4) perception = null;
                    if (notes != null && notes.trim().isEmpty) notes = null;
                  } else {
                    feeling = null;
                    perception = null;
                    notes = null;
                  }

                  await ChallengeDatabase.instance.addLogbookEntry({
                    'user_id': null,
                    // TODO adjust if user IDs are used
                    'challenge_id': challenge.id,
                    'earned': (challenge.xp * rewardFactor).round(),
                    'timestamp': DateTime.now().toIso8601String(),
                    'status': rewardFactor < 0 ? 'failed' : 'success',
                    'feeling': feeling,
                    'perception': perception,
                    'notes': notes,
                  });
                  print(
                    'Challenge added to logbook: ${challenge.title}',
                  );
                  if (onDone != null)
                    onDone!(rewardFactor); // <-- Score-Update Callback
                  Navigator.of(context).pop(
                    rewardFactor,
                  ); // Return result to previous screen
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyWidget extends StatefulWidget {
  @override
  State<_SurveyWidget> createState() => _SurveyWidgetState();

  static _SurveyWidgetState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<_SurveyWidgetState>();
    return state;
  }
}

class _SurveyWidgetState extends State<_SurveyWidget> {
  // if feeling or perceived is 5, the user has not selected an option
  int _feeling = 2; // Default neutral
  int _perceived = 2; // Default neutral
  bool _submitted = false;
  final TextEditingController _notesController = TextEditingController();

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
    if (_submitted) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did you feel?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: () => setState(() => _feeling = i),
              tooltip: [
                "Very bad",
                "Bad",
                "Neutral",
                "Good",
                "Very good",
              ][i],
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'How do you think you were perceived?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              onPressed: () => setState(() => _perceived = i),
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
        Text('Notes:', style: TextStyle(fontSize: 16)),
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

  bool get submitted => _submitted;

  int get feeling => _feeling;

  int get perceived => _perceived;

  String get notes => _notesController.text;

  void submit() {
    setState(() => _submitted = true);
  }
}
