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
import '../generated/l10n.dart';
import 'ActiveChallengeScreen.dart';
import 'ChallengeDoneScreen.dart';
import 'StatisticsScreen.dart';

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

class _ChallengesScreenState extends State<ChallengesScreen>
    with RouteAware, TickerProviderStateMixin {
  static int staticCardIndex = 0;
  final CardSwiperController _cardSwiperController = CardSwiperController();
  DateTime? lastScoreDate;
  final ChallengesScreenLogic logic = ChallengesScreenLogic();
  bool _loading = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeScore();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _initializeScore();
  }

  Future<void> _initializeScore() async {
    setState(() {
      _loading = true;
    });

    // Use the StatisticsScreenLogic to fetch today's XP
    int todayScore = await StatisticsLogic().fetchTotalXp();
    setState(() {
      logic.score = todayScore;
      _loading = false;
    });

    // Start animations when content is loaded
    if (!_loading) {
      _fadeController.forward();
      _scaleController.forward();
      _slideController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc), Color(0xFF74b9ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppStatic.grape),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading challenges...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredCards = logic.getFilteredCards();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc), Color(0xFF74b9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final titleColor = isDark ? Colors.pinkAccent : AppStatic.grape;
    final scoreBoxColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.95)
        : Colors.amber[50]!.withValues(alpha: 0.95);
    final scoreTextColor = isDark ? Colors.amber[200] : Colors.amber[800];
    final scoreValueColor = isDark ? Colors.amberAccent : Colors.amber[900];
    final shuffleIconColor = isDark ? Colors.pinkAccent : AppStatic.grape;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Toggle Switch with slide animation
                            SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: titleColor.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ToggleSwitch(
                                  minWidth: 120.0,
                                  minHeight: 45.0,
                                  initialLabelIndex: logic.session.selectedToggle,
                                  cornerRadius: 25.0,
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                  inactiveFgColor: isDark ? Colors.white70 : Colors.grey[600],
                                  totalSwitches: 2,
                                  icons: [Icons.person, Icons.group],
                                  iconSize: 24.0,
                                  borderWidth: 0.0,
                                  labels: [S.of(context).solo, S.of(context).group],
                                  activeBgColors: [
                                    [titleColor, titleColor.withValues(alpha: 0.8)],
                                    [Colors.pinkAccent, Colors.pinkAccent.withValues(alpha: 0.8)],
                                  ],
                                  onToggle: (index) {
                                    setState(() {
                                      logic.session.selectedToggle = index!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Score container with pulse animation
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: scoreBoxColor,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber,
                                                Colors.amber.withValues(alpha: 0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withValues(alpha: 0.4),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(8),
                                          child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
                                        ),
                                        const SizedBox(width: 16),
                                        Flexible(
                                          child: Text(
                                            S.of(context).score,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: scoreTextColor,
                                              letterSpacing: 1.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber[600]!,
                                                Colors.amber[400]!,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            logic.score.toString(),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                shuffleIconColor,
                                                shuffleIconColor.withValues(alpha: 0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: shuffleIconColor.withValues(alpha: 0.4),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.shuffle,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                logic.shuffleChallenges();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(S.of(context).challengesShuffled),
                                                  backgroundColor: titleColor,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: S.of(context).shuffleTooltip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Challenge cards
                            Expanded(
                              child: filteredCards.isEmpty
                                  ? Center(
                                      child: Container(
                                        padding: EdgeInsets.all(32),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.search_off,
                                              size: 64,
                                              color: titleColor.withValues(alpha: 0.6),
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              S.of(context).noChalllengesFound,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: titleColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Try changing the filter or check back later!',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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
                                      cardBuilder: (
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
                                                color: titleColor.withValues(alpha: 0.2),
                                                blurRadius: 25,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 12),
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 15,
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
                                            final result = await Navigator.of(context).push<double>(
                                              MaterialPageRoute(
                                                builder: (context) => ActiveChallengeScreen(
                                                  challenge: filteredCards[previousIndex].challenge,
                                                ),
                                              ),
                                            );
                                            if (result != null) {
                                              // After challenge, show ChallengeDoneScreen and update score.
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => ChallengeDoneScreen(
                                                    challenge: filteredCards[previousIndex].challenge,
                                                    rewardFactor: result,
                                                    onDone: (double rewardFactor) async {},
                                                  ),
                                                ),
                                              );
                                              await _initializeScore();
                                              // Show snackbar when challenge is completed
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(S.of(context).challengeCompletedGeneric),
                                                  backgroundColor: titleColor,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
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
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

