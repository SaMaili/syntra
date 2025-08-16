// ActiveChallengeScreen.dart
// This file defines the ActiveChallengeScreen widget, which manages the UI and logic for an active challenge session in the Syntra app.
// It handles challenge timing, abort lock, notifications, and user interactions during an ongoing challenge.
//
// Key features:
// - Displays the current challenge and manages its state.
// - Implements a lockout timer to prevent immediate aborting of the challenge.
// - Uses local notifications to alert the user.
// - Integrates with audio and animation for user feedback.
// - Navigates to the ChallengeDoneScreen upon completion.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:syntra/Challenge.dart';
import 'package:syntra/logic/NotificationManager.dart';
import 'package:syntra/widgets/ChallengeCard.dart';
import 'package:syntra/widgets/NotSureWhatToSayDialog.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../generated/l10n.dart';
import '../static.dart';
import 'ChallengeDoneScreen.dart';

// The ActiveChallengeScreen widget manages the UI and logic for an active challenge session.
class ActiveChallengeScreen extends StatefulWidget {
  // The challenge to be performed.
  final Challenge challenge;

  // Optional callback when the challenge is done.
  final ValueChanged<double>? onDone;

  const ActiveChallengeScreen({
    super.key,
    required this.challenge,
    this.onDone,
  });

  @override
  _ActiveChallengeScreenState createState() => _ActiveChallengeScreenState();
}

// State class for ActiveChallengeScreen, handles timers, notifications, and UI updates.
class _ActiveChallengeScreenState extends State<ActiveChallengeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Timer for abort lock (prevents aborting the challenge immediately).
  int abortLockTimer = 15;

  // Main challenge timer (counts down challenge duration).
  int mainTimer = 0;

  // Store the challenge start time.
  late DateTime _startTime;
  late DateTime _endTime;

  // Whether abort lock is finished.
  bool abortLockDone = false;

  // Futures for managing timers.
  late final Future<void> mainTicker;
  late final Future<void> abortLockTicker;

  // Animation controller for pulse effect.
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  
  // Additional animation controllers for beautiful UI
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _timerPulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _timerPulseAnimation;

  int? _scheduledNotificationId;

  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize main timer with challenge time.
    mainTimer = widget.challenge.time;
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(seconds: mainTimer));
    tz.initializeTimeZones();
    _startMainTimer();
    _startAbortLockTimer();
    
    // Set up animations for beautiful UI
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _timerPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _timerPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );
    
    // Set up pulse animation for the DONE button.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _timerPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController?.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _timerPulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recalculate the remaining time when app resumes
      final now = DateTime.now();
      final secondsLeft = _endTime.difference(now).inSeconds;
      setState(() {
        mainTimer = secondsLeft > 0 ? secondsLeft : 0;
      });
    }
  }

  // --- Business Logic ---

  // Start the main challenge timer and update the UI every second.
  Future<void> _startMainTimer() async {
    print("=== CHALLENGE TIMER STARTING ===");
    print("Challenge: ${widget.challenge.title}");
    print("Timer duration: $mainTimer seconds");
    print("Current time: ${DateTime.now()}");
    print(
      "Notification scheduled for: ${DateTime.now().add(Duration(seconds: mainTimer))}",
    );

    // Schedule notification for when timer ends using the reliable NotificationManager
    try {
      final id = await NotificationManager.sendNotification(
        channelId: 'challenge_timer',
        channelName: 'Challenge Timer',
        channelDescription: 'Notification for challenge timer',
        title: S.of(context).challengeTimerCompleteTitle,
        body: S.of(context).challengeTimerCompleteBody(widget.challenge.title),
        vibration: true,
        scheduledTime: DateTime.now().add(Duration(seconds: mainTimer)),
      );
      print("✅ Challenge notification scheduled successfully! ID: $id");
      _scheduledNotificationId = id;
    } catch (e) {
      print("❌ Failed to schedule challenge notification: $e");
    }

    mainTicker = Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isDone) return false;
      final now = DateTime.now();
      final secondsLeft = _endTime.difference(now).inSeconds;

      if (secondsLeft > 0) {
        if (mounted) setState(() => mainTimer = secondsLeft);
        return true; // Continue the timer
      } else {
        // Timer has reached zero
        if (mounted) setState(() => mainTimer = 0);
        print("🏁 Challenge timer finished at: ${DateTime.now()}");

        // Remove legacy immediate backup notification to avoid duplicates
        return false; // Exit the timer loop
      }
    });
  }

  // Start the abort lock timer and update the UI every second.
  void _startAbortLockTimer() {
    abortLockTicker = Future.doWhile(() async {
      if (abortLockTimer > 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => abortLockTimer--);
        return abortLockTimer > 0 && mounted;
      }
      if (mounted && !abortLockDone) setState(() => abortLockDone = true);
      return false;
    });
  }

  // Format seconds as MM:SS string.
  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  // Finish the challenge and navigate to the ChallengeDoneScreen.
  Future<void> _finishChallenge(double rewardFactor) async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (context) => ChallengeDoneScreen(
          challenge: widget.challenge,
          rewardFactor: rewardFactor,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    // Whether abort lock is over.
    final over = abortLockTimer <= 0;
    // Whether main timer is over.
    final mainTimeOver = mainTimer <= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Beautiful gradient backgrounds similar to StatisticsScreen
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
    final timerColor = isDark ? Colors.cyanAccent : AppStatic.marianBlue;
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: isDark ? Colors.black : AppStatic.grapeLight,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            top: false, // Allow content to go behind the AppBar
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
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 60.0), // Reduced top padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Timer section with compact design
                              if (!mainTimeOver) ...[
                                AnimatedBuilder(
                                  animation: _timerPulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _timerPulseAnimation.value,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16), // Reduced from 28
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(20), // Reduced from 28
                                          boxShadow: [
                                            BoxShadow(
                                              color: timerColor.withValues(alpha: 0.2), // Reduced shadow
                                              blurRadius: 15, // Reduced from 25
                                              spreadRadius: 1, // Reduced from 2
                                              offset: Offset(0, 6), // Reduced from 12
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 10, // Reduced from 15
                                              offset: Offset(0, 4), // Reduced from 8
                                            ),
                                          ],
                                        ),
                                        child: Row( // Changed from Column to Row for more compact layout
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.access_time, color: timerColor, size: 24), // Reduced from 28
                                            SizedBox(width: 12),
                                            Text(
                                              S.of(context).timeRemaining,
                                              style: TextStyle(
                                                fontSize: 16, // Reduced from 20
                                                fontWeight: FontWeight.bold,
                                                color: timerColor,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    timerColor.withValues(alpha: 0.1),
                                                    timerColor.withValues(alpha: 0.05),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(15), // Reduced from 20
                                              ),
                                              child: Text(
                                                _formatTime(mainTimer),
                                                style: TextStyle(
                                                  fontSize: 28, // Reduced from 42
                                                  fontWeight: FontWeight.bold,
                                                  color: timerColor,
                                                  letterSpacing: 1, // Reduced from 2
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16), // Reduced from 24
                              ],
                              
                              // Challenge card with enhanced styling
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: titleColor.withValues(alpha: 0.2),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                        offset: Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ChallengeCard(challenge: widget.challenge, showXP: false),
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Help button with beautiful styling
                              if (!mainTimeOver) ...[
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.withValues(alpha: 0.8),
                                        Colors.deepOrange.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.help_outline, size: 24, color: Colors.white),
                                    label: Text(
                                      S.of(context).notSureWhatToSay,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => NotSureWhatToSayDialog(
                                          text: widget.challenge.notSureWhatToSay,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                              
                              // Done button with enhanced styling
                              Container(
                                width: double.infinity,
                                height: mainTimeOver ? 80 : 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: mainTimeOver
                                        ? [
                                            (isDark ? Colors.greenAccent[400]! : const Color(0xFF39FF14)),
                                            (isDark ? Colors.green[600]! : Colors.green[700]!),
                                          ]
                                        : over
                                            ? [
                                                (isDark ? Colors.green[700]! : Colors.green),
                                                (isDark ? Colors.green[800]! : Colors.green[800]!),
                                              ]
                                            : [
                                                (isDark ? Colors.grey[700]! : Colors.grey[400]!),
                                                (isDark ? Colors.grey[800]! : Colors.grey[500]!),
                                              ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mainTimeOver
                                          ? (isDark ? Colors.greenAccent : const Color(0xFF39FF14)).withValues(alpha: 0.4)
                                          : Colors.black.withValues(alpha: 0.2),
                                      blurRadius: mainTimeOver ? 25 : 15,
                                      spreadRadius: mainTimeOver ? 2 : 1,
                                      offset: Offset(0, mainTimeOver ? 12 : 8),
                                    ),
                                  ],
                                ),
                                child: mainTimeOver
                                    ? ScaleTransition(
                                        scale: _pulseAnimation!,
                                        child: ElevatedButton(
                                          onPressed: over
                                              ? () async {
                                                  _isDone = true;
                                                  if (_scheduledNotificationId != null) {
                                                    await NotificationManager.cancelNotification(
                                                      _scheduledNotificationId!,
                                                    );
                                                  }
                                                  final player = AudioPlayer();
                                                  await player.play(
                                                    AssetSource('yipee-45360.mp3'),
                                                  );
                                                  await Future.delayed(
                                                    const Duration(milliseconds: 600),
                                                  );
                                                  await _finishChallenge(0.8);
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.flash_on, color: Colors.white, size: 32),
                                              SizedBox(width: 12),
                                              Text(
                                                S.of(context).doneExcited,
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: over
                                            ? () async {
                                                _isDone = true;
                                                if (_scheduledNotificationId != null) {
                                                  await NotificationManager.cancelNotification(
                                                    _scheduledNotificationId!,
                                                  );
                                                }
                                                final player = AudioPlayer();
                                                await player.play(AssetSource('yipee-45360.mp3'));
                                                await Future.delayed(
                                                  const Duration(milliseconds: 600),
                                                );
                                                await _finishChallenge(1);
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: over
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    S.of(context).doneExcited,
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                S.of(context).stillSecondsLeft(abortLockTimer.toString()),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Abort button with subtle styling
                              if (over)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: mainTimeOver ? 0.2 : 0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      final player = AudioPlayer();
                                      await player.play(
                                        AssetSource('error-call-to-attention-129258.mp3'),
                                      );
                                      await Future.delayed(const Duration(milliseconds: 600));
                                      await _finishChallenge(-0.5);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: mainTimeOver
                                          ? Colors.amberAccent.shade700
                                          : Colors.red.shade400,
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      padding: EdgeInsets.symmetric(
                                        vertical: mainTimeOver ? 12 : 8,
                                        horizontal: 24,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      S.of(context).notToday,
                                      style: TextStyle(
                                        fontSize: mainTimeOver ? 18 : 14,
                                        fontWeight: mainTimeOver ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              SizedBox(height: 8),
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
      ),
    );
  }
}
