import 'package:flutter/material.dart';

import '../../../../core/theme/ide_colors.dart';
import '../../../../core/theme/ide_theme.dart';
import '../conversation/code_line.dart';
import 'hidden_secret.dart';
import 'secret_press.dart';

class ConversationView extends StatefulWidget {
  const ConversationView({super.key, required this.lines});

  final List<CodeLine> lines;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToEnd();
  }

  @override
  void didUpdateWidget(ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lines.length != widget.lines.length) _scrollToEnd();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMessage(widget.lines);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        if (!group.hasSecret) {
          return _LineGroup(group: group, revealed: false);
        }
        return SecretPress(
          builder: (context, revealed) =>
              _LineGroup(group: group, revealed: revealed),
        );
      },
    );
  }

  List<_Group> _groupByMessage(List<CodeLine> lines) {
    final groups = <_Group>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final last = groups.isEmpty ? null : groups.last;
      if (line.messageId != null &&
          last != null &&
          last.messageId == line.messageId) {
        last.lines.add(line);
      } else {
        groups.add(_Group(i + 1, line.messageId, [line]));
      }
    }
    return groups;
  }
}

class _Group {
  _Group(this.firstLineNumber, this.messageId, this.lines);

  final int firstLineNumber;
  final String? messageId;
  final List<CodeLine> lines;

  bool get hasSecret =>
      lines.any((line) => line.tokens.any((token) => token.secret));
}

class _LineGroup extends StatelessWidget {
  const _LineGroup({required this.group, required this.revealed});

  final _Group group;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < group.lines.length; i++)
          _CodeLineRow(
            number: group.firstLineNumber + i,
            line: group.lines[i],
            revealed: revealed,
          ),
      ],
    );
  }
}

class _CodeLineRow extends StatelessWidget {
  const _CodeLineRow({
    required this.number,
    required this.line,
    required this.revealed,
  });

  final int number;
  final CodeLine line;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    final base = IdeTheme.editor(colors);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: IdeTheme.lineHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$number',
              textAlign: TextAlign.right,
              style: base.copyWith(color: colors.lineNumber),
            ),
          ),
          SizedBox(
            width: 24,
            height: IdeTheme.lineHeight,
            child: line.runnable
                ? Icon(Icons.play_arrow, size: 15, color: colors.string)
                : null,
          ),
          Container(
            width: 3,
            height: IdeTheme.lineHeight,
            color: line.changed ? colors.accent : Colors.transparent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomPaint(
              painter: _IndentGuidePainter(
                indent: line.indent,
                spaceWidth: _spaceWidth(base),
                color: colors.lineNumber.withValues(alpha: 0.35),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: line.indent * _spaceWidth(base)),
                child: Text.rich(
                  TextSpan(
                    children: [
                      for (final token in _withoutIndent(line))
                        _span(token, base, colors),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Iterable<CodeToken> _withoutIndent(CodeLine line) sync* {
    var remaining = line.indent;
    for (final token in line.tokens) {
      if (remaining == 0) {
        yield token;
        continue;
      }
      final skip = remaining.clamp(0, token.text.length);
      remaining -= skip;
      if (skip < token.text.length) {
        yield CodeToken(
          token.text.substring(skip),
          token.kind,
          secret: token.secret,
          bold: token.bold,
          italic: token.italic,
          strike: token.strike,
        );
      }
    }
  }

  static double _spaceWidth(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  InlineSpan _span(CodeToken token, TextStyle base, IdeColors colors) {
    final style = base.copyWith(
      color: _color(token, colors),
      fontWeight: token.bold ? FontWeight.bold : null,
      fontStyle: token.italic ? FontStyle.italic : null,
      decoration: token.strike ? TextDecoration.lineThrough : null,
    );

    if (!token.secret) return TextSpan(text: token.text, style: style);

    if (revealed) {
      return TextSpan(
        text: token.text,
        style: style.copyWith(backgroundColor: colors.revealedSecret),
      );
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: HiddenSecret(
        text: token.text,
        style: style,
        color: colors.lineNumber.withValues(alpha: 0.35),
      ),
    );
  }

  Color _color(CodeToken token, IdeColors colors) {
    return switch (token.kind) {
      CodeTokenKind.plain => colors.text,
      CodeTokenKind.keyword => colors.keyword,
      CodeTokenKind.function => colors.function,
      CodeTokenKind.string => colors.string,
      CodeTokenKind.escape => colors.escape,
      CodeTokenKind.number => colors.number,
      CodeTokenKind.comment => colors.comment,
      CodeTokenKind.todo => colors.todo,
    };
  }
}

class _IndentGuidePainter extends CustomPainter {
  _IndentGuidePainter({
    required this.indent,
    required this.spaceWidth,
    required this.color,
  });

  static const _step = 4;

  final int indent;
  final double spaceWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var level = 0; level < indent ~/ _step; level++) {
      final x = level * _step * spaceWidth + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_IndentGuidePainter oldDelegate) =>
      oldDelegate.indent != indent ||
      oldDelegate.spaceWidth != spaceWidth ||
      oldDelegate.color != color;
}
