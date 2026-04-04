import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the app-wide [SharedPreferences] instance.
///
/// Must be overridden at the [ProviderScope] root before the widget tree is
/// built. In tests, override with a [FakeSharedPreferences] or an in-memory
/// instance to keep tests hermetic and fast.
///
/// ```dart
/// // main.dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(ProviderScope(
///   overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///   child: const SyntraApp(),
/// ));
///
/// // test
/// await tester.pumpWidget(ProviderScope(
///   overrides: [sharedPreferencesProvider.overrideWithValue(fakePrefs)],
///   child: const SyntraApp(),
/// ));
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);
