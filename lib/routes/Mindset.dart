import 'package:flutter/material.dart';

import '../static.dart';

class Mindset extends StatelessWidget {
  const Mindset({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Mindset & Growth',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppStatic.grape,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Your mindset shapes your reality. Embrace growth, courage, and positivity every day!',
              style: TextStyle(
                fontSize: 16,
                color: AppStatic.textPrimary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppStatic.grapeLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppStatic.grape.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology_alt, color: AppStatic.grape, size: 54),
                  SizedBox(height: 18),
                  ..._buildGuidelinesList(),
                  SizedBox(height: 10),
                  Divider(
                    thickness: 1,
                    color: AppStatic.grape.withOpacity(0.2),
                  ),
                  SizedBox(height: 10),
                  _buildGuideline(
                    'That\'s it. Now go out & speak up!',
                    null,
                    true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppStatic.marianBlueLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppStatic.marianBlue.withOpacity(0.08),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: AppStatic.marianBlue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mindset Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStatic.marianBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ..._buildTipsList(),
                ],
              ),
            ),
            SizedBox(height: 32),
            _MotivationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppStatic.marianBlue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 14, color: AppStatic.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(
    String text, [
    String? description,
    bool isFinal = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppStatic.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppStatic.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (isFinal) SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildGuidelinesList() {
    return [
      _buildGuideline(
        'Everyone has received an upbringing – even if they are not happy, they react politely.',
        'What matters is THAT you do it, not how they react.',
      ),
      _buildGuideline(
        'You are not trying to sell anything. People often enjoy being approached.',
        'Be glad that YOU are the brave one. Let others feel that.',
      ),
      _buildGuideline('Focus: be social, not dating.'),
      _buildGuideline(
        'Only 1 joker per person.',
        'Look ONCE: attractive? Think briefly.\nOn the SECOND look you must approach. No excuses.',
      ),
      _buildGuideline(
        'The world is too small for emo mode.',
        'Be the sun. Pure social energy. Unshakable self-confidence.',
      ),
      _buildGuideline(
        'Looks don\'t matter.',
        'Many make excuses: "Not my type."\nTalk anyway. You never know what will happen.',
      ),
      _buildGuideline(
        'Nervous? Perfect!',
        'That\'s your guarantee for a good feeling afterwards – no matter if it works out.\nNot the goal: to get rid of the feeling.\nGoal: change your mindset & build a social life.\nCollect interactions like Pokémon.',
      ),
    ];
  }

  List<Widget> _buildTipsList() {
    final tips = [
      'Embrace challenges as opportunities',
      'Focus on progress, not perfection',
      'Celebrate small wins daily',
      'Learn from setbacks',
      'Stay curious and open-minded',
    ];
    return tips.map(_buildTipItem).toList();
  }
}

class _MotivationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: AppStatic.grapeDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            Icon(Icons.format_quote, color: AppStatic.white, size: 32),
            SizedBox(height: 10),
            Text(
              '“The only limit to our realization of tomorrow will be our doubts of today.”',
              style: TextStyle(
                color: AppStatic.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStatic.marianBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () {
                // TODO: Implement new motivation quote
              },
              child: Text(
                'Get New Motivation',
                style: TextStyle(fontSize: 16, color: AppStatic.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
