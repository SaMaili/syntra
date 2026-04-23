import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider used to trigger a "scroll to top" action on the challenges screen.
/// Incrementing this value indicates a new request.
final challengesScrollToTopProvider = StateProvider<int>((ref) => 0);
