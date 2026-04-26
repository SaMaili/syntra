import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../challenge.dart';
import '../generated/l10n.dart';
import '../router.dart';
import '../services/vibration_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_button.dart';

/// 5-second priming screen shown between challenge selection and the timer.
class PrimingScreen extends StatefulWidget {
  final Challenge challenge;
  final bool isDailyMission;

  const PrimingScreen({
    super.key,
    required this.challenge,
    this.isDailyMission = false,
  });

  @override
  State<PrimingScreen> createState() => _PrimingScreenState();
}

class _PrimingScreenState extends State<PrimingScreen>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 10;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;
  bool _isExiting = false;
  /// Duration override chosen by user; null = use challenge default.
  int? _selectedTime;
  /// Pre-challenge anxiety level (1–5); null = user skipped.
  int? _preAnxiety;

  /// Drives the circular arc from 1.0 → 0.0 continuously over the full
  /// countdown so the ring sweeps smoothly instead of jumping each second.
  late final AnimationController _arcController;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _totalSeconds),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isExiting) {
        t.cancel();
        return;
      }
      if (ModalRoute.of(context)?.isCurrent != true) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _launch();
      }
    });
  }

  @override
  void dispose() {
    _arcController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _headline(S l) {
    final c = widget.challenge;
    if (c.flirt) return l.primingHeadlineFlirt;
    if (c.type == ChallengeType.group) return l.primingHeadlineGroup;
    if (c.time < 60) return l.primingHeadlineQuick;
    if (c.aura > 60) return l.primingHeadlineHard;
    return l.primingHeadlineDefault;
  }

  String _subtext(S l) {
    final c = widget.challenge;
    if (c.flirt) return l.primingSubFlirt;
    if (c.type == ChallengeType.group) return l.primingSubGroup;
    if (c.time < 60) return l.primingSubQuick;
    if (c.aura > 60) return l.primingSubHard;
    return l.primingSubDefault;
  }

  Future<void> _launch() async {
    if (_isExiting) return;
    _isExiting = true;
    _timer?.cancel();
    if (!mounted) return;

    await VibrationService.start();
    if (!mounted) return;

    final result = await context.pushActiveChallenge(
      widget.challenge,
      isDailyMission: widget.isDailyMission,
      overrideTime: _selectedTime,
      preAnxiety: _preAnxiety,
    );
    if (mounted) context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);

    final ringSize =
        (MediaQuery.sizeOf(context).height * 0.13).clamp(72.0, 110.0);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Scrollable content ────────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Animated countdown ring + number ──────────
                          _CountdownRing(
                            arcController: _arcController,
                            secondsLeft: _secondsLeft,
                            size: ringSize,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // ── Headline ──────────────────────────────────
                          Text(
                            _headline(l),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, height: 1.3),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _subtext(l),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: cs.onSurfaceVariant, height: 1.6),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Pre-challenge anxiety picker ───────────────
                          _AnxietyPicker(
                            selected: _preAnxiety,
                            onChanged: (v) =>
                                setState(() => _preAnxiety = v),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Duration picker ───────────────────────────
                          _DurationPicker(
                            challengeTime: widget.challenge.time,
                            selected: _selectedTime,
                            onChanged: (t) =>
                                setState(() => _selectedTime = t),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Actions pinned at bottom ──────────────────────────────
              const SizedBox(height: AppSpacing.lg),
              SyntraButton(onPressed: _launch, child: Text(l.imReady)),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  if (_isExiting) return;
                  _isExiting = true;
                  _timer?.cancel();
                  context.pop();
                },
                child: Text(
                  l.notNow,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Countdown ring ───────────────────────────────────────────────────────────

class _CountdownRing extends StatelessWidget {
  final AnimationController arcController;
  final int secondsLeft;
  final double size;

  const _CountdownRing({
    required this.arcController,
    required this.secondsLeft,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Arc value: 1.0 (full ring) → 0.0 (empty), continuous.
    final arcValue = Tween<double>(begin: 1.0, end: 0.0)
        .animate(arcController);

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Circular arc ──
        SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: arcValue,
            builder: (_, child) => CircularProgressIndicator(
              value: arcValue.value,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ),

        // ── Number — pops in with easeOutBack on each tick ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            // Incoming digit: scale from 0.4 → 1.0 with a slight overshoot,
            // outgoing digit: fades + scales down.
            final scaleIn = Tween<double>(begin: 0.4, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scaleIn, child: child),
            );
          },
          child: Text(
            '$secondsLeft',
            // ValueKey forces AnimatedSwitcher to treat each number as a new
            // widget and run the transition even when the type stays the same.
            key: ValueKey(secondsLeft),
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Duration picker ──────────────────────────────────────────────────────────

class _DurationPicker extends StatelessWidget {
  final int challengeTime;
  final int? selected; // null = default
  final ValueChanged<int?> onChanged;

  const _DurationPicker({
    required this.challengeTime,
    required this.selected,
    required this.onChanged,
  });

  static const _overrides = [30, 60, 120, 300]; // seconds

  String _fmt(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final r = s % 60;
    return r == 0 ? '${m}m' : '${m}m ${r}s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          S.of(context).timerCustomLabel,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          alignment: WrapAlignment.center,
          children: [
            // "Default" chip (null → use challenge time)
            _Chip(
              label: _fmt(challengeTime),
              suffix: ' ★',
              isSelected: selected == null,
              onTap: () => onChanged(null),
              cs: cs,
            ),
            for (final t in _overrides)
              if (t != challengeTime)
                _Chip(
                  label: _fmt(t),
                  isSelected: selected == t,
                  onTap: () => onChanged(t),
                  cs: cs,
                ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String suffix;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _Chip({
    required this.label,
    this.suffix = '',
    required this.isSelected,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: isSelected
              ? Border.all(color: cs.primary, width: 1.5)
              : null,
        ),
        child: Text(
          '$label$suffix',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

// ─── Anxiety picker ───────────────────────────────────────────────────────────

class _AnxietyPicker extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;

  const _AnxietyPicker({required this.selected, required this.onChanged});

  static const _icons = [
    Icons.sentiment_very_satisfied,
    Icons.sentiment_satisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_very_dissatisfied,
  ];
  static const _colors = [
    Colors.green,
    Colors.lightGreen,
    Colors.amber,
    Colors.orange,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Column(
      children: [
        Text(
          l.howNervousQuestion,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final value = i + 1; // 1–5
            final isSelected = selected == value;
            return IconButton(
              icon: Icon(
                _icons[i],
                color: isSelected ? _colors[i] : cs.outlineVariant,
                size: 36,
              ),
              onPressed: () => onChanged(isSelected ? null : value),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.notNervousAtAll,
                  style: tt.labelSmall?.copyWith(color: cs.outlineVariant)),
              Text(l.veryNervous,
                  style: tt.labelSmall?.copyWith(color: cs.outlineVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
