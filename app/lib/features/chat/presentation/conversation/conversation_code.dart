import '../../domain/member.dart';
import '../../domain/message.dart';
import '../../domain/message_segment.dart';
import '../../domain/secret_syntax_parser.dart';
import 'code_line.dart';

enum TurnShape { declaration, scope, list, condition, entry, check }

abstract final class ConversationCode {
  static const _member = '    ';
  static const _body = '        ';
  static const _nested = '            ';
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _listNames = [
    'items',
    'lines',
    'rows',
    'steps',
    'entries',
    'args',
    'values',
    'buffer',
    'queue',
    'pending',
    'result',
    'payload',
  ];

  static List<CodeLine> build({
    required String roomName,
    required List<Member> members,
    required List<Message> messages,
    DateTime? newMessagesAfter,
  }) {
    final nicknames = {
      for (final member in members) member.id: member.nickname,
    };
    final lines = <CodeLine>[
      const CodeLine([
        CodeToken('package', CodeTokenKind.keyword),
        CodeToken(' notes.rooms', CodeTokenKind.plain),
      ]),
      CodeLine.blank,
      const CodeLine([
        CodeToken('import', CodeTokenKind.keyword),
        CodeToken(' notes.core.*', CodeTokenKind.plain),
      ]),
      CodeLine.blank,
      CodeLine([
        const CodeToken('class', CodeTokenKind.keyword),
        CodeToken(' $roomName : ', CodeTokenKind.plain),
        const CodeToken('Room', CodeTokenKind.plain),
        const CodeToken('() {', CodeTokenKind.plain),
      ], runnable: true),
      CodeLine.blank,
      CodeLine([
        const CodeToken(_member, CodeTokenKind.plain),
        const CodeToken('override val', CodeTokenKind.keyword),
        const CodeToken(' members = ', CodeTokenKind.plain),
        const CodeToken('listOf', CodeTokenKind.function),
        CodeToken(
          '(${members.map((member) => member.nickname).join(', ')})',
          CodeTokenKind.plain,
        ),
      ]),
    ];

    var changed = false;
    final recentShapes = <TurnShape>[];

    for (final day in _groupByDay(messages)) {
      lines
        ..add(CodeLine([], changed: changed))
        ..add(
          CodeLine([
            const CodeToken(_member, CodeTokenKind.plain),
            CodeToken('// ${_dayLabel(day.date)}', CodeTokenKind.comment),
          ], changed: changed),
        )
        ..add(
          CodeLine([
            const CodeToken(_member, CodeTokenKind.plain),
            const CodeToken('fun', CodeTokenKind.keyword),
            const CodeToken(' ', CodeTokenKind.plain),
            CodeToken(
              'day${_two(day.date.month)}${_two(day.date.day)}',
              CodeTokenKind.function,
            ),
            const CodeToken('() {', CodeTokenKind.plain),
          ], changed: changed),
        );

      final items = _groupTurns(day.messages, newMessagesAfter);
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is _Marker) {
          if (i > 0) lines.add(CodeLine([], changed: changed));
          lines.add(
            const CodeLine([
              CodeToken(_body, CodeTokenKind.plain),
              CodeToken('// TODO: 새 메시지', CodeTokenKind.todo),
            ]),
          );
          changed = true;
          continue;
        }
        if (i > 0 && items[i - 1] is! _Marker) {
          lines.add(CodeLine([], changed: changed));
        }
        switch (item) {
          case _System(:final message):
            lines.addAll(_system(message, changed));
          case _Turn(:final sender, :final messages):
            final shape = _shapeFor(messages.first.id, recentShapes);
            recentShapes
              ..add(shape)
              ..removeRange(
                0,
                recentShapes.length > 2 ? recentShapes.length - 2 : 0,
              );
            lines.addAll(_turn(shape, sender(nicknames), messages, changed));
          case _Marker():
            break;
        }
      }

      lines.add(
        CodeLine(const [
          CodeToken(_member, CodeTokenKind.plain),
          CodeToken('}', CodeTokenKind.plain),
        ], changed: changed),
      );
    }

    lines.add(const CodeLine([CodeToken('}', CodeTokenKind.plain)]));
    return lines;
  }

  static TurnShape _shapeFor(String messageId, List<TurnShape> recent) {
    final shapes = TurnShape.values;
    var shape = shapes[_stableHash(messageId) % shapes.length];
    while (recent.contains(shape)) {
      shape = shapes[(shape.index + 1) % shapes.length];
    }
    return shape;
  }

  static List<CodeLine> _turn(
    TurnShape shape,
    String sender,
    List<Message> messages,
    bool changed,
  ) {
    CodeLine line(List<CodeToken> tokens) => CodeLine(tokens, changed: changed);

    List<CodeToken> at(DateTime time) => [
      const CodeToken('at', CodeTokenKind.function),
      const CodeToken('(', CodeTokenKind.plain),
      CodeToken('${time.hour}', CodeTokenKind.number),
      const CodeToken(', ', CodeTokenKind.plain),
      CodeToken('${time.minute}', CodeTokenKind.number),
      const CodeToken(')', CodeTokenKind.plain),
    ];

    switch (shape) {
      case TurnShape.declaration:
        final used = <String, int>{};
        return [
          for (final message in messages)
            ..._literal(
              message,
              indent: _body,
              before: [
                const CodeToken('val', CodeTokenKind.keyword),
                CodeToken(
                  ' ${_uniqueName('$sender${_hhmm(message.sentAt)}', used)} = ',
                  CodeTokenKind.plain,
                ),
              ],
              after: const [],
              changed: changed,
            ),
        ];
      case TurnShape.scope:
        return [
          line([
            const CodeToken(_body, CodeTokenKind.plain),
            CodeToken('$sender.', CodeTokenKind.plain),
            const CodeToken('run', CodeTokenKind.function),
            const CodeToken(' {', CodeTokenKind.plain),
          ]),
          for (final message in messages)
            ..._literal(
              message,
              indent: _nested,
              before: const [
                CodeToken('say', CodeTokenKind.function),
                CodeToken('(', CodeTokenKind.plain),
              ],
              after: [
                const CodeToken(', ', CodeTokenKind.plain),
                ...at(message.sentAt),
                const CodeToken(')', CodeTokenKind.plain),
              ],
              changed: changed,
            ),
          line(const [
            CodeToken(_body, CodeTokenKind.plain),
            CodeToken('}', CodeTokenKind.plain),
          ]),
        ];
      case TurnShape.list:
        final name =
            _listNames[_stableHash('${messages.first.id}name') %
                _listNames.length];
        return [
          line([
            const CodeToken(_body, CodeTokenKind.plain),
            const CodeToken('val', CodeTokenKind.keyword),
            CodeToken(' $name = ', CodeTokenKind.plain),
            const CodeToken('listOf', CodeTokenKind.function),
            const CodeToken('(', CodeTokenKind.plain),
          ]),
          for (final message in messages)
            ..._literal(
              message,
              indent: _nested,
              before: const [],
              after: [
                const CodeToken(',', CodeTokenKind.plain),
                CodeToken(
                  ' // ${_clock(message.sentAt)}',
                  CodeTokenKind.comment,
                ),
              ],
              changed: changed,
            ),
          line([
            const CodeToken('$_body)', CodeTokenKind.plain),
            CodeToken(' // $sender', CodeTokenKind.comment),
          ]),
        ];
      case TurnShape.condition:
        return [
          line([
            const CodeToken(_body, CodeTokenKind.plain),
            const CodeToken('if', CodeTokenKind.keyword),
            CodeToken(' ($sender.isOnline) {', CodeTokenKind.plain),
          ]),
          for (final message in messages)
            ..._literal(
              message,
              indent: _nested,
              before: const [
                CodeToken('reply', CodeTokenKind.function),
                CodeToken('(', CodeTokenKind.plain),
              ],
              after: [
                const CodeToken(', at = ', CodeTokenKind.plain),
                CodeToken('${message.sentAt.hour}', CodeTokenKind.number),
                const CodeToken(' ', CodeTokenKind.plain),
                const CodeToken('to', CodeTokenKind.function),
                const CodeToken(' ', CodeTokenKind.plain),
                CodeToken('${message.sentAt.minute}', CodeTokenKind.number),
                const CodeToken(')', CodeTokenKind.plain),
              ],
              changed: changed,
            ),
          line(const [
            CodeToken(_body, CodeTokenKind.plain),
            CodeToken('}', CodeTokenKind.plain),
          ]),
        ];
      case TurnShape.entry:
        return [
          for (final message in messages)
            ..._literal(
              message,
              indent: _body,
              before: [
                const CodeToken('notes[', CodeTokenKind.plain),
                CodeToken('"${_clock(message.sentAt)}"', CodeTokenKind.string),
                CodeToken('] = $sender ', CodeTokenKind.plain),
                const CodeToken('to', CodeTokenKind.function),
                const CodeToken(' ', CodeTokenKind.plain),
              ],
              after: const [],
              changed: changed,
            ),
        ];
      case TurnShape.check:
        return [
          for (final message in messages)
            ..._literal(
              message,
              indent: _body,
              before: [
                const CodeToken('check', CodeTokenKind.function),
                CodeToken('($sender.', CodeTokenKind.plain),
                const CodeToken('said', CodeTokenKind.function),
                const CodeToken('(', CodeTokenKind.plain),
              ],
              after: [
                const CodeToken(')) { ', CodeTokenKind.plain),
                CodeToken('"${_clock(message.sentAt)}"', CodeTokenKind.string),
                const CodeToken(' }', CodeTokenKind.plain),
              ],
              changed: changed,
            ),
        ];
    }
  }

  static List<CodeLine> _system(Message message, bool changed) {
    final parts = message.text.split(' → ');
    if (parts.length == 2) {
      return [
        CodeLine(
          [
            const CodeToken(_body, CodeTokenKind.plain),
            const CodeToken('rename', CodeTokenKind.function),
            const CodeToken('(from = ', CodeTokenKind.plain),
            const CodeToken('"', CodeTokenKind.string),
            ..._stringTokens(MessageSegment(parts[0])),
            const CodeToken('"', CodeTokenKind.string),
            const CodeToken(', to = ', CodeTokenKind.plain),
            const CodeToken('"', CodeTokenKind.string),
            ..._stringTokens(MessageSegment(parts[1])),
            const CodeToken('"', CodeTokenKind.string),
            const CodeToken(')', CodeTokenKind.plain),
            CodeToken(' // ${_clock(message.sentAt)}', CodeTokenKind.comment),
          ],
          messageId: message.id,
          changed: changed,
        ),
      ];
    }
    return _literal(
      message,
      indent: _body,
      before: const [
        CodeToken('notify', CodeTokenKind.function),
        CodeToken('(', CodeTokenKind.plain),
      ],
      after: [
        const CodeToken(')', CodeTokenKind.plain),
        CodeToken(' // ${_clock(message.sentAt)}', CodeTokenKind.comment),
      ],
      changed: changed,
    );
  }

  static List<CodeLine> _literal(
    Message message, {
    required String indent,
    required List<CodeToken> before,
    required List<CodeToken> after,
    required bool changed,
  }) {
    final segments = SecretSyntaxParser.parse(message.text);

    CodeLine line(List<CodeToken> tokens) =>
        CodeLine(tokens, messageId: message.id, changed: changed);

    if (!message.text.contains('\n')) {
      return [
        line([
          CodeToken(indent, CodeTokenKind.plain),
          ...before,
          const CodeToken('"', CodeTokenKind.string),
          for (final segment in segments) ..._stringTokens(segment),
          const CodeToken('"', CodeTokenKind.string),
          ...after,
        ]),
      ];
    }

    return [
      line([
        CodeToken(indent, CodeTokenKind.plain),
        ...before,
        const CodeToken('"""', CodeTokenKind.string),
      ]),
      for (final textLine in _splitLines(segments))
        line([
          CodeToken('$indent    ', CodeTokenKind.plain),
          for (final segment in textLine) ..._rawStringTokens(segment),
        ]),
      line([
        CodeToken(indent, CodeTokenKind.plain),
        const CodeToken('"""', CodeTokenKind.string),
        const CodeToken('.', CodeTokenKind.plain),
        const CodeToken('trimIndent', CodeTokenKind.function),
        const CodeToken('()', CodeTokenKind.plain),
        ...after,
      ]),
    ];
  }

  static List<_Day> _groupByDay(List<Message> messages) {
    final days = <_Day>[];
    for (final message in messages) {
      final date = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      if (days.isEmpty || days.last.date != date) {
        days.add(_Day(date, [message]));
      } else {
        days.last.messages.add(message);
      }
    }
    return days;
  }

  static List<_Item> _groupTurns(
    List<Message> messages,
    DateTime? newMessagesAfter,
  ) {
    final items = <_Item>[];
    var markerPlaced = newMessagesAfter == null;
    for (final message in messages) {
      if (!markerPlaced && message.sentAt.isAfter(newMessagesAfter!)) {
        items.add(const _Marker());
        markerPlaced = true;
      }
      if (message.isSystem) {
        items.add(_System(message));
        continue;
      }
      final last = items.isEmpty ? null : items.last;
      if (last is _Turn && last.senderId == message.senderId) {
        last.messages.add(message);
      } else {
        items.add(_Turn(message.senderId, [message]));
      }
    }
    return items;
  }

  static List<List<MessageSegment>> _splitLines(List<MessageSegment> segments) {
    final lines = <List<MessageSegment>>[[]];
    for (final segment in segments) {
      final parts = segment.text.split('\n');
      for (var p = 0; p < parts.length; p++) {
        if (p > 0) lines.add([]);
        if (parts[p].isEmpty) continue;
        lines.last.add(
          MessageSegment(
            parts[p],
            secret: segment.secret,
            bold: segment.bold,
            italic: segment.italic,
            strike: segment.strike,
          ),
        );
      }
    }
    return lines;
  }

  static Iterable<CodeToken> _rawStringTokens(MessageSegment segment) sync* {
    CodeToken token(String text, CodeTokenKind kind) => CodeToken(
      text,
      kind,
      secret: segment.secret,
      bold: segment.bold,
      italic: segment.italic,
      strike: segment.strike,
    );

    final text = segment.text;
    final buffer = StringBuffer();
    var i = 0;
    while (i < text.length) {
      final String escaped;
      final int consumed;
      if (text.startsWith('"""', i)) {
        buffer.write('""');
        escaped = r"""${'"'}""";
        consumed = 3;
      } else if (text[i] == r'$') {
        escaped = r"${'$'}";
        consumed = 1;
      } else {
        buffer.write(text[i]);
        i++;
        continue;
      }
      if (buffer.isNotEmpty) {
        yield token(buffer.toString(), CodeTokenKind.string);
        buffer.clear();
      }
      yield token(escaped, CodeTokenKind.escape);
      i += consumed;
    }
    if (buffer.isNotEmpty) {
      yield token(buffer.toString(), CodeTokenKind.string);
    }
  }

  static Iterable<CodeToken> _stringTokens(MessageSegment segment) sync* {
    final buffer = StringBuffer();

    CodeToken token(String text, CodeTokenKind kind) => CodeToken(
      text,
      kind,
      secret: segment.secret,
      bold: segment.bold,
      italic: segment.italic,
      strike: segment.strike,
    );

    for (final char in segment.text.split('')) {
      final escaped = switch (char) {
        '"' => r'\"',
        r'\' => r'\\',
        r'$' => r'\$',
        _ => null,
      };
      if (escaped == null) {
        buffer.write(char);
        continue;
      }
      if (buffer.isNotEmpty) {
        yield token(buffer.toString(), CodeTokenKind.string);
        buffer.clear();
      }
      yield token(escaped, CodeTokenKind.escape);
    }
    if (buffer.isNotEmpty) {
      yield token(buffer.toString(), CodeTokenKind.string);
    }
  }

  static String _uniqueName(String base, Map<String, int> used) {
    final count = (used[base] ?? 0) + 1;
    used[base] = count;
    return count == 1 ? base : '${base}_$count';
  }

  static int _stableHash(String text) {
    var hash = 0;
    for (final unit in text.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _hhmm(DateTime time) =>
      '${_two(time.hour)}${_two(time.minute)}';

  static String _clock(DateTime time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  static String _dayLabel(DateTime day) =>
      '${day.month}월 ${day.day}일 (${_weekdays[day.weekday - 1]})';
}

class _Day {
  _Day(this.date, this.messages);

  final DateTime date;
  final List<Message> messages;
}

sealed class _Item {
  const _Item();
}

class _Marker extends _Item {
  const _Marker();
}

class _System extends _Item {
  const _System(this.message);

  final Message message;
}

class _Turn extends _Item {
  _Turn(this.senderId, this.messages);

  final String senderId;
  final List<Message> messages;

  String sender(Map<String, String> nicknames) => nicknames[senderId] ?? '알수없음';
}
