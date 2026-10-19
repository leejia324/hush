import '../../domain/member.dart';
import '../../domain/message.dart';
import '../../domain/message_segment.dart';
import '../../domain/secret_syntax_parser.dart';
import 'code_line.dart';

abstract final class ConversationCode {
  static const _indent = '    ';
  static const _itemIndent = '        ';
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

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
        const CodeToken('val', CodeTokenKind.keyword),
        CodeToken(' $roomName = ', CodeTokenKind.plain),
        const CodeToken('chat', CodeTokenKind.function),
        const CodeToken('(', CodeTokenKind.plain),
      ], runnable: true),
      CodeLine([
        const CodeToken('${_indent}members = ', CodeTokenKind.plain),
        const CodeToken('listOf', CodeTokenKind.function),
        CodeToken(
          '(${members.map((member) => member.nickname).join(', ')}),',
          CodeTokenKind.plain,
        ),
      ]),
      const CodeLine([
        CodeToken('${_indent}messages = ', CodeTokenKind.plain),
        CodeToken('listOf', CodeTokenKind.function),
        CodeToken('(', CodeTokenKind.plain),
      ]),
    ];

    DateTime? currentDay;
    var markerPlaced = newMessagesAfter == null;
    var changed = false;

    for (final message in messages) {
      final day = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      if (currentDay != day) {
        lines.add(_comment(_dayLabel(day), changed: changed));
        currentDay = day;
      }
      if (!markerPlaced && message.sentAt.isAfter(newMessagesAfter!)) {
        lines.add(
          const CodeLine([
            CodeToken(_itemIndent, CodeTokenKind.plain),
            CodeToken('// TODO: 새 메시지', CodeTokenKind.todo),
          ]),
        );
        markerPlaced = true;
        changed = true;
      }
      lines.add(
        _call(
          message,
          sender: message.isSystem
              ? null
              : nicknames[message.senderId] ?? '알수없음',
          changed: changed,
        ),
      );
    }

    lines.addAll(const [
      CodeLine([CodeToken('$_indent),', CodeTokenKind.plain)]),
      CodeLine([CodeToken(')', CodeTokenKind.plain)]),
    ]);
    return lines;
  }

  static CodeLine _call(
    Message message, {
    required String? sender,
    required bool changed,
  }) {
    return CodeLine(
      [
        const CodeToken(_itemIndent, CodeTokenKind.plain),
        CodeToken(
          sender == null ? 'system' : 'message',
          CodeTokenKind.function,
        ),
        CodeToken(sender == null ? '(' : '($sender, ', CodeTokenKind.plain),
        const CodeToken('"', CodeTokenKind.string),
        for (final segment in SecretSyntaxParser.parse(message.text))
          ..._stringTokens(segment),
        const CodeToken('"', CodeTokenKind.string),
        const CodeToken(', ', CodeTokenKind.plain),
        const CodeToken('at', CodeTokenKind.function),
        const CodeToken('(', CodeTokenKind.plain),
        CodeToken('${message.sentAt.hour}', CodeTokenKind.number),
        const CodeToken(', ', CodeTokenKind.plain),
        CodeToken('${message.sentAt.minute}', CodeTokenKind.number),
        const CodeToken(')),', CodeTokenKind.plain),
      ],
      messageId: message.id,
      changed: changed,
    );
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
        '\n' => r'\n',
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

  static CodeLine _comment(String text, {required bool changed}) {
    return CodeLine([
      const CodeToken(_itemIndent, CodeTokenKind.plain),
      CodeToken('// $text', CodeTokenKind.comment),
    ], changed: changed);
  }

  static String _dayLabel(DateTime day) =>
      '${day.month}월 ${day.day}일 (${_weekdays[day.weekday - 1]})';
}
