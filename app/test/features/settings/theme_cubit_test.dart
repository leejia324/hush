import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/settings/domain/settings_repository.dart';
import 'package:hush/features/settings/domain/theme_preference.dart';
import 'package:hush/features/settings/presentation/theme_cubit.dart';

import '../../support/memory_settings_repository.dart';

class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<ThemePreference> loadTheme() async => ThemePreference.system;

  @override
  Future<void> saveTheme(ThemePreference theme) async =>
      throw Exception('disk');

  @override
  Future<String?> loadLockImagePath() async => null;

  @override
  Future<void> saveLockImagePath(String? path) async {}
}

void main() {
  test('저장에 성공하면 테마가 바뀜', () async {
    final repository = MemorySettingsRepository();
    final cubit = ThemeCubit(repository);
    addTearDown(cubit.close);

    await cubit.select(ThemePreference.dark);

    expect(cubit.state, ThemePreference.dark);
    expect(repository.saved, ThemePreference.dark);
  });

  test('저장에 실패하면 테마가 그대로', () async {
    final cubit = ThemeCubit(_FailingSettingsRepository());
    addTearDown(cubit.close);

    await expectLater(cubit.select(ThemePreference.dark), throwsException);

    expect(cubit.state, ThemePreference.system);
  });
}
