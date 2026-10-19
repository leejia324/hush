import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_repository.dart';
import '../domain/theme_preference.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _themeKey = 'theme';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ThemePreference> loadTheme() async {
    final saved = await _preferences.getString(_themeKey);
    return ThemePreference.values.firstWhere(
      (theme) => theme.name == saved,
      orElse: () => ThemePreference.system,
    );
  }

  @override
  Future<void> saveTheme(ThemePreference theme) =>
      _preferences.setString(_themeKey, theme.name);
}
