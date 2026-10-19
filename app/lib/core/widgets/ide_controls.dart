import 'package:flutter/material.dart';

import '../theme/ide_colors.dart';
import '../theme/ide_theme.dart';

class IdeButton extends StatelessWidget {
  const IdeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final enabled = onPressed != null;
    final textColor = primary
        ? Colors.white
        : enabled
        ? colors.text
        : colors.comment;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 28,
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary
                ? colors.accent.withValues(alpha: enabled ? 1 : 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: primary ? null : Border.all(color: colors.lineNumber),
          ),
          child: Text(
            label,
            style: IdeTheme.ui(colors)
                .copyWith(fontSize: 13, height: 1, color: textColor),
          ),
        ),
      ),
    );
  }
}

class IdeCheckbox extends StatelessWidget {
  const IdeCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: value ? colors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: value ? null : Border.all(color: colors.comment),
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class IdeComboBox<T> extends StatelessWidget {
  const IdeComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.width = 180,
  });

  final T value;
  final List<T> items;
  final String Function(T item) labelOf;
  final ValueChanged<T>? onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final enabled = onChanged != null;
    final style = IdeTheme.ui(colors).copyWith(
      fontSize: 13,
      height: 1,
      color: enabled ? colors.text : colors.comment,
    );

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.panel),
        elevation: const WidgetStatePropertyAll(4),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: colors.lineNumber),
          ),
        ),
      ),
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(width - 8, 28)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 10),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.focused)
                    ? colors.selection
                    : Colors.transparent,
              ),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
            onPressed: () => onChanged?.call(item),
            child: Text(labelOf(item), style: style),
          ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled
              ? () => controller.isOpen ? controller.close() : controller.open()
              : null,
          child: Container(
            width: width,
            height: 28,
            padding: const EdgeInsets.only(left: 10, right: 6),
            decoration: BoxDecoration(
              color: colors.editorBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: controller.isOpen ? colors.accent : colors.lineNumber,
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text(labelOf(value), style: style)),
                Icon(Icons.expand_more, size: 16, color: colors.comment),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
