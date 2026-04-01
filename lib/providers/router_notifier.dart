import 'package:flutter/foundation.dart';

/// Tells GoRouter to re-evaluate its redirect whenever the onboarding status
/// changes. Initialized in main() after reading SharedPreferences so the
/// router has the correct initial location without an async redirect.
class RouterNotifier extends ChangeNotifier {
  bool _onboardingComplete;

  RouterNotifier(this._onboardingComplete);

  bool get onboardingComplete => _onboardingComplete;

  void completeOnboarding() {
    if (_onboardingComplete) return;
    _onboardingComplete = true;
    notifyListeners();
  }
}

// Initialized in main() before runApp().
late final RouterNotifier routerNotifier;
