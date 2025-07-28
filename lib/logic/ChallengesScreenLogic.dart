// ChallengesScreenLogic.dart
// Contains business logic and state management for ChallengesScreen
// All variable and method names are in English, with comments for clarity.
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../static.dart';
import '../widgets/ChallengeCard.dart';
import '../generated/l10n.dart';

// IM SO SORRY FOR THE MESSY CODE, I KNOW IT'S NOT THE BEST PRACTICE TO HAVE ALL THIS IN ONE FILE, BUT I HAD TO DO IT FOR THE CHALLENGE SCREEN LOGIC. I'LL TRY TO IMPROVE IT LATER!
// YOU KNOW THAT'S A LIE, I JUST WANTED TO GET IT DONE QUICKLY AND MOVE ON TO THE NEXT TASK. I'LL CLEAN IT UP WHEN I HAVE MORE TIME!
// I HAVE BEEN VIBE CODING FOR TOO LONG, I NEED TO GET BACK TO WORK AND FINISH THIS APP!
// EVEN THESE COMMENTS ARE AI GENERATED, I JUST WANTED TO MAKE IT LOOK LIKE I'M DOING SOMETHING HERE! :(

/// Singleton to hold session state for the challenge screen (e.g., current card index, toggle selection)
class ChallengeSessionState {
  static final ChallengeSessionState _instance =
      ChallengeSessionState._internal();

  factory ChallengeSessionState() => _instance;

  ChallengeSessionState._internal();

  int currentCardIndex = 0; // Index of the currently displayed card
  int selectedToggle = 0; // 0 = Solo, 1 = Group
}

/// Handles business logic and state for ChallengesScreen
class ChallengesScreenLogic {
  final ChallengeSessionState session = ChallengeSessionState();
  int score = 0; // User's score for today

  /// Returns a list of solo challenge cards
  List<ChallengeCard> get soloCards => AppStatic.CHALLENGES
      .where((challenge) => challenge.type != 'group')
      .map((challenge) => ChallengeCard(challenge: challenge))
      .toList();

  /// Returns a list of group challenge cards
  List<ChallengeCard> get groupCards => AppStatic.CHALLENGES
      .where((challenge) => challenge.type == 'group')
      .map((challenge) => ChallengeCard(challenge: challenge))
      .toList();

  /// Returns the filtered list of cards based on the toggle selection
  List<ChallengeCard> getFilteredCards() {
    return session.selectedToggle == 1 ? groupCards : soloCards;
  }

  /// Shuffles the list of challenges (affects the global static list)
  void shuffleChallenges() {
    AppStatic.CHALLENGES.shuffle();
  }

  /// Plays a sound when a card is swiped right
  Future<void> playSwipeSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('ding-126626.mp3'));
  }

  /// Shows a dialog to confirm the selected challenge
  /// Returns true if the user confirms, false if they cancel
  Future<bool?> showChallengeDialog(
    BuildContext context,
    String challengeTitle,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).challengeConfirmTitle),
        content: Text(S.of(context).challengeConfirmMessage(challengeTitle)),
        actions: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: Text(S.of(context).preferAnotherChallenge),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  child: Text(S.of(context).letsGo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
