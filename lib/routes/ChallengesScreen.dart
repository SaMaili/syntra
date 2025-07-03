import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../main.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import 'ActiveChallengeScreen.dart';
import 'ChallengeDoneScreen.dart';
import 'StatisticsScreen.dart';

final statsContainer = StatsOverviewContainer();

final List<ChallengeCard> cards = AppStatic.CHALLENGES
    .map((challenge) => ChallengeCard(challenge: challenge))
    .toList();

// Singleton für Session-State
class ChallengeSessionState {
  static final ChallengeSessionState _instance =
      ChallengeSessionState._internal();

  factory ChallengeSessionState() => _instance;

  ChallengeSessionState._internal();

  int currentCardIndex = 0;
  int selectedToggle = 0;
}

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with RouteAware {
  static int staticCardIndex =
      0; // Statisch gespeicherter Index der obersten Karte
  int score = 0;
  final CardSwiperController _cardSwiperController = CardSwiperController();
  DateTime? lastScoreDate;

  // Zugriff auf Session-State
  ChallengeSessionState session = ChallengeSessionState();

  List<ChallengeCard> get _soloCards => AppStatic.CHALLENGES
      .where((challenge) => challenge.type != 'group')
      .map((challenge) => ChallengeCard(challenge: challenge))
      .toList();

  List<ChallengeCard> get _groupCards => AppStatic.CHALLENGES
      .where((challenge) => challenge.type == 'group')
      .map((challenge) => ChallengeCard(challenge: challenge))
      .toList();

  List<ChallengeCard> get filteredCards =>
      session.selectedToggle == 1 ? _groupCards : _soloCards;

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
    int todayScore = await statsContainer.fetchTotalXpToday();
    setState(() {
      score = todayScore;
    });
  }

  Widget buildChallengeDialog(String challengeTitle) {
    return AlertDialog(
      title: Text('Notiz'),
      content: Text('Du hast dich für "$challengeTitle" entschieden. Bereit?'),
      actions: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: Text('🙈 Doch lieber eine andere?'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
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
                child: Text('Los geht\'s!'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStatic.grapeLight,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                initialLabelIndex: session.selectedToggle,
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
                    session.selectedToggle = index!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
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
                      Text(
                        'Score heute:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Text(
                          score.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: filteredCards.isEmpty
                    ? Center(
                        child: Text(
                          'Keine Challenges gefunden',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurple[300],
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
                                        0.08,
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
                          print(
                            'Swiped from $previousIndex to $newIndex in direction $direction',
                          );
                          if (direction == CardSwiperDirection.right) {
                            print('Right swipe detected');
                            final player = AudioPlayer();
                            await player.play(AssetSource('ding-126626.mp3'));
                            // Notiz-Dialog anzeigen
                            bool? completed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => buildChallengeDialog(
                                filteredCards[previousIndex].challenge.title,
                              ),
                            );
                            if (completed == true) {
                              // Navigation zum ActiveChallengeScreen
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
                              // Nach Rückkehr: ChallengeDoneScreen je nach Ergebnis
                              if (result != null) {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChallengeDoneScreen(
                                      challenge: filteredCards[previousIndex]
                                          .challenge,
                                      rewardFactor: result,
                                      // Success factor from ActiveChallengeScreen
                                      onDone: (double rewardFactor) async {
                                        // removed, update happens after return
                                      },
                                    ),
                                  ),
                                );
                                // Update score after returning
                                await _initializeScore();
                              }
                            } else {
                              _cardSwiperController.undo();
                            }
                          } else if (direction == CardSwiperDirection.left) {
                            // Optionally show a message or animation for left swipe
                            print('Left swipe detected');
                          }
                          // NEW: Save current index
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
