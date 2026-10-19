import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/domain/member.dart';
import 'package:hush/features/chat/domain/message.dart';
import 'package:hush/features/chat/presentation/conversation/code_line.dart';
import 'package:hush/features/chat/presentation/conversation/conversation_code.dart';

void main() {
  const members = [
    Member(id: 'me', nickname: '나', colorIndex: 0, isMe: true),
    Member(id: 'cat', nickname: '고양이발', colorIndex: 1),
    Member(id: 'dawn', nickname: '새벽세시', colorIndex: 2),
  ];

  DateTime at(int hour, int minute, {int day = 14}) =>
      DateTime(2026, 10, day, hour, minute);

  Message message(
    String id,
    String senderId,
    String text,
    DateTime sentAt, {
    bool isSystem = false,
  }) => Message(
    id: id,
    roomId: 'team',
    senderId: senderId,
    text: text,
    sentAt: sentAt,
    isSystem: isSystem,
  );

  List<CodeLine> build(List<Message> messages, {DateTime? newMessagesAfter}) =>
      ConversationCode.build(
        roomName: '수행평가조',
        members: members,
        messages: messages,
        newMessagesAfter: newMessagesAfter,
      );

  List<String> texts(List<CodeLine> lines) =>
      lines.map((line) => line.text).toList();

  test('방은 클래스, 날짜는 함수로 감쌈', () {
    final lines = build([
      message('1', 'cat', '안녕', at(9, 0)),
      message('2', 'cat', '내일 봐', at(9, 0, day: 15)),
    ]);

    expect(texts(lines).take(7), [
      'package notes.rooms',
      '',
      'import notes.core.*',
      '',
      'class 수행평가조 : Room() {',
      '',
      '    override val members = listOf(나, 고양이발, 새벽세시)',
    ]);
    expect(texts(lines), contains('    // 10월 14일 (수)'));
    expect(texts(lines), contains('    fun day1014() {'));
    expect(texts(lines), contains('    fun day1015() {'));
    expect(texts(lines).last, '}');
  });

  test('모든 메시지 내용이 따옴표 안에 그대로 들어감', () {
    final lines = build([
      message('1', 'cat', '발표 자료 올릴게', at(14, 4)),
      message('2', 'dawn', '잠깐 나 할 말 있어', at(14, 15)),
      message('3', 'me', 'ㅇㅋ', at(14, 18)),
    ]);

    for (final (id, text) in [
      ('1', '"발표 자료 올릴게"'),
      ('2', '"잠깐 나 할 말 있어"'),
      ('3', '"ㅇㅋ"'),
    ]) {
      expect(
        lines.where((line) => line.messageId == id).single.text,
        contains(text),
      );
    }
  });

  test('대화가 길어지면 여러 가지 코드 모양이 섞임', () {
    final lines = build([
      for (var i = 0; i < 24; i++)
        message('$i', i.isEven ? 'cat' : 'dawn', '메시지 $i', at(10, i)),
    ]);
    final code = texts(lines).join('\n');

    final shapes = [
      RegExp(r'\.run \{'),
      RegExp(r'val \w+ = listOf\('),
      RegExp(r'if \(.+\.isOnline\)'),
      RegExp(r'notes\["'),
      RegExp(r'check\('),
      RegExp(r'val \S+\d{4} = "'),
    ].where((shape) => shape.hasMatch(code));

    expect(shapes.length, greaterThanOrEqualTo(4));
  });

  test('한 사람이 길게 보내도 같은 모양만 반복되지 않음', () {
    final lines = build([
      for (var i = 0; i < 12; i++) message('m$i', 'me', '메시지 $i', at(10, i)),
    ]);
    final code = texts(lines).join('\n');

    final shapes = [
      RegExp(r'\.run \{'),
      RegExp(r'val \w+ = listOf\('),
      RegExp(r'if \(.+\.isOnline\)'),
      RegExp(r'notes\["'),
      RegExp(r'check\('),
      RegExp(r'val \S+\d{4} = "'),
    ].where((shape) => shape.hasMatch(code));

    expect(shapes.length, greaterThanOrEqualTo(3));
  });

  test('같은 대화는 항상 같은 코드로 바뀜', () {
    List<Message> conversation() => [
      for (var i = 0; i < 10; i++)
        message('$i', i.isEven ? 'cat' : 'dawn', '메시지 $i', at(10, i)),
    ];

    expect(texts(build(conversation())), texts(build(conversation())));
  });

  test('닉네임 바꿈 시스템 메시지는 rename 호출', () {
    final lines = build([
      message('1', 'cat', '감자 → 감자튀김', at(14, 17), isSystem: true),
    ]);

    expect(
      lines.where((line) => line.messageId == '1').single.text,
      '        rename(from = "감자", to = "감자튀김") // 14:17',
    );
  });

  test('새 메시지 표시 아래 메시지만 변경 표시', () {
    final lines = build([
      message('1', 'cat', 'a', at(9, 0)),
      message('2', 'me', 'b', at(9, 5)),
    ], newMessagesAfter: at(9, 1));

    expect(texts(lines), contains('        // TODO: 새 메시지'));
    expect(lines.firstWhere((line) => line.messageId == '1').changed, isFalse);
    expect(lines.firstWhere((line) => line.messageId == '2').changed, isTrue);
  });

  test('여러 줄 메시지는 """ 문자열로, 모든 줄이 같은 메시지로 묶임', () {
    final lines = build([message('1', 'cat', 'a\n||b||', at(9, 0))]);

    final messageLines = lines.where((line) => line.messageId == '1').toList();
    expect(messageLines, hasLength(4));
    expect(messageLines.first.text, endsWith('"""'));
    expect(messageLines.last.text.trimLeft(), startsWith('""".trimIndent()'));
    expect(
      messageLines
          .expand((line) => line.tokens)
          .where((t) => t.secret)
          .single
          .text,
      'b',
    );
  });

  test('한 줄 문자열의 따옴표, 역슬래시, 달러는 이스케이프', () {
    final lines = build([message('1', 'cat', r'"$5" \ 끝', at(9, 0))]);

    final line = lines.firstWhere((line) => line.messageId == '1');
    expect(line.text, contains(r'"\"\$5\" \\ 끝"'));
    expect(
      line.tokens
          .where((token) => token.kind == CodeTokenKind.escape)
          .map((token) => token.text),
      [r'\"', r'\$', r'\"', r'\\'],
    );
  });

  test('여러 줄 문자열의 달러와 따옴표 세 개는 이스케이프', () {
    final lines = build([message('1', 'cat', 'a\n\$5 """끝', at(9, 0))]);

    final body = lines.where((line) => line.messageId == '1').elementAt(2);
    expect(body.text.trim(), r"""${'$'}5 ""${'"'}끝""");
  });

  test('비밀 구간은 비밀 표시가 붙은 조각으로 나옴', () {
    final lines = build([message('1', 'cat', '내일 ||9시|| 정문', at(9, 0))]);

    final messageLine = lines.firstWhere((line) => line.messageId == '1');
    final secret = messageLine.tokens.where((token) => token.secret);
    expect(secret.map((token) => token.text), ['9시']);
  });
}
