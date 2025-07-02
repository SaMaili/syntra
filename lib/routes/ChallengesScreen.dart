import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../main.dart';
import '../static.dart';
import '../widgets/ChallengeCard.dart';
import 'ActiveChallengeScreen.dart';
import 'ChallengeDoneScreen.dart';
import 'Stats.dart';

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
                child: Text('Ups, das wollte ich nicht'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToggleSwitch(
              minWidth: 90.0,
              minHeight: 22.0,
              initialLabelIndex: session.selectedToggle,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              icons: [Icons.person, Icons.group],
              iconSize: 12.0,
              borderWidth: 2.0,
              borderColor: [AppStatic.grapeLight],
              labels: ['Solo', 'Group'],
              activeBgColors: [
                [Colors.lightBlueAccent],
                [Colors.pink],
              ],
              onToggle: (index) {
                setState(() {
                  session.selectedToggle = index!;
                  // staticCardIndex bleibt erhalten
                });
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Score today: ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Text(
                      score.toString(), // Zeigt den Score an
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredCards.isEmpty
                  ? Center(child: Text('Keine Challenges gefunden'))
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
                          ) => filteredCards[index],
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
                                    builder: (context) => ActiveChallengeScreen(
                                      challenge: filteredCards[previousIndex]
                                          .challenge,
                                    ),
                                  ),
                                );
                            // Nach Rückkehr: ChallengeDoneScreen je nach Ergebnis
                            if (result != null) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChallengeDoneScreen(
                                    challenge:
                                        filteredCards[previousIndex].challenge,
                                    rewardFactor: result,
                                    // Erfolgsfaktor aus ActiveChallengeScreen
                                    onDone: (double rewardFactor) async {
                                      // entfernt, Aktualisierung erfolgt nach Rückkehr
                                    },
                                  ),
                                ),
                              );
                              await _initializeScore(); // Score nach Rückkehr aktualisieren
                            }
                          } else {
                            _cardSwiperController.undo();
                          }
                        } else if (direction == CardSwiperDirection.left) {
                          print('Left swipe detected');
                        }
                        // NEU: aktuellen Index speichern
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
    );
  }
}
