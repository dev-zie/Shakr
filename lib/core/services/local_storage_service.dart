import 'package:shared_preferences/shared_preferences.dart';
import 'package:shakr/common/constants/app_enums.dart';

class LocalStorageService {
  static const _onboardingKey = 'onboarding_completed';
  static const _sensitivityKey = 'shake_sensitivity';
  static const _darkModeKey = 'dark_mode';

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }

  Future<ShakeSensitivity> getSensitivity() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_sensitivityKey);
    return ShakeSensitivity.values.firstWhere(
      (s) => s.name == name,
      orElse: () => ShakeSensitivity.normal,
    );
  }

  Future<void> setSensitivity(ShakeSensitivity sensitivity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sensitivityKey, sensitivity.name);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }
}
