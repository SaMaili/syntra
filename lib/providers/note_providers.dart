import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/logbook_repository.dart';
import 'statistics_providers.dart';

/// Provides the most recent note (with timestamp) for a specific challenge.
/// Returns null if no notes exist for this challenge.
final lastNoteProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, challengeId) async {
    ref.watch(statisticsRefreshProvider);
    return LogbookRepository.instance.lastNotesForChallenge(challengeId);
  },
);
