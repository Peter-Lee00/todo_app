import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  static final SettingsHelper instance = SettingsHelper._init();
  static SharedPreferences? _prefs;

  SettingsHelper._init();

  // Initialize settings
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme mode
  Future<void> setThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'light';
  }

  // Selected date
  Future<void> setSelectedDate(String date) async {
    await _prefs?.setString('selected_date', date);
  }

  String? getSelectedDate() {
    return _prefs?.getString('selected_date');
  }

  // Selected mood
  Future<void> setSelectedMood(String mood) async {
    await _prefs?.setString('selected_mood', mood);
  }

  String getSelectedMood() {
    return _prefs?.getString('selected_mood') ?? 'sentiment_satisfied';
  }

  // Clear all settings
  Future<void> clearSettings() async {
    await _prefs?.clear();
  }
}
