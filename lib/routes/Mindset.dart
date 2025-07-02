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
                    'Jeder hat Erziehung genossen – selbst wenn sie sich nicht freuen, reagieren sie höflich.',
                    'Es zählt, DASS du es tust, nicht wie sie reagieren.',
                  ),
                  _buildGuideline(
                    'Du willst nichts verkaufen. Menschen genießen es oft, angesprochen zu werden.',
                    'Sei froh, dass DU der Mutige bist. Lass andere das spüren.',
                  ),
                  _buildGuideline('Fokus: sozial sein, nicht daten.'),
                  _buildGuideline(
                    'Nur 1 Joker pro Person.',
                    'Schau EINMAL: hübsch? Überleg kurz.\nBeim ZWEITEN Blick musst du sie ansprechen. Keine Ausrede.',
                  ),
                  _buildGuideline(
                    'Die Welt ist zu klein für Emo-Modus.',
                    'Sei die Sonne. Pure soziale Energie. Unerschütterliches Selbstvertrauen.',
                  ),
                  _buildGuideline(
                    'Aussehen egal.',
                    'Viele reden sich raus: „Nicht mein Typ.“\nRede trotzdem. Du weißt nie, was daraus wird.',
                  ),
                  _buildGuideline(
                    'Nervosität? Perfekt!',
                    'Das ist dein Garant fürs gute Gefühl danach – egal ob’s klappt.\nNicht Ziel: das Gefühl loswerden.\nZiel: dein Mindset ändern & ein soziales Leben aufbauen.\nSammle Interaktionen wie Pokémon.',
                  ),
                  SizedBox(height: 16),
                  _buildGuideline('Das war’s. Jetzt raus & Mund auf!'),
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
