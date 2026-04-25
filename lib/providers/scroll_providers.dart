import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrementing any of these triggers a "scroll to top" on the corresponding tab.
final challengesScrollToTopProvider = StateProvider<int>((ref) => 0);
final dailyScrollToTopProvider     = StateProvider<int>((ref) => 0);
final profileScrollToTopProvider   = StateProvider<int>((ref) => 0);
final settingsScrollToTopProvider  = StateProvider<int>((ref) => 0);
