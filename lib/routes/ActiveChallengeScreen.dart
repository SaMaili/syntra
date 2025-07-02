import 'package:android_intent_plus/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syntra/Challenge.dart';
import 'package:syntra/widgets/ChallengeCard.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'ChallengeDoneScreen.dart';

class ActiveChallengeScreen extends StatefulWidget {
  final Challenge challenge;
  final ValueChanged<double>? onDone;

  const ActiveChallengeScreen({
    super.key,
    required this.challenge,
    this.onDone,
  });

  @override
  _ActiveChallengeScreenState createState() => _ActiveChallengeScreenState();
}

class _ActiveChallengeScreenState extends State<ActiveChallengeScreen>
    with SingleTickerProviderStateMixin {
  /// TODO Timer-Variablen runter setzen für debugging
  int abortLockTimer = 15; // 10 seconds
  int mainTimer = 0; // Set in initState
  bool abortLockDone = false;
  late final mainTicker;
  late final abortLockTicker;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    mainTimer = widget.challenge.time;
    _initNotifications();
    tz.initializeTimeZones();
    _startMainTimer();
    _startabortLockTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _askForExactAlarmPermission();
  }

  Future<void> _initNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin!.initialize(initializationSettings);
    // Request notification permission (Android 13+)
    if (Theme.of(context).platform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      print('Notification permission status: ' + status.toString());
    }
  }

  Future<bool> _canScheduleExactAlarms() async {
    try {
      const platform = MethodChannel('channel_timer');
      final bool canSchedule = await platform.invokeMethod(
        'canScheduleExactAlarms',
      );
      print('[DEBUG] Can schedule exact alarms: $canSchedule');
      return canSchedule;
    } catch (e) {
      print('[DEBUG] Error checking exact alarm permission: $e');
      return false;
    }
  }

  Future<void> _askForExactAlarmPermission() async {
    // Only relevant for Android
    if (Theme.of(context).platform != TargetPlatform.android) return;
    bool canSchedule = await _canScheduleExactAlarms();
    if (canSchedule) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Allow exact alarms'),
        content: Text(
          'To make scheduled notifications work exactly, Syntra needs permission for exact alarms. Please grant this in the settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
              );
              await intent.launch();
              Navigator.of(dialogContext).pop();
            },
            child: Text('Go to settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleTimerNotification() async {
    if (flutterLocalNotificationsPlugin == null) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'challenge_timer',
          'Challenge Timer',
          channelDescription: 'Notification for challenge timer',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    bool canSchedule = await _canScheduleExactAlarms();
    await flutterLocalNotificationsPlugin!.zonedSchedule(
      0,
      'Zeit abgelaufen!',
      'Deine Challenge-Zeit ist vorbei! Zeit für Action! 💪',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: mainTimer)),
      details,
      androidScheduleMode: canSchedule
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      matchDateTimeComponents: null,
    );
  }

  Future<void> _cancelTimerNotification() async {
    if (flutterLocalNotificationsPlugin != null) {
      await flutterLocalNotificationsPlugin!.cancel(0);
    }
  }

  void _startMainTimer() {
    _scheduleTimerNotification();
    mainTicker = Future.doWhile(() async {
      if (mainTimer > 0) {
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          setState(() {
            mainTimer--;
          });
        }
        return mainTimer > 0 && mounted;
      }
      return false;
    });
  }

  void _startabortLockTimer() {
    abortLockTicker = Future.doWhile(() async {
      if (abortLockTimer > 0) {
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          setState(() {
            abortLockTimer--;
          });
        }
        return abortLockTimer > 0 && mounted;
      }
      if (mounted && !abortLockDone) {
        setState(() {
          abortLockDone = true;
        });
      }
      return false;
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final bool Over = abortLockTimer <= 0;
    final bool mainTimeOver = mainTimer <= 0;
    // No more vibration at timer end

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('SPOT! RUN! TALK!'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!mainTimeOver) ...[
              SizedBox(height: 16),
              Text(
                'Time Remaining',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _formatTime(mainTimer),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
            ],
            Expanded(
              child: ChallengeCard(challenge: widget.challenge, showXP: false),
            ),
            SizedBox(height: 32),
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
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Not sure what to say?'),
              ),
              SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: mainTimeOver ? 80 : 64,
              child: mainTimeOver
                  ? ScaleTransition(
                      scale: _pulseAnimation!,
                      child: ElevatedButton(
                        onPressed: Over
                            ? () async {
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
                          backgroundColor: Color(0xFF39FF14),
                          // Neon Green
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 12,
                          shadowColor: Color(0xFF39FF14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Text('DONE! 😎'),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: Over
                          ? () async {
                              final player = AudioPlayer();
                              await player.play(AssetSource('yipee-45360.mp3'));
                              await Future.delayed(
                                const Duration(milliseconds: 600),
                              );
                              await _finishChallenge(1);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Over ? Colors.green : Colors.grey[400],
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 2,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Over
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('DONE! 😎')],
                            )
                          : Text('Noch $abortLockTimer Sekunden...'),
                    ),
            ),
            SizedBox(height: mainTimeOver ? 16 : 8),
            if (Over)
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
                child: Text('Not today 🙈'),
              ),
          ],
        ),
      ),
    );
  }

  // Hilfsfunktion für Abschluss
  Future<void> _finishChallenge(double rewardFactor) async {
    final result = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (context) => ChallengeDoneScreen(
          challenge: widget.challenge,
          rewardFactor: rewardFactor,
        ),
      ),
    );
    // Immer direkt zurück zur Challenge-Übersicht, egal wie viele Screens dazwischen liegen
    if (result != null && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _cancelTimerNotification();
    _pulseController?.dispose();
    super.dispose();
  }
}

class NotSureWhatToSayDialog extends StatelessWidget {
  final String text;

  const NotSureWhatToSayDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text(
            'Lost for words?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(text, style: TextStyle(fontSize: 18))],
      ),
      actions: [
        TextButton(
          //TODO: add "penalty" for using the not sure what to say button for example reduce by 10% because you didn't try hard genug
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Okay', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
