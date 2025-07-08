// ChallengesScreen.dart
// This file defines the ChallengesScreen widget, which displays and manages the challenge cards UI.
// Imports necessary packages and logic for challenge management.

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:syntra/logic/StatisticsLogic.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../main.dart';
import '../logic/ChallengesScreenLogic.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import 'ActiveChallengeScreen.dart';
import 'ChallengeDoneScreen.dart';
import 'StatisticsScreen.dart';

// Container for statistics overview (used to fetch today's score)
final statsContainer = StatsOverviewContainer();

// List of all challenge cards (used for initial display)
final List<ChallengeCard> cards = AppStatic.CHALLENGES
    .map((challenge) => ChallengeCard(challenge: challenge))
    .toList();

// Singleton for session state (current card index, toggle selection)
class ChallengeSessionState {
  static final ChallengeSessionState _instance =
      ChallengeSessionState._internal();

  factory ChallengeSessionState() => _instance;

  ChallengeSessionState._internal();

  int currentCardIndex = 0; // Index of the currently displayed card
  int selectedToggle = 0; // 0 = Solo, 1 = Group
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with RouteAware {
  static int staticCardIndex = 0;
  final CardSwiperController _cardSwiperController = CardSwiperController();
  DateTime? lastScoreDate;
  final ChallengesScreenLogic logic = ChallengesScreenLogic();

  @override
  void initState() {
    super.initState();
    _initializeScore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _initializeScore();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _initializeScore();
  }

  Future<void> _initializeScore() async {
    // Use the StatisticsScreenLogic to fetch today's XP
    int todayScore = await StatisticsLogic().fetchTotalXp();
    setState(() {
      logic.score = todayScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCards = logic.getFilteredCards();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final scoreBoxColor = isDark ? Colors.grey[900] : Colors.amber[50];
    final scoreTextColor = isDark ? Colors.amber[200] : Colors.amber[800];
    final scoreValueColor = isDark ? Colors.amberAccent : Colors.amber[900];
    final shuffleIconColor = isDark ? Colors.pinkAccent : Colors.deepPurple[400];
    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: bgGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 18),
              ToggleSwitch(
                minWidth: 100.0,
                minHeight: 32.0,
                initialLabelIndex: logic.session.selectedToggle,
                cornerRadius: 24.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey[300],
                inactiveFgColor: Colors.deepPurple[400],
                totalSwitches: 2,
                icons: [Icons.person, Icons.group],
                iconSize: 20.0,
                borderWidth: 2.0,
                borderColor: [Colors.deepPurple[100]!],
                labels: ['Solo', 'Group'],
                activeBgColors: [
                  [Colors.deepPurpleAccent],
                  [Colors.pinkAccent],
                ],
                onToggle: (index) {
                  setState(() {
                    logic.session.selectedToggle = index!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: scoreBoxColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.amber : Colors.amber).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Score:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: scoreTextColor,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.amber[900] : Colors.amber[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Text(
                          logic.score.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scoreValueColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Tooltip(
                        message: 'shuffle challenges',
                        child: IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: shuffleIconColor,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              logic.shuffleChallenges();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Challenges shuffled!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredCards.isEmpty
                    ? Center(
                        child: Text(
                          'No challenges found',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDark ? Colors.deepPurple[100] : Colors.deepPurple[300],
                          ),
                        ),
                      )
                    : CardSwiper(
                        controller: _cardSwiperController,
                        cardsCount: filteredCards.length,
                        initialIndex: staticCardIndex,
                        allowedSwipeDirection: AllowedSwipeDirection.symmetric(
                          horizontal: true,
                        ),
                        cardBuilder:
                            (
                              context,
                              index,
                              percentThresholdX,
                              percentThresholdY,
                            ) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(
                                        isDark ? 0.18 : 0.08,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: filteredCards[index],
                              );
                            },
                        onSwipe: (previousIndex, newIndex, direction) async {
                          // Called when a card is swiped.
                          // If swiped right, play sound, show dialog, and possibly start challenge.
                          if (direction == CardSwiperDirection.right) {
                            await logic.playSwipeSound();
                            bool? completed = await logic.showChallengeDialog(
                              context,
                              filteredCards[previousIndex].challenge.title,
                            );
                            if (completed == true) {
                              // If user confirms, navigate to ActiveChallengeScreen.
                              final result = await Navigator.of(context)
                                  .push<double>(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ActiveChallengeScreen(
                                            challenge:
                                                filteredCards[previousIndex]
                                                    .challenge,
                                          ),
                                    ),
                                  );
                              if (result != null) {
                                // After challenge, show ChallengeDoneScreen and update score.
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChallengeDoneScreen(
                                      challenge: filteredCards[previousIndex]
                                          .challenge,
                                      rewardFactor: result,
                                      onDone: (double rewardFactor) async {},
                                    ),
                                  ),
                                );
                                await _initializeScore();
                                // Show snackbar when challenge is completed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Challenge completed!'),
                                  ),
                                );
                              }
                            } else {
                              // If user cancels, undo the swipe.
                              _cardSwiperController.undo();
                            }
                          }
                          // Update the static card index after swipe.
                          setState(() {
                            if (newIndex != null) staticCardIndex = newIndex;
                          });
                          return true;
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
