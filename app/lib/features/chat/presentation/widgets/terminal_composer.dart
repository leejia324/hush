import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';

class TerminalComposer extends StatefulWidget {
  const TerminalComposer({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<TerminalComposer> createState() => _TerminalComposerState();
}

class _TerminalComposerState extends State<TerminalComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _wrap(String marker) {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) return;

    final selected = selection.textInside(value.text);
    final replaced = value.text.replaceRange(
      selection.start,
      selection.end,
      '$marker$selected$marker',
    );
    final cursor = selected.isEmpty
        ? selection.start + marker.length
        : selection.end + marker.length * 2;
    _controller.value = TextEditingValue(
      text: replaced,
      selection: selected.isEmpty
          ? TextSelection.collapsed(offset: cursor)
          : TextSelection(baseOffset: selection.start, extentOffset: cursor),
    );
    _focusNode.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        !keyboard.isShiftPressed) {
      if (_controller.value.composing.isValid &&
          !_controller.value.composing.isCollapsed) {
        return KeyEventResult.ignored;
      }
      _send();
      return KeyEventResult.handled;
    }
    if (!keyboard.isMetaPressed) return KeyEventResult.ignored;

    final marker = switch (event.logicalKey) {
      LogicalKeyboardKey.keyH when keyboard.isShiftPressed => '||',
      LogicalKeyboardKey.keyX when keyboard.isShiftPressed => '~~',
      LogicalKeyboardKey.keyB => '**',
      LogicalKeyboardKey.keyI => '*',
      _ => null,
    };
    if (marker == null) return KeyEventResult.ignored;
    _wrap(marker);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final code = IdeTheme.code(colors);

    return Container(
      decoration: BoxDecoration(
        color: colors.editorBackground,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            color: colors.panel,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Text('Terminal', style: code.copyWith(fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'study-notes ',
                          style: code.copyWith(color: colors.function),
                        ),
                        TextSpan(
                          text: 'git:(',
                          style: code.copyWith(color: colors.keyword),
                        ),
                        TextSpan(
                          text: 'main',
                          style: code.copyWith(color: colors.property),
                        ),
                        TextSpan(
                          text: ') ❯ ',
                          style: code.copyWith(color: colors.keyword),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      minLines: 1,
                      maxLines: 5,
                      style: code,
                      cursorColor: colors.text,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                _FormatButton(
                  label: 'B',
                  tooltip: '굵게 ⌘B',
                  onTap: () => _wrap('**'),
                ),
                _FormatButton(
                  label: 'I',
                  tooltip: '기울임 ⌘I',
                  onTap: () => _wrap('*'),
                ),
                _FormatButton(
                  label: 'S',
                  tooltip: '취소선 ⌘⇧X',
                  onTap: () => _wrap('~~'),
                ),
                _FormatButton(
                  label: '...',
                  tooltip: '비밀 ⌘⇧H',
                  onTap: () => _wrap('||'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 24,
          alignment: Alignment.center,
          child: Text(
            label,
            style: IdeTheme.code(colors)
                .copyWith(color: colors.comment, fontSize: 12, height: 1),
          ),
        ),
      ),
    );
  }
}
