import 'package:flutter/material.dart';
import 'package:syntra/challenge.dart';

import '../../generated/l10n.dart';
import '../../logic/comfort_zone_logic.dart';
import '../../theme/brand_colors.dart';
import '../../widgets/syntra_button.dart';
import 'onboarding_shared.dart';

// ─── Screen 1: Hook ──────────────────────────────────────────────────────────

class Page1Hook extends StatelessWidget {
  final VoidCallback onNext;
  const Page1Hook({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return OnbScaffold(
      footer: SyntraButton(
        onPressed: onNext,
        child: Text(l.onboarding1Button),
      ),
      children: [
        const OnbDisc(icon: Icons.psychology_alt_rounded),
        OnbHeadline(l.onboarding1Headline),
        OnbSubtext(l.onboarding1Subtext),
      ],
    );
  }
}

// ─── Screen 2: How it works ──────────────────────────────────────────────────

class Page2HowItWorks extends StatelessWidget {
  final VoidCallback onNext;
  const Page2HowItWorks({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final steps = <(IconData, String, String)>[
      (Icons.explore_rounded, l.onboarding2Step1, l.onboarding2Step1Desc),
      (Icons.schedule_rounded, l.onboarding2Step2, l.onboarding2Step2Desc),
      (Icons.check_circle_rounded, l.onboarding2Step3, l.onboarding2Step3Desc),
    ];
    return OnbScaffold(
      footer: SyntraButton(onPressed: onNext, child: Text(l.onboarding2Button)),
      children: [
        const OnbDisc(icon: Icons.route_rounded),
        OnbHeadline(l.onboarding2Headline),
        OnbSubtext(l.onboarding2Subtext),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _StepCard(
                  number: i + 1,
                  icon: steps[i].$1,
                  title: steps[i].$2,
                  desc: steps[i].$3,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String desc;
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: cs.primary),
                ),
                Positioned(
                  right: 0,
                  top: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark ? Colors.white : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Screen 3: Safety statement ──────────────────────────────────────────────

class Page3Safety extends StatelessWidget {
  final VoidCallback onNext;
  const Page3Safety({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    const green = BrandColors.green;
    return OnbScaffold(
      footer: SyntraButton(onPressed: onNext, child: Text(l.onboarding3Button)),
      children: [
        const OnbDisc(icon: Icons.shield_rounded, tint: green),
        OnbHeadline(l.onboarding3Headline),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.08),
              border: Border.all(color: green.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_rounded, size: 16, color: green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.onboarding3Subtext,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.5,
                      color:
                          isDark ? BrandColors.greenLight : cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Screen 4: Starting point ────────────────────────────────────────────────

class Page4StartingPoint extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const Page4StartingPoint({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final levels = <_Lv>[
      _Lv(1, l.onboarding4Level1Title, l.onboarding4Level1Subtitle,
          Icons.self_improvement_rounded,
          const Color(0xFF43A047), const Color(0xFF66BB6A)),
      _Lv(2, l.onboarding4Level2Title, l.onboarding4Level2Subtitle,
          Icons.trending_up_rounded, BrandColors.blue, BrandColors.blueLight),
      _Lv(3, l.onboarding4Level3Title, l.onboarding4Level3Subtitle,
          Icons.rocket_launch_rounded,
          BrandColors.orangeLo, BrandColors.orangeHi),
    ];
    return OnbScaffold(
      children: [
        const OnbDisc(icon: Icons.tune_rounded),
        OnbHeadline(l.onboarding4Headline),
        OnbSubtext(l.onboarding4Subtext),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
          child: Column(
            children: [
              for (var i = 0; i < levels.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _LevelCard(
                  lv: levels[i],
                  selected: selected == levels[i].level,
                  onTap: () => onSelect(levels[i].level),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Lv {
  final int level;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color from;
  final Color to;
  _Lv(this.level, this.title, this.subtitle, this.icon, this.from, this.to);
}

class _LevelCard extends StatelessWidget {
  final _Lv lv;
  final bool selected;
  final VoidCallback onTap;
  const _LevelCard({
    required this.lv,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: const Cubic(0.16, 1, 0.3, 1),
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lv.from.withValues(alpha: 0.12),
                  lv.to.withValues(alpha: 0.04),
                ],
              )
            : null,
        color: selected ? null : s.bg1,
        border: Border.all(
          color: selected ? lv.to : s.bg3,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: selected
            ? [BoxShadow(color: lv.to.withValues(alpha: 0.20), blurRadius: 20)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [lv.from, lv.to],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: lv.to.withValues(alpha: 0.33),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(lv.icon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEVEL ${lv.level}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: lv.to,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lv.title,
                        style: TextStyle(
                          fontFamily: 'Octarine',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? Colors.white : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lv.subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle_rounded, size: 22, color: lv.to),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Screen 5: Commitment ────────────────────────────────────────────────────

class Page5Commitment extends StatelessWidget {
  final VoidCallback onNext;
  const Page5Commitment({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return OnbScaffold(
      footer: SyntraButton(onPressed: onNext, child: Text(l.onboarding5Button)),
      children: [
        const OnbDisc(icon: Icons.schedule_rounded, tint: BrandColors.orange),
        OnbHeadline(l.onboarding5Headline),
        OnbSubtext(l.onboarding5Subtext),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: _StatGrid(
            stats: [
              (l.onboarding5Stat1Value, l.onboarding5Stat1Label),
              (l.onboarding5Stat2Value, l.onboarding5Stat2Label),
              (l.onboarding5Stat3Value, l.onboarding5Stat3Label),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final List<(String, String)> stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats[i].$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Octarine',
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      letterSpacing: -0.5,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats[i].$2.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      letterSpacing: 1,
                      color: cs.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Screen 6: Notifications ─────────────────────────────────────────────────

class Page6Notifications extends StatelessWidget {
  final Set<int> selectedSlots;
  final bool requesting;
  final void Function(int) onToggleSlot;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const Page6Notifications({
    super.key,
    required this.selectedSlots,
    required this.requesting,
    required this.onToggleSlot,
    required this.onEnable,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    final slots = <_Slot>[
      _Slot(1, Icons.wb_sunny_rounded, l.morning, '9:00',
          BrandColors.amberWarm),
      _Slot(2, Icons.wb_cloudy_rounded, l.afternoon, '14:00',
          BrandColors.pink),
      _Slot(3, Icons.nights_stay_rounded, l.evening, '19:00',
          const Color(0xFF7E57C2)),
    ];
    return OnbScaffold(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyntraButton.icon(
            onPressed: requesting ? null : onEnable,
            icon: Icons.notifications_active_rounded,
            label: requesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.enableReminders),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            child: Text(
              l.rememberOnMyOwn,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      children: [
        const OnbDisc(icon: Icons.notifications_active_rounded),
        OnbHeadline(l.wantReminders),
        OnbSubtext(l.reminderExplanation),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: Row(
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _SlotChip(
                    slot: slots[i],
                    selected: selectedSlots.contains(slots[i].id),
                    onTap: () => onToggleSlot(slots[i].id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Slot {
  final int id;
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  _Slot(this.id, this.icon, this.label, this.time, this.color);
}

class _SlotChip extends StatelessWidget {
  final _Slot slot;
  final bool selected;
  final VoidCallback onTap;
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final c = slot.color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      c.withValues(alpha: 0.12),
                      c.withValues(alpha: 0.03),
                    ],
                  )
                : null,
            color: selected ? null : s.bg1,
            border: Border.all(
              color: selected ? c : s.bg3,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 16)]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(slot.icon,
                  size: 28, color: selected ? c : cs.onSurfaceVariant),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.label,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected
                        ? (isDark ? Colors.white : cs.onSurface)
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.time,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: cs.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Screen 7: First challenge ───────────────────────────────────────────────

class Page7FirstChallenge extends StatelessWidget {
  final Challenge? challenge;
  final VoidCallback onStartNow;
  final VoidCallback onLater;

  const Page7FirstChallenge({
    super.key,
    required this.challenge,
    required this.onStartNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    final c = challenge;
    return OnbScaffold(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyntraButton.icon(
            onPressed: c != null ? onStartNow : null,
            icon: Icons.rocket_launch_rounded,
            label: Text(l.startNow),
          ),
          const SizedBox(height: 10),
          SyntraButton(
            onPressed: onLater,
            color: cs.surfaceContainerHigh,
            child: Text(l.doItLater, style: TextStyle(color: cs.onSurface)),
          ),
        ],
      ),
      children: [
        const OnbDisc(icon: Icons.flag_rounded),
        OnbHeadline(l.heresYourFirst),
        OnbSubtext(l.firstChallengeDesc),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: c == null
              ? const Center(child: CircularProgressIndicator())
              : _FirstChallengeCard(challenge: c),
        ),
      ],
    );
  }
}

class _FirstChallengeCard extends StatelessWidget {
  final Challenge challenge;
  const _FirstChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final s = SyntraSurface.of(context);
    final gradient = ComfortZoneLogic.levelGradient(challenge.level);
    return Container(
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, decoration: BoxDecoration(gradient: gradient)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.levelN(challenge.level).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                size: 12, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              '+${challenge.aura}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      challenge.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(challenge.time),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: cs.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}
