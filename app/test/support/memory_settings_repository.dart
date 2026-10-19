import 'package:hush/features/settings/domain/settings_repository.dart';
import 'package:hush/features/settings/domain/theme_preference.dart';

class MemorySettingsRepository implements SettingsRepository {
  ThemePreference saved = ThemePreference.system;

  @override
  Future<ThemePreference> loadTheme() async => saved;

  @override
  Future<void> saveTheme(ThemePreference theme) async => saved = theme;
}
