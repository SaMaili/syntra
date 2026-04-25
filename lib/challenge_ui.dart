import 'package:flutter/material.dart';

import 'challenge.dart';
import 'generated/l10n.dart';

/// UI helpers for [Challenge] — icons, labels, and display formatting.
/// Kept separate from [Challenge] to avoid importing Flutter into the data layer.
extension ChallengeDisplay on Challenge {
  IconData get typeIcon => switch (type) {
        ChallengeType.group => Icons.group_outlined,
        ChallengeType.coop => Icons.people_alt_outlined,
        ChallengeType.dare => Icons.bolt_outlined,
        _ => Icons.person_outlined,
      };

  String typeLabel(S l) => switch (type) {
        ChallengeType.group => l.group,
        ChallengeType.coop => l.coop,
        ChallengeType.dare => l.dare,
        _ => l.solo,
      };

  String environmentLabel(S l) => switch (environment) {
        ChallengeEnvironment.street => l.filterEnvStreet,
        ChallengeEnvironment.transit => l.filterEnvTransit,
        ChallengeEnvironment.cafe => l.filterEnvCafe,
        ChallengeEnvironment.event => l.filterEnvEvent,
        _ => '',
      };
}
