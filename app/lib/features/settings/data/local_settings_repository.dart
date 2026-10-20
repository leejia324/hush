import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_repository.dart';
import '../domain/theme_preference.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _themeKey = 'theme';
  static const _lockImageKey = 'lockImagePath';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ThemePreference> loadTheme() async {
    try {
      final saved = await _preferences.getString(_themeKey);
      return ThemePreference.values.firstWhere(
        (theme) => theme.name == saved,
        orElse: () => ThemePreference.system,
      );
    } catch (_) {
      return ThemePreference.system;
    }
  }

  @override
  Future<void> saveTheme(ThemePreference theme) =>
      _preferences.setString(_themeKey, theme.name);

  @override
  Future<String?> loadLockImagePath() async {
    try {
      return await _preferences.getString(_lockImageKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLockImagePath(String? path) => path == null
      ? _preferences.remove(_lockImageKey)
      : _preferences.setString(_lockImageKey, path);
}
