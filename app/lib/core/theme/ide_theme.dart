import 'package:flutter/material.dart';

import 'ide_colors.dart';

abstract final class IdeTheme {
  static const codeFontSize = 14.0;
  static const lineHeight = 24.0;
  static const editorFontFamily = 'D2Coding';

  static ThemeData dark() => _build(Brightness.dark, IdeColors.dark);

  static ThemeData light() => _build(Brightness.light, IdeColors.light);

  static TextStyle ui(IdeColors colors) => TextStyle(
    fontSize: codeFontSize,
    height: lineHeight / codeFontSize,
    color: colors.text,
  );

  static TextStyle editor(IdeColors colors) =>
      ui(colors).copyWith(fontFamily: editorFontFamily);

  static ThemeData _build(Brightness brightness, IdeColors colors) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.editorBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
        surface: colors.panel,
      ),
      dividerColor: colors.lineNumber.withValues(alpha: 0.4),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.text,
        selectionColor: colors.selection,
      ),
      extensions: [colors],
    );
  }
}
