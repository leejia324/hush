import '../../domain/member.dart';
import '../../domain/message.dart';
import '../../domain/message_segment.dart';
import '../../domain/secret_syntax_parser.dart';
import 'code_line.dart';

abstract final class ConversationCode {
  static const _indent = '    ';
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  static List<CodeLine> build({
    required String roomName,
    required List<Member> members,
    required List<Message> messages,
    DateTime? newMessagesAfter,
  }) {
    final membersById = {for (final member in members) member.id: member};
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
        const CodeToken(' {', CodeTokenKind.plain),
      ]),
    ];

    final items = _group(messages, newMessagesAfter);
    DateTime? lastShownTime;
    var changed = false;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      switch (item) {
        case _DayItem(:final day):
          lines.add(_comment('region ${_dayLabel(day)}', changed: changed));
        case _MarkerItem():
          lines.add(
            const CodeLine([
              CodeToken(_indent, CodeTokenKind.plain),
              CodeToken('// TODO: 새 메시지', CodeTokenKind.todo),
            ]),
          );
          changed = true;
        case _SystemItem(:final message):
          lines.add(_comment(message.text, changed: changed));
          lastShownTime = message.sentAt;
        case _BlockItem(:final senderId, :final messages):
          final member = membersById[senderId];
          lines.add(
            CodeLine([
              const CodeToken(_indent, CodeTokenKind.plain),
              CodeToken(
                member?.nickname ?? '알수없음',
                CodeTokenKind.function,
                colorIndex: member?.colorIndex,
              ),
              const CodeToken('(', CodeTokenKind.plain),
            ], changed: changed),
          );
          for (var m = 0; m < messages.length; m++) {
            final message = messages[m];
            final showTime =
                lastShownTime == null ||
                !_sameMinute(lastShownTime, message.sentAt);
            lines.addAll(
              _messageLines(
                message,
                isLast: m == messages.length - 1,
                time: showTime ? message.sentAt : null,
                changed: changed,
              ),
            );
            lastShownTime = message.sentAt;
          }
          lines.add(
            CodeLine(const [
              CodeToken('$_indent);', CodeTokenKind.plain),
            ], changed: changed),
          );
          final nextIsBlock =
              i + 1 < items.length && items[i + 1] is _BlockItem;
          if (nextIsBlock) lines.add(CodeLine([], changed: changed));
      }
    }

    lines.add(const CodeLine([CodeToken('}', CodeTokenKind.plain)]));
    return lines;
  }

  static List<_Item> _group(
    List<Message> messages,
    DateTime? newMessagesAfter,
  ) {
    final items = <_Item>[];
    DateTime? currentDay;
    var markerPlaced = newMessagesAfter == null;

    for (final message in messages) {
      final day = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      if (currentDay != day) {
        items.add(_DayItem(day));
        currentDay = day;
      }
      if (!markerPlaced && message.sentAt.isAfter(newMessagesAfter!)) {
        items.add(const _MarkerItem());
        markerPlaced = true;
      }
      if (message.isSystem) {
        items.add(_SystemItem(message));
        continue;
      }
      final last = items.isEmpty ? null : items.last;
      if (last is _BlockItem && last.senderId == message.senderId) {
        last.messages.add(message);
      } else {
        items.add(_BlockItem(message.senderId, [message]));
      }
    }
    return items;
  }

  static List<CodeLine> _messageLines(
    Message message, {
    required bool isLast,
    required DateTime? time,
    required bool changed,
  }) {
    final textLines = _splitLines(SecretSyntaxParser.parse(message.text));
    final lines = <CodeLine>[];

    for (var l = 0; l < textLines.length; l++) {
      final isFirstLine = l == 0;
      final isLastLine = l == textLines.length - 1;
      final tokens = <CodeToken>[
        CodeToken(
          isFirstLine ? '$_indent$_indent"' : '$_indent$_indent ',
          isFirstLine ? CodeTokenKind.string : CodeTokenKind.plain,
        ),
        for (final segment in textLines[l])
          CodeToken(
            segment.text,
            CodeTokenKind.string,
            secret: segment.secret,
            bold: segment.bold,
            italic: segment.italic,
            strike: segment.strike,
          ),
        if (isLastLine) ...[
          const CodeToken('"', CodeTokenKind.string),
          if (!isLast) const CodeToken(',', CodeTokenKind.plain),
          if (time != null)
            CodeToken('   // ${_time(time)}', CodeTokenKind.comment),
        ],
      ];
      lines.add(CodeLine(tokens, messageId: message.id, changed: changed));
    }
    return lines;
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

  static CodeLine _comment(String text, {required bool changed}) {
    return CodeLine([
      const CodeToken(_indent, CodeTokenKind.plain),
      CodeToken('// $text', CodeTokenKind.comment),
    ], changed: changed);
  }

  static bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  static String _time(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String _dayLabel(DateTime day) =>
      '${day.month}월 ${day.day}일 (${_weekdays[day.weekday - 1]})';
}

sealed class _Item {
  const _Item();
}

class _DayItem extends _Item {
  const _DayItem(this.day);

  final DateTime day;
}

class _MarkerItem extends _Item {
  const _MarkerItem();
}

class _SystemItem extends _Item {
  const _SystemItem(this.message);

  final Message message;
}

class _BlockItem extends _Item {
  _BlockItem(this.senderId, this.messages);

  final String senderId;
  final List<Message> messages;
}
