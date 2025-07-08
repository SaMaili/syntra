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
import 'package:flutter/services.dart';
import 'package:syntra/Challenge.dart';
import 'package:syntra/widgets/ChallengeCard.dart';
import 'package:syntra/widgets/not_sure_what_to_say_dialog.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'ChallengeDoneScreen.dart';
import 'package:syntra/logic/ActiveChallengeLogic.dart';

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
    with SingleTickerProviderStateMixin {
  // Timer for abort lock (prevents aborting the challenge immediately).
  int abortLockTimer = 2;
  // Main challenge timer (counts down challenge duration).
  int mainTimer = 0;
  // Whether abort lock is finished.
  bool abortLockDone = false;
  // Futures for managing timers.
  late final Future<void> mainTicker;
  late final Future<void> abortLockTicker;
  // Animation controller for pulse effect.
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  late ActiveChallengeLogic logic;

  @override
  void initState() {
    super.initState();
    // Initialize main timer with challenge time.
    mainTimer = widget.challenge.time;
    logic = ActiveChallengeLogic(context: context, mainTimer: mainTimer);
    logic.initNotifications();
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
    logic.cancelTimerNotification();
    _pulseController?.dispose();
    super.dispose();
  }

  // --- Business Logic ---

  // Start the main challenge timer and update the UI every second.
  void _startMainTimer() {
    logic.scheduleTimerNotification();
    mainTicker = Future.doWhile(() async {
      if (mainTimer > 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) setState(() => mainTimer--);
        return mainTimer > 0 && mounted;
      }
      return false;
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
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SPOT! RUN! TALK!'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!mainTimeOver) ...[
              const SizedBox(height: 16),
              const Text('Time Remaining', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Display the main timer.
              Text(_formatTime(mainTimer), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
            ],
            // Show the challenge card.
            Expanded(child: ChallengeCard(challenge: widget.challenge, showXP: false)),
            const SizedBox(height: 32),
            if (!mainTimeOver) ...[
              // Button for help dialog if user is unsure what to say.
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => NotSureWhatToSayDialog(text: widget.challenge.notSureWhatToSay),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Not sure what to say?'),
              ),
              const SizedBox(height: 24),
            ],
            // Main DONE button or countdown.
            SizedBox(
              width: double.infinity,
              height: mainTimeOver ? 80 : 64,
              child: mainTimeOver
                  ? ScaleTransition(
                      scale: _pulseAnimation!,
                      child: ElevatedButton(
                        onPressed: over
                            ? () async {
                                // Play success sound and finish challenge with reduced reward.
                                final player = AudioPlayer();
                                await player.play(AssetSource('yipee-45360.mp3'));
                                await Future.delayed(const Duration(milliseconds: 600));
                                await _finishChallenge(0.8);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39FF14),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          elevation: 12,
                          shadowColor: const Color(0xFF39FF14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [Icon(Icons.flash_on, color: Colors.white, size: 32), SizedBox(width: 12), Text('DONE! 😎')],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: over
                          ? () async {
                              // Play success sound and finish challenge with full reward.
                              final player = AudioPlayer();
                              await player.play(AssetSource('yipee-45360.mp3'));
                              await Future.delayed(const Duration(milliseconds: 600));
                              await _finishChallenge(1);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: over ? Colors.green : Colors.grey[400],
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        elevation: 2,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: over
                          ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('DONE! 😎')])
                          : Text('Noch $abortLockTimer Sekunden...'),
                    ),
            ),
            SizedBox(height: mainTimeOver ? 16 : 8),
            // Button to abort the challenge (shows after abort lock is over).
            if (over)
              TextButton(
                onPressed: () async {
                  // Play error sound and finish challenge with penalty.
                  final player = AudioPlayer();
                  await player.play(AssetSource('error-call-to-attention-129258.mp3'));
                  await Future.delayed(const Duration(milliseconds: 600));
                  await _finishChallenge(-0.5);
                },
                style: TextButton.styleFrom(
                  foregroundColor: mainTimeOver ? Colors.amberAccent.shade700 : Colors.black54,
                  textStyle: TextStyle(fontSize: mainTimeOver ? 18 : 12, fontWeight: mainTimeOver ? FontWeight.bold : FontWeight.normal),
                  padding: EdgeInsets.symmetric(vertical: mainTimeOver ? 12 : 4, horizontal: 8),
                ),
                child: const Text('Not today 🙈'),
              ),
          ],
        ),
      ),
    );
  }
}
