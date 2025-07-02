import 'package:flutter/material.dart';

import '../static.dart';

class Mindset extends StatelessWidget {
  const Mindset({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Mindset & Growth',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppStatic.grape,
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStatic.grapeLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.psychology_alt, color: AppStatic.grape, size: 48),
                  SizedBox(height: 24),
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
                  SizedBox(height: 16),
                  _buildGuideline('That\'s it. Now go out & speak up!'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppStatic.marianBlueLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Mindset Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppStatic.marianBlue,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildTipItem('Embrace challenges as opportunities'),
                  _buildTipItem('Focus on progress, not perfection'),
                  _buildTipItem('Celebrate small wins daily'),
                  _buildTipItem('Learn from setbacks'),
                  _buildTipItem('Stay curious and open-minded'),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStatic.grapeDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                // TODO: Implement new motivation quote
              },
              child: Text(
                'Get New Motivation',
                style: TextStyle(fontSize: 18, color: AppStatic.white),
              ),
            ),
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
}
