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
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7F52FF), Color(0xFFC711E1), Color(0xFFE44857)],
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
        FileTreeIconType.kotlin => const _Badge(
          label: 'K',
          gradient: _kotlinGradient,
        ),
        FileTreeIconType.kotlinScript => const _Badge(
          label: 'S',
          gradient: _kotlinGradient,
        ),
        FileTreeIconType.markdown => _Markdown(color: colors.comment),
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.gradient});

  final String label;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
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
