import 'theme_preference.dart';

abstract interface class SettingsRepository {
  Future<ThemePreference> loadTheme();

  Future<void> saveTheme(ThemePreference theme);
}
