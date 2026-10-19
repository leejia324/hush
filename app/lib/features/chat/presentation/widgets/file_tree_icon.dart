import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';

enum FileTreeIconType {
  module,
  folder,
  sourceFolder,
  packageFolder,
  configFolder,
  kotlin,
  kotlinScript,
  markdown,
}

class FileTreeIcon extends StatelessWidget {
  const FileTreeIcon(this.type, {super.key});

  static const size = 14.0;

  static const _kotlinGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF2FB5A3), Color(0xFF3574F0), Color(0xFF6B5CF6)],
  );

  final FileTreeIconType type;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return SizedBox.square(
      dimension: size,
      child: switch (type) {
        FileTreeIconType.module => _Folder(
          color: colors.comment,
          badge: colors.accent,
        ),
        FileTreeIconType.folder => _Folder(color: colors.comment),
        FileTreeIconType.sourceFolder => _Folder(color: colors.accent),
        FileTreeIconType.packageFolder => _Folder(
          color: colors.comment,
          dot: colors.editorBackground,
        ),
        FileTreeIconType.configFolder => _Folder(
          color: colors.comment.withValues(alpha: 0.55),
        ),
        FileTreeIconType.kotlin || FileTreeIconType.kotlinScript =>
          const CustomPaint(painter: _KotlinMarkPainter(_kotlinGradient)),
        FileTreeIconType.markdown => _Markdown(color: colors.comment),
      },
    );
  }
}

class _Markdown extends StatelessWidget {
  const _Markdown({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          'M↓',
          style: TextStyle(
            fontSize: 6,
            height: 1,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Folder extends StatelessWidget {
  const _Folder({required this.color, this.badge, this.dot});

  final Color color;
  final Color? badge;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FolderPainter(color: color, badge: badge, dot: dot),
    );
  }
}

class _FolderPainter extends CustomPainter {
  _FolderPainter({required this.color, this.badge, this.dot});

  final Color color;
  final Color? badge;
  final Color? dot;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 14;
    final fill = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromLTRBR(
        1 * unit,
        2 * unit,
        6.5 * unit,
        5 * unit,
        Radius.circular(1 * unit),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        1 * unit,
        3.5 * unit,
        13 * unit,
        12 * unit,
        Radius.circular(1.5 * unit),
      ),
      fill,
    );

    final dot = this.dot;
    if (dot != null) {
      canvas.drawCircle(
        Offset(7 * unit, 7.75 * unit),
        1.6 * unit,
        Paint()..color = dot,
      );
    }

    final badge = this.badge;
    if (badge != null) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          8 * unit,
          7.5 * unit,
          14 * unit,
          13.5 * unit,
          Radius.circular(1 * unit),
        ),
        Paint()..color = badge,
      );
    }
  }

  @override
  bool shouldRepaint(_FolderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.badge != badge ||
      oldDelegate.dot != dot;
}

class _KotlinMarkPainter extends CustomPainter {
  const _KotlinMarkPainter(this.gradient);

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.07;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.center.dx, rect.center.dy)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    canvas.drawPath(path, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_KotlinMarkPainter oldDelegate) =>
      oldDelegate.gradient != gradient;
}
