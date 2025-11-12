import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._preferences);

  static const _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  @override
  Future<bool> isOnboardingCompleted() async {
    return _preferences.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _preferences.setBool(_onboardingCompletedKey, true);
  }
}

