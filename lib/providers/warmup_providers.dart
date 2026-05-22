// warmup_providers.dart — state for the Warm-ups screen.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../data/settings_repository.dart';
import '../logic/warmup_logic.dart';
import 'challenge_providers.dart'
    show challengeCatalogProvider, bookmarkedChallengeIdsProvider;
import 'settings_providers.dart' show settingsRepositoryProvider;

/// Vibe the user picked. Null until they tap one — the screen renders only the
/// step-1 question and the chips below it before that.
final warmupVibeProvider = StateProvider<WarmupVibe?>((_) => null);

/// Target session length. Defaults to 10 min — matches the design prototype's
/// initial state.
final warmupLengthProvider =
    StateProvider<WarmupLength>((_) => WarmupLength.m10);

/// Bumped by the shuffle button to force the [warmupSetProvider] to re-pick.
final warmupSeedProvider = StateProvider<int>((_) => 1);

/// Per-row override map. Lets the user swap a single ladder slot without
/// regenerating the whole set. Keys are slot indices; values are the
/// challenge IDs to substitute in. Cleared whenever the seed/length/vibe
/// changes.
final warmupSlotOverridesProvider =
    StateProvider<Map<int, String>>((_) => const {});

/// The current auto-built ladder, derived from vibe + length + seed.
/// Returns an empty list when no vibe is selected.
final warmupSetProvider = Provider<AsyncValue<List<Challenge>>>((ref) {
  final vibe = ref.watch(warmupVibeProvider);
  final length = ref.watch(warmupLengthProvider);
  final seed = ref.watch(warmupSeedProvider);
  final overrides = ref.watch(warmupSlotOverridesProvider);
  final catalogAsync = ref.watch(challengeCatalogProvider);

  if (vibe == null) return const AsyncValue.data([]);

  return catalogAsync.whenData((catalog) {
    final base = buildWarmupSet(catalog, vibe, length, seed: seed);
    if (overrides.isEmpty) return base;
    final byId = {for (final c in catalog) c.id: c};
    return [
      for (var i = 0; i < base.length; i++)
        if (overrides[i] != null && byId.containsKey(overrides[i]))
          byId[overrides[i]]!
        else
          base[i],
    ];
  });
});

/// User's saved warm-up — the challenges they've bookmarked, in the order
/// they've arranged them on this screen. Backed by `bookmarkedChallengeIds`
/// (source of truth for which) and a separate ordered list (source of truth
/// for the order).
///
/// On every read it reconciles:
///   - bookmark IDs not yet in the order list → appended to the end
///   - order entries that are no longer bookmarked → dropped
final savedWarmupOrderProvider =
    StateNotifierProvider<SavedWarmupOrderNotifier, List<String>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  final bookmarks = ref.watch(bookmarkedChallengeIdsProvider);
  return SavedWarmupOrderNotifier(repo, bookmarks);
});

class SavedWarmupOrderNotifier extends StateNotifier<List<String>> {
  final SettingsRepository _repo;
  final Set<String> _bookmarks;

  SavedWarmupOrderNotifier(this._repo, this._bookmarks) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    final stored = await _repo.loadWarmupOrder();
    state = _reconcile(stored);
  }

  List<String> _reconcile(List<String> stored) {
    final seen = <String>{};
    final out = <String>[];
    // Keep stored order for entries that are still bookmarked.
    for (final id in stored) {
      if (_bookmarks.contains(id) && seen.add(id)) out.add(id);
    }
    // Append any new bookmarks not yet in the order.
    for (final id in _bookmarks) {
      if (seen.add(id)) out.add(id);
    }
    return out;
  }

  Future<void> reorder(int from, int to) async {
    if (from < 0 || from >= state.length) return;
    final next = List<String>.from(state);
    final moved = next.removeAt(from);
    final clamped = to.clamp(0, next.length);
    next.insert(clamped, moved);
    state = next;
    await _repo.saveWarmupOrder(next);
  }

  Future<void> remove(String id) async {
    // Removing from the warm-up list also un-bookmarks — the two stay in
    // sync, since the bookmark IS the membership.
    final next = state.where((e) => e != id).toList();
    state = next;
    await _repo.saveWarmupOrder(next);
  }
}

/// Resolved [Challenge] list for the saved warm-up, in the user's order.
final savedWarmupChallengesProvider =
    Provider<AsyncValue<List<Challenge>>>((ref) {
  final order = ref.watch(savedWarmupOrderProvider);
  final catalogAsync = ref.watch(challengeCatalogProvider);
  return catalogAsync.whenData((catalog) {
    final byId = {for (final c in catalog) c.id: c};
    return [
      for (final id in order)
        if (byId[id] != null) byId[id]!,
    ];
  });
});
