import 'package:audioplayers/audioplayers.dart';

/// Centralized sound effect service for Syntra.
///
/// Uses a pool of players to allow overlapping sounds without cutting each other off.
abstract class SoundService {
  static final List<AudioPlayer> _pool = List.generate(6, (_) => AudioPlayer());
  static int _poolIndex = 0;

  /// Call once at app startup so sound effects mix with background music
  /// (Spotify, podcasts, etc.) instead of interrupting it.
  static Future<void> init() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.notificationEvent,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        // ambient: mixes with other audio, silenced by ring/silent switch
        category: AVAudioSessionCategory.ambient,
      ),
    ));
  }

  static const String click = 'skyscraper_seven-click-buttons-ui-menu-sounds-effects-button-2-203594.mp3';
  static const String ding = 'ding-126626.mp3';
  static const String success = 'yipee-45360.wav';
  static const String error = 'error-call-to-attention-129258.mp3';
  static const String auraProgress = 'Prompt_XP_Bar_Progress.wav';
  static const String auraComplete = 'Loading_Sucsess_sound.wav';

  /// Plays a sound from the pool.
  static void _play(String asset, {double volume = 1.0}) {
    final player = _pool[_poolIndex];
    player.stop().then((_) {
      player.play(AssetSource(asset), volume: volume);
    });
    _poolIndex = (_poolIndex + 1) % _pool.length;
  }

  /// Specialized method for button clicks.
  static void playClick({bool enabled = true}) {
    if (!enabled) return;
    _play(click, volume: 0.4);
  }

  /// Specialized method for challenge start / info.
  static void playDing({bool enabled = true}) {
    if (!enabled) return;
    _play(ding, volume: 0.6);
  }

  /// Specialized method for success/milestones.
  static void playSuccess({bool enabled = true}) {
    if (!enabled) return;
    _play(success, volume: 0.7);
  }

  /// Specialized method for errors/warnings.
  static void playError({bool enabled = true}) {
    if (!enabled) return;
    _play(error, volume: 0.5);
  }

  /// Plays while an XP / progress bar is filling.
  static void playXpProgress({bool enabled = true}) {
    if (!enabled) return;
    _play(auraProgress, volume: 0.55);
  }

  /// Plays at the end of every XP bar fill animation (the "landing" chime).
  static void playXpComplete({bool enabled = true}) {
    if (!enabled) return;
    _play(auraComplete, volume: 0.7);
  }
}
