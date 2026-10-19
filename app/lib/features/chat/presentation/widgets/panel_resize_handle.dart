import 'package:flutter/material.dart';

class PanelResizeHandle extends StatelessWidget {
  const PanelResizeHandle({
    super.key,
    required this.onDrag,
    required this.onDragEnd,
    this.axis = Axis.horizontal,
  });

  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final horizontal = axis == Axis.horizontal;
    return MouseRegion(
      cursor: horizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: horizontal
            ? (details) => onDrag(details.delta.dx)
            : null,
        onHorizontalDragEnd: horizontal ? (_) => onDragEnd() : null,
        onVerticalDragUpdate: horizontal
            ? null
            : (details) => onDrag(details.delta.dy),
        onVerticalDragEnd: horizontal ? null : (_) => onDragEnd(),
        child: horizontal
            ? const SizedBox(width: 6)
            : const SizedBox(height: 6, width: double.infinity),
      ),
    );
  }
}
