import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

/// An animated progress bar with XP sounds and haptic feedback.
///
/// Animates from the previous value to the new [value] every time [value]
/// changes. On upward changes: plays [SoundService.xpProgress] and fires
/// light haptic ticks at 25 / 50 / 75 % milestones. When [value] reaches 1.0
/// it plays [SoundService.xpComplete] and triggers [VibrationService.milestone].
///
/// Set [silent] = true for timer / countdown bars where audio feedback is
/// unwanted (e.g. challenge timer, dismiss bars).
class SyntraXpBar extends ConsumerStatefulWidget {
  final double value;
  final double minHeight;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final bool silent;

  const SyntraXpBar({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 2300),
    this.silent = false,
  });

  @override
  ConsumerState<SyntraXpBar> createState() => _SyntraXpBarState();
}

class _SyntraXpBarState extends ConsumerState<SyntraXpBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  /// Where the current animation sweep started (for milestone gating).
  double _sweepFrom = 0.0;
  /// True while a fill animation is in progress and audio/haptic is wanted.
  bool _feedbackActive = false;
  final Set<int> _milestonesFired = {};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.addListener(_onTick);
    _ctrl.addStatusListener(_onStatus);

    final initialValue = widget.value.clamp(0.0, 1.0);
    _sweepFrom = 0.0;
    // Play feedback on init when bar actually has something to fill.
    _feedbackActive = !widget.silent && initialValue > 0.001;

    _anim = Tween<double>(begin: 0.0, end: initialValue)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    if (_feedbackActive) {
      SoundService.playXpProgress(
          enabled: ref.read(soundEffectsEnabledProvider));
    }
  }

  @override
  void didUpdateWidget(SyntraXpBar old) {
    super.didUpdateWidget(old);
    final to = widget.value.clamp(0.0, 1.0);
    final from = _anim.value;
    if ((to - from).abs() < 0.001) return;

    _sweepFrom = from;
    _milestonesFired.clear();
    _feedbackActive = !widget.silent && to > from;

    _anim = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl
      ..duration = widget.duration
      ..reset()
      ..forward();

    if (_feedbackActive) {
      SoundService.playXpProgress(
          enabled: ref.read(soundEffectsEnabledProvider));
    }
  }

  void _onTick() {
    if (!_feedbackActive) return;
    final v = _anim.value;
    for (final pct in [25, 50, 75]) {
      final t = pct / 100.0;
      if (!_milestonesFired.contains(pct) && v >= t && _sweepFrom < t) {
        _milestonesFired.add(pct);
        VibrationService.xpTick();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (!mounted || !_feedbackActive || status != AnimationStatus.completed) {
      return;
    }
    _feedbackActive = false;
    // Completion chime only when the bar actually reaches 100%.
    if (widget.value >= 1.0) {
      SoundService.playXpComplete(enabled: ref.read(soundEffectsEnabledProvider));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => LinearProgressIndicator(
          value: _anim.value,
          minHeight: widget.minHeight,
          backgroundColor:
              widget.backgroundColor ?? cs.surfaceContainerHighest,
          valueColor:
              AlwaysStoppedAnimation<Color>(widget.color ?? cs.primary),
        ),
      ),
    );
  }
}
