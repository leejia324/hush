import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';

class TerminalComposer extends StatefulWidget {
  const TerminalComposer({super.key, required this.onSend, this.height = 240});

  final ValueChanged<String> onSend;
  final double height;

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
    final code = IdeTheme.editor(colors).copyWith(fontSize: 13);
    final ui = IdeTheme.ui(colors).copyWith(fontSize: 13, height: 1);
    final divider = Theme.of(context).dividerColor;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.editorBackground,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Text('터미널', style: ui.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 20),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: colors.accent, width: 2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('로컬', style: ui),
                      const SizedBox(width: 8),
                      Icon(Icons.close, size: 12, color: colors.comment),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.add, size: 16, color: colors.comment),
                const Spacer(),
                Icon(Icons.more_vert, size: 16, color: colors.comment),
                const SizedBox(width: 12),
                Icon(Icons.remove, size: 16, color: colors.comment),
                const SizedBox(width: 12),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      for (final icon in const [
                        Icons.splitscreen_outlined,
                        Icons.history,
                        Icons.delete_outline,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Icon(icon, size: 16, color: colors.comment),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ListView(
                            reverse: true,
                            children: [
                              for (final line in _history.reversed)
                                Text(
                                  line,
                                  style: code.copyWith(color: colors.text),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(_prompt(code, colors)),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _history = [
    'Last login: Sun Oct 19 09:12:44 on ttys003',
    'study-notes git:(main) ❯ ./gradlew test',
    '',
    'BUILD SUCCESSFUL in 4s',
    '7 actionable tasks: 2 executed, 5 up-to-date',
  ];

  TextSpan _prompt(TextStyle code, IdeColors colors) {
    return TextSpan(
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
            style: IdeTheme.ui(colors)
                .copyWith(color: colors.comment, fontSize: 12, height: 1),
          ),
        ),
      ),
    );
  }
}
