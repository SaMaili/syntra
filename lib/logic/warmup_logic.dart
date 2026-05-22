// warmup_logic.dart — pure helpers for the Warm-ups screen.
//
// A warm-up is a short ladder of 2–4 challenges, picked for a specific vibe
// (where the user is going) and a soft time budget (5/10/15 min). The logic
// matches the design prototype's `buildSet` / `swapItem` exactly, only
// translated to the Flutter [Challenge] catalog instead of the JSX POOL.
import 'package:syntra/challenge.dart';

/// Where the user is going next. Drives the catalog filter and the eyebrow
/// label on the auto-built warm-up card.
enum WarmupVibe { coffee, errands, any }

/// Soft total-time budgets the user can pick between.
enum WarmupLength { m5, m10, m15 }

extension WarmupLengthX on WarmupLength {
  /// Target total session seconds. The ladder can run slightly over (1.25×)
  /// if the next challenge would have pushed us right past the cutoff.
  int get targetSeconds => switch (this) {
        WarmupLength.m5 => 5 * 60,
        WarmupLength.m10 => 10 * 60,
        WarmupLength.m15 => 15 * 60,
      };
}

/// Hand-picked challenge IDs per vibe, ordered by ascending level.
/// These form the pool that `buildWarmupSet` draws from — shuffle and
/// time-budget logic still applies, but only within this curated set.
const Map<WarmupVibe, List<String>> _vibePool = {
  WarmupVibe.coffee: [
    '116', // Cashier goodbye      L2 120s  — say "have a great day"
    '117', // Barista favorite     L2 240s  — ask their go-to drink
    '121', // Waiter recommendation L2 240s — ask what to order
    '6',   // Waitress' smile      L2 270s  — compliment server's smile
    '75',  // Coffee-to-go question L3 300s — ask about their coffee
    '2',   // Style compliment     L3 300s  — ask where they got their outfit
    '64',  // Water for cashier    L4 600s  — buy them a water
    '62',  // Restaurant compliment L5 240s — compliment the whole table
  ],
  WarmupVibe.errands: [
    '1',   // Say hello            L1  60s  — smile + hello to a stranger
    '119', // Ask the time         L1  60s  — classic micro-interaction
    '118', // Weather comment      L2 180s  — chat at a crossing
    '55',  // Hello to 5 strangers L2 180s  — builds momentum
    '122', // Transit direction    L2 180s  — practical excuse to talk
    '4',   // Small talk for dirs  L3 300s  — directions + 2-3 sentences
    '95',  // Pet the dog          L3 210s  — easy, fun approach
    '80',  // Best thing this week L5 360s  — open, engaging question
  ],
  WarmupVibe.any: [
    '112', // Like a Gentleman     L1 180s  — hold door, eye contact
    '1',   // Say hello            L1  60s  — simplest possible
    '116', // Cashier goodbye      L2 120s  — low-stakes social act
    '8',   // Lost Bet Ice Cream   L3 300s  — playful opener
    '75',  // Coffee-to-go question L3 300s — curious, natural
    '66',  // Tell them great smile L4 180s — direct warm compliment
    '54',  // Ask about their work  L5 300s — genuine curiosity
    '80',  // Best thing this week  L5 360s — open question
  ],
};

/// Returns the curated pool of [Challenge]s for [vibe], preserving the
/// hand-picked order (ascending level) so the build ladder ramps correctly.
List<Challenge> challengesForVibe(List<Challenge> catalog, WarmupVibe vibe) {
  final ids = _vibePool[vibe] ?? const [];
  final byId = <String, Challenge>{for (final c in catalog) c.id: c};
  return ids.map((id) => byId[id]).whereType<Challenge>().toList();
}

/// Picks a 2–4 challenge ladder for [vibe] that fits the [length] budget.
///
/// Order: ascending level inside the vibe pool, with a stable pseudo-shuffle
/// driven by [seed] so "Shuffle set" produces a fresh-feeling ladder without
/// network or randomness side-effects.
List<Challenge> buildWarmupSet(
  List<Challenge> catalog,
  WarmupVibe vibe,
  WarmupLength length, {
  int seed = 0,
}) {
  final target = length.targetSeconds;
  final pool = challengesForVibe(catalog, vibe);
  if (pool.isEmpty) return const [];

  // Stable pseudo-shuffle so each seed yields a deterministic re-ordering.
  final shuffled = List<Challenge>.from(pool)
    ..sort((a, b) {
      final av = (a.id.hashCode * 9301 + seed * 49297) % 233280;
      final bv = (b.id.hashCode * 9301 + seed * 49297) % 233280;
      return av.compareTo(bv);
    })
    // Then a stable ascending-level sort so the ladder still ramps.
    ..sort((a, b) => a.level.compareTo(b.level));

  final chosen = <Challenge>[];
  var total = 0;
  for (final c in shuffled) {
    if (chosen.length >= 4) break;
    if (total + c.time > target * 1.25 && chosen.length >= 2) break;
    chosen.add(c);
    total += c.time;
    if (total >= target && chosen.length >= 3) break;
  }
  return chosen.isEmpty ? shuffled.take(3).toList() : chosen;
}

/// Returns [current] with the challenge at [index] replaced by a different
/// one of the same level from [catalog]. If no candidate exists, returns the
/// list unchanged.
List<Challenge> swapWarmupItem(
  List<Challenge> current,
  int index,
  WarmupVibe vibe,
  List<Challenge> catalog, {
  required int seed,
}) {
  if (index < 0 || index >= current.length) return current;
  final used = current.map((c) => c.id).toSet();
  final target = current[index];
  final pool = challengesForVibe(catalog, vibe)
      .where((c) => !used.contains(c.id) && c.level == target.level)
      .toList();
  if (pool.isEmpty) return current;
  final pick = pool[seed.abs() % pool.length];
  final next = List<Challenge>.from(current);
  next[index] = pick;
  return next;
}

/// An in-progress warm-up run: the picked [ladder] and which rung the user is
/// on. Threaded through the active-challenge → done flow so each completion
/// chains automatically into the next challenge of the same ladder.
class WarmupSession {
  final List<Challenge> ladder;

  /// 0-based index of the challenge currently being run.
  final int index;

  const WarmupSession({required this.ladder, this.index = 0});

  /// 1-based position for display, e.g. the `2` in "Warm-up 2/3".
  int get position => index + 1;

  int get total => ladder.length;

  bool get hasNext => index + 1 < ladder.length;

  bool get isLast => !hasNext;

  /// The challenge to run after the current one, or null on the last rung.
  Challenge? get nextChallenge => hasNext ? ladder[index + 1] : null;

  /// The session advanced by one rung.
  WarmupSession get next => WarmupSession(ladder: ladder, index: index + 1);
}

/// Formats seconds for the warm-up summary line. <60 → `30s`, ≥60 → `5 min`.
String formatWarmupDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = (seconds / 60).round();
  return '$m min';
}
