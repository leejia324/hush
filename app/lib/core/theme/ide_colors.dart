import 'package:flutter/material.dart';

@immutable
class IdeColors extends ThemeExtension<IdeColors> {
  const IdeColors({
    required this.editorBackground,
    required this.panel,
    required this.text,
    required this.lineNumber,
    required this.string,
    required this.keyword,
    required this.function,
    required this.property,
    required this.comment,
    required this.todo,
    required this.selection,
    required this.revealedSecret,
    required this.accent,
    required this.people,
  });

  static const dark = IdeColors(
    editorBackground: Color(0xFF1E1F22),
    panel: Color(0xFF2B2D30),
    text: Color(0xFFDFE1E5),
    lineNumber: Color(0xFF4B5059),
    string: Color(0xFF6AAB73),
    keyword: Color(0xFFCF8E6D),
    function: Color(0xFF56A8F5),
    property: Color(0xFFC77DBB),
    comment: Color(0xFF7A7E85),
    todo: Color(0xFFA8C023),
    selection: Color(0xFF2E436E),
    revealedSecret: Color(0xFF4A4426),
    accent: Color(0xFF3574F0),
    people: [
      Color(0xFF7FB1F7),
      Color(0xFFE0A46E),
      Color(0xFF5FC4B0),
      Color(0xFFC79BE8),
    ],
  );

  static const light = IdeColors(
    editorBackground: Color(0xFFFFFFFF),
    panel: Color(0xFFF7F8FA),
    text: Color(0xFF1F2023),
    lineNumber: Color(0xFFAEB3C2),
    string: Color(0xFF067D17),
    keyword: Color(0xFF0033B3),
    function: Color(0xFF00627A),
    property: Color(0xFF871094),
    comment: Color(0xFF8C8C8C),
    todo: Color(0xFF008DDE),
    selection: Color(0xFFD5E1FF),
    revealedSecret: Color(0xFFFFF0A8),
    accent: Color(0xFF3574F0),
    people: [
      Color(0xFF2763D6),
      Color(0xFFB05A12),
      Color(0xFF0B7F69),
      Color(0xFF8343C2),
    ],
  );

  final Color editorBackground;
  final Color panel;
  final Color text;
  final Color lineNumber;
  final Color string;
  final Color keyword;
  final Color function;
  final Color property;
  final Color comment;
  final Color todo;
  final Color selection;
  final Color revealedSecret;
  final Color accent;
  final List<Color> people;

  Color person(int colorIndex) => people[colorIndex % people.length];

  static IdeColors of(BuildContext context) =>
      Theme.of(context).extension<IdeColors>()!;

  @override
  IdeColors copyWith({
    Color? editorBackground,
    Color? panel,
    Color? text,
    Color? lineNumber,
    Color? string,
    Color? keyword,
    Color? function,
    Color? property,
    Color? comment,
    Color? todo,
    Color? selection,
    Color? revealedSecret,
    Color? accent,
    List<Color>? people,
  }) {
    return IdeColors(
      editorBackground: editorBackground ?? this.editorBackground,
      panel: panel ?? this.panel,
      text: text ?? this.text,
      lineNumber: lineNumber ?? this.lineNumber,
      string: string ?? this.string,
      keyword: keyword ?? this.keyword,
      function: function ?? this.function,
      property: property ?? this.property,
      comment: comment ?? this.comment,
      todo: todo ?? this.todo,
      selection: selection ?? this.selection,
      revealedSecret: revealedSecret ?? this.revealedSecret,
      accent: accent ?? this.accent,
      people: people ?? this.people,
    );
  }

  @override
  IdeColors lerp(IdeColors? other, double t) {
    if (other == null) return this;
    return IdeColors(
      editorBackground: Color.lerp(
        editorBackground,
        other.editorBackground,
        t,
      )!,
      panel: Color.lerp(panel, other.panel, t)!,
      text: Color.lerp(text, other.text, t)!,
      lineNumber: Color.lerp(lineNumber, other.lineNumber, t)!,
      string: Color.lerp(string, other.string, t)!,
      keyword: Color.lerp(keyword, other.keyword, t)!,
      function: Color.lerp(function, other.function, t)!,
      property: Color.lerp(property, other.property, t)!,
      comment: Color.lerp(comment, other.comment, t)!,
      todo: Color.lerp(todo, other.todo, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      revealedSecret: Color.lerp(revealedSecret, other.revealedSecret, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      people: [
        for (var i = 0; i < people.length; i++)
          Color.lerp(people[i], other.person(i), t)!,
      ],
    );
  }
}
