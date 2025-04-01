import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/data/settings/settings_helper.dart';

class ThemeCubit extends Cubit<bool> {
  final SettingsHelper _settings;

  ThemeCubit(this._settings) : super(_settings.getThemeMode() == 'dark') {
    // Initialize with saved theme mode
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDarkMode = _settings.getThemeMode() == 'dark';
    emit(isDarkMode);
  }

  Future<void> toggleTheme() async {
    final isDarkMode = !state;
    await _settings.setThemeMode(isDarkMode ? 'dark' : 'light');
    emit(isDarkMode);
  }

  bool get isDarkMode => state;
}
