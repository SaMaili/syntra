// ChallengesScreenLogic.dart
// Contains business logic and state management for ChallengesScreen
// All variable and method names are in English, with comments for clarity.
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';

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

  /// Shuffles the cards and resets the swiper controller
  void shuffleCards(dynamic cardSwiperController) {
    shuffleChallenges();
    // Reset the controller to show the shuffled cards
    if (cardSwiperController != null) {
      try {
        cardSwiperController.moveTo(0);
      } catch (e) {
        // Handle any controller errors gracefully
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final accentColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            width: 320,
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                        Colors.grey[900]!,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                        Colors.white,
                      ],
                    ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.2),
                          primaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      color: primaryColor,
                      size: 48,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Title
                  Text(
                    S.of(context).challengeConfirmTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16),

                  // Challenge name in a styled container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      challengeTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action buttons
                  Column(
                    children: [
                      // "Let's Go" button - primary action
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 26,
                          ),
                          label: Text(
                            S.of(context).letsGo,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // "Prefer another" button - secondary action
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: Icon(
                            Icons.shuffle,
                            color: Colors.grey[600],
                            size: 13,
                          ),
                          label: Text(
                            S.of(context).preferAnotherChallenge,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  /// Handles card swipe events
  bool onSwipe(int? previousIndex, int? currentIndex, dynamic direction,
      BuildContext context, List<dynamic> filteredCards) {
    // Handle swipe logic here
    if (previousIndex != null && filteredCards.isNotEmpty && previousIndex < filteredCards.length) {
      // Play sound effect for right swipe (challenge accepted)
      if (direction.toString().contains('right')) {
        playSwipeSound();

        // You can add additional logic here for when a challenge is accepted
        // For example, show a confirmation dialog or navigate to challenge screen

        print('Challenge accepted: ${filteredCards[previousIndex]}');
      } else if (direction.toString().contains('left')) {
        // Handle left swipe (challenge rejected)
        print('Challenge rejected: ${filteredCards[previousIndex]}');
      }
    }
    return true; // Allow the swipe
  }

  /// Handles undo events
  bool onUndo(int? previousIndex, int? currentIndex, dynamic direction) {
    // Handle undo logic here
    print('Undo swipe - Previous: $previousIndex, Current: $currentIndex, Direction: $direction');
    return true; // Allow the undo
  }
}
