import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/settings_repository.dart';
import '../domain/theme_preference.dart';

class ThemeCubit extends Cubit<ThemePreference> {
  ThemeCubit(
    this._repository, {
    ThemePreference initial = ThemePreference.system,
  }) : super(initial);

  final SettingsRepository _repository;

  Future<void> select(ThemePreference theme) async {
    if (theme == state) return;
    await _repository.saveTheme(theme);
    if (!isClosed) emit(theme);
  }
}

extension ThemePreferenceMode on ThemePreference {
  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.light => ThemeMode.light,
  };
}
