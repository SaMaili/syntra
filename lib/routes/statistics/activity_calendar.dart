import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/l10n.dart';
import '../../logic/weekly_streak_logic.dart';
import '../../providers/statistics_providers.dart';
import '../../theme/brand_colors.dart';
import 'profile_section.dart';

/// Activity calendar — one bar per ISO week for the last N weeks. Colors
/// follow the design's `ActivityChart`:
///
///   • Orange gradient if a week reached the weekly Aura threshold
///   • Blue gradient if the week is a streak-freeze
///   • Dark/light "rest" tone otherwise
///
/// Month labels sit under the chart (Jan/Feb/Mar/Apr/May...) with a small
/// 3-up legend below them.
class WeeklyAuraChart extends ConsumerWidget {
  const WeeklyAuraChart({super.key});

  static const int _weeks = 17;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auraAsync = ref.watch(weeklyAuraByWeekProvider);
    final frozenAsync = ref.watch(frozenWeeksProvider);
    final l = S.of(context);

    if (auraAsync.isLoading || frozenAsync.isLoading) {
      return ProfileSection(
        title: l.profileActivityTitle,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    if (auraAsync.hasError || frozenAsync.hasError) {
      return ProfileSection(
        title: l.profileActivityTitle,
        child: Text('Error: ${auraAsync.error ?? frozenAsync.error}'),
      );
    }

    final auraByWeek = auraAsync.value!;
    final frozenWeeks = frozenAsync.value!;
    final now = DateTime.now();
    final currentMonday = WeeklyStreakLogic.startOfIsoWeek(now);

    // Oldest week first.
    final weeks = List.generate(_weeks, (i) {
      final offset = (_weeks - 1 - i) * 7;
      return DateTime(
        currentMonday.year,
        currentMonday.month,
        currentMonday.day - offset,
      );
    });

    final activeCount = weeks.where((m) {
      final key = WeeklyStreakLogic.isoYearWeek(m);
      final aura = auraByWeek[key] ?? 0;
      return aura >= kWeeklyAuraThreshold || frozenWeeks.contains(key);
    }).length;

    return ProfileSection(
      title: l.profileActivityTitle,
      right: l.activeWeeksCount(activeCount),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 90,
            child: _Bars(
              weeks: weeks,
              auraByWeek: auraByWeek,
              frozenWeeks: frozenWeeks,
            ),
          ),
          const SizedBox(height: 8),
          _MonthLabels(weeks: weeks),
          const SizedBox(height: 12),
          const _Legend(),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  final List<DateTime> weeks;
  final Map<String, int> auraByWeek;
  final Set<String> frozenWeeks;

  const _Bars({
    required this.weeks,
    required this.auraByWeek,
    required this.frozenWeeks,
  });

  static const int _maxAura = 420;

  @override
  Widget build(BuildContext context) {
    final restColor = SyntraSurface.of(context).bg3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < weeks.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _Bar(
              monday: weeks[i],
              auraByWeek: auraByWeek,
              frozenWeeks: frozenWeeks,
              restColor: restColor,
              maxAura: _maxAura,
            ),
          ),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final DateTime monday;
  final Map<String, int> auraByWeek;
  final Set<String> frozenWeeks;
  final Color restColor;
  final int maxAura;

  const _Bar({
    required this.monday,
    required this.auraByWeek,
    required this.frozenWeeks,
    required this.restColor,
    required this.maxAura,
  });

  @override
  Widget build(BuildContext context) {
    final key = WeeklyStreakLogic.isoYearWeek(monday);
    final isFrozen = frozenWeeks.contains(key);
    final aura = isFrozen ? kWeeklyAuraThreshold : (auraByWeek[key] ?? 0);
    final reached = aura >= kWeeklyAuraThreshold;
    final fraction = (aura / maxAura).clamp(0.05, 1.0);

    final Gradient? gradient;
    final Color? color;
    if (isFrozen) {
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: BrandColors.streakFreezeGradient,
      );
      color = null;
    } else if (reached) {
      gradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: BrandColors.auraWeekGradient,
      );
      color = null;
    } else {
      gradient = null;
      color = restColor;
    }

    return FractionallySizedBox(
      heightFactor: fraction,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(3),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(1),
            bottomRight: Radius.circular(1),
          ),
        ),
      ),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  final List<DateTime> weeks;
  const _MonthLabels({required this.weeks});

  static const _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        for (int i = 0; i < weeks.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: _label(weeks[i], i, cs, tt)),
        ],
      ],
    );
  }

  Widget _label(DateTime monday, int index, ColorScheme cs, TextTheme tt) {
    final isFirst = index == 0;
    // Mark the column whose week contains the 1st of a month.
    DateTime? labelDay;
    for (int d = 0; d < 7; d++) {
      final day = monday.add(Duration(days: d));
      if (day.day == 1) {
        labelDay = day;
        break;
      }
    }
    if (!isFirst && labelDay == null) return const SizedBox.shrink();
    final dayToLabel = labelDay ?? monday;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        _monthAbbr[dayToLabel.month - 1],
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final restColor = SyntraSurface.of(context).bg3;
    final l = S.of(context);

    final labelStyle = tt.labelSmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontSize: 11,
    );

    return Row(
      children: [
        _Swatch(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: BrandColors.auraWeekGradient,
          ),
        ),
        const SizedBox(width: 6),
        Text(l.activityLegendActive(kWeeklyAuraThreshold), style: labelStyle),
        const SizedBox(width: 14),
        _Swatch(color: restColor),
        const SizedBox(width: 6),
        Text(l.activityLegendQuiet, style: labelStyle),
        const SizedBox(width: 14),
        _Swatch(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: BrandColors.streakFreezeGradient,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(l.activityLegendFreeze,
              style: labelStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color? color;
  final Gradient? gradient;
  const _Swatch({this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
