import 'package:flutter/material.dart';

class HiddenSecret extends StatelessWidget {
  const HiddenSecret({
    super.key,
    required this.text,
    required this.style,
    required this.color,
  });

  final String text;
  final TextStyle style;
  final Color color;

  static Size measure(String text, TextStyle style, TextScaler textScaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final size = measure(
      text,
      style.copyWith(height: 1.2),
      MediaQuery.textScalerOf(context),
    );
    return Semantics(
      label: '가려진 내용',
      excludeSemantics: true,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
