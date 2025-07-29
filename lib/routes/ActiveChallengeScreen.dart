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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController?.dispose();
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
        title: '🎉 Challenge Complete!',
        body:
            'Amazing! You completed "${widget.challenge.title}" - time to celebrate! 🏆',
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

        // Send an immediate notification as backup
        try {
          print("🚨 Sending immediate notification as timer finished");
          // Try immediate notification first
          await NotificationManager.sendImmediateNotification(
            channelId: 'challenge_timer',
            channelName: 'Challenge Timer',
            channelDescription: 'Notification for challenge timer',
            title: S.of(context).challengeTimerCompleteTitle,
            body: S
                .of(context)
                .challengeTimerCompleteBody(widget.challenge.title),
            vibration: true,
          );
        } catch (e) {
          print("❌ Failed to send immediate notification: $e");
        }

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
    final bgColor = isDark ? Colors.black : null;
    final helpBtnBg = isDark ? Colors.grey[800] : Colors.grey[300];
    final helpBtnFg = isDark ? Colors.white : Colors.black;
    final doneBtnBg = mainTimeOver
        ? (isDark ? Colors.greenAccent[400] : const Color(0xFF39FF14))
        : (over
              ? (isDark ? Colors.green[700] : Colors.green)
              : (isDark ? Colors.grey[700] : Colors.grey[400]));
    final doneBtnFg = Colors.white;
    final doneBtnShadow = mainTimeOver
        ? (isDark ? Colors.greenAccent : const Color(0xFF39FF14))
        : (isDark ? Colors.black54 : Colors.black26);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).activeChallengeTitle),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: bgColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!mainTimeOver) ...[
              const SizedBox(height: 16),
              Text(
                S.of(context).timeRemaining,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(mainTimer),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
            ],
            Expanded(
              child: ChallengeCard(challenge: widget.challenge, showXP: false),
            ),
            const SizedBox(height: 32),
            if (!mainTimeOver) ...[
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => NotSureWhatToSayDialog(
                      text: widget.challenge.notSureWhatToSay,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: helpBtnBg,
                  foregroundColor: helpBtnFg,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(S.of(context).notSureWhatToSay),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: mainTimeOver ? 80 : 64,
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
                          backgroundColor: doneBtnBg,
                          foregroundColor: doneBtnFg,
                          textStyle: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 12,
                          shadowColor: doneBtnShadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Text(S.of(context).doneExcited),
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
                        backgroundColor: doneBtnBg,
                        foregroundColor: doneBtnFg,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 2,
                        shadowColor: doneBtnShadow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: over
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text(S.of(context).doneExcited)],
                            )
                          : Text(
                              S
                                  .of(context)
                                  .stillSecondsLeft(abortLockTimer.toString()),
                            ),
                    ),
            ),
            SizedBox(height: mainTimeOver ? 16 : 8),
            if (over)
              TextButton(
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
                      : Colors.black54,
                  textStyle: TextStyle(
                    fontSize: mainTimeOver ? 18 : 12,
                    fontWeight: mainTimeOver
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: mainTimeOver ? 12 : 4,
                    horizontal: 8,
                  ),
                ),
                child: Text(
                  S.of(context).notToday,
                  style: TextStyle(
                    color: isDark ? Colors.pink[200] : Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
