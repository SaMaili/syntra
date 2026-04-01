import 'package:vibration/vibration.dart';

/// Centralized haptic/vibration vocabulary for Syntra.
///
/// All vibrations have semantic names so call-sites communicate intent
/// rather than raw millisecond values.  Each method is no-op if the device
/// has no vibrator.
abstract class VibrationService {
  static Future<bool> get _available async =>
      await Vibration.hasVibrator();

  /// Light single tap — challenge accepted / swipe right.
  static Future<void> accept() async {
    if (!await _available) return;
    Vibration.vibrate(duration: 40, amplitude: 80);
  }

  /// Short double pulse — challenge session started.
  static Future<void> start() async {
    if (!await _available) return;
    Vibration.vibrate(pattern: [0, 60, 80, 60], intensities: [0, 100, 0, 100]);
  }

  /// Single long buzz — 10-second timer warning (user is away from phone).
  static Future<void> timerWarning() async {
    if (!await _available) return;
    Vibration.vibrate(duration: 400, amplitude: 180);
  }

  /// Three short pulses — timer reached zero, come back now.
  static Future<void> timerEnd() async {
    if (!await _available) return;
    Vibration.vibrate(
      pattern: [0, 120, 80, 120, 80, 120],
      intensities: [0, 200, 0, 200, 0, 200],
    );
  }

  /// Strong single long vibration — challenge succeeded.
  static Future<void> success() async {
    if (!await _available) return;
    Vibration.vibrate(duration: 600, amplitude: 255);
  }

  /// Complex pattern — streak milestone or level-up moment.
  static Future<void> milestone() async {
    if (!await _available) return;
    Vibration.vibrate(
      pattern: [0, 150, 60, 150, 60, 400],
      intensities: [0, 180, 0, 180, 0, 255],
    );
  }

  /// Very light single tick — XP bar crossing a 25/50/75 % milestone.
  static Future<void> xpTick() async {
    if (!await _available) return;
    Vibration.vibrate(duration: 18, amplitude: 50);
  }

  // No vibration for failure — do not punish with haptics.
}
