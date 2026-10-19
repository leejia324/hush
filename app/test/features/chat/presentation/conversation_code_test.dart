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

  DateTime at(int hour, int minute) => DateTime(2026, 10, 14, hour, minute);

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

  test('대화를 함수 호출 코드로 바꾸고 여러 줄 메시지는 """ 문자열로', () {
    final lines = ConversationCode.build(
      roomName: '수행평가조',
      members: members,
      messages: [
        message('1', 'cat', '발표 자료 올릴게', at(14, 4)),
        message('2', 'dawn', '잠깐 나 할 말 있어', at(14, 15)),
        message('3', 'dawn', '질문 리스트\n1. 주제\n2. 역할', at(14, 16)),
        message('4', 'cat', '감자 → 감자튀김', at(14, 17), isSystem: true),
        message('5', 'me', 'ㅇㅋ', at(14, 18)),
      ],
      newMessagesAfter: at(14, 17),
    );

    expect(lines.map((line) => line.text).toList(), [
      'package notes.rooms',
      '',
      'import notes.core.*',
      '',
      'val 수행평가조 = chat(',
      '    members = listOf(나, 고양이발, 새벽세시),',
      '    messages = listOf(',
      '        // 10월 14일 (수)',
      '        message(고양이발, "발표 자료 올릴게", at(14, 4)),',
      '        message(새벽세시, "잠깐 나 할 말 있어", at(14, 15)),',
      '        message(새벽세시, """',
      '            질문 리스트',
      '            1. 주제',
      '            2. 역할',
      '        """.trimIndent(), at(14, 16)),',
      '        system("감자 → 감자튀김", at(14, 17)),',
      '        // TODO: 새 메시지',
      '        message(나, "ㅇㅋ", at(14, 18)),',
      '    ),',
      ')',
    ]);
  });

  test('따옴표, 역슬래시, 달러는 Kotlin 문자열처럼 이스케이프', () {
    final lines = ConversationCode.build(
      roomName: '방',
      members: members,
      messages: [message('1', 'cat', r'"$5" \ 끝', at(9, 0))],
    );

    final line = lines.firstWhere((line) => line.messageId == '1');
    expect(line.text, r'        message(고양이발, "\"\$5\" \\ 끝", at(9, 0)),');
    expect(
      line.tokens
          .where((token) => token.kind == CodeTokenKind.escape)
          .map((token) => token.text),
      [r'\"', r'\$', r'\"', r'\\'],
    );
  });

  test('여러 줄 메시지의 모든 줄이 같은 메시지로 묶임', () {
    final lines = ConversationCode.build(
      roomName: '방',
      members: members,
      messages: [message('1', 'cat', 'a\n||b||', at(9, 0))],
    );

    final messageLines = lines.where((line) => line.messageId == '1');
    expect(messageLines, hasLength(4));
    expect(
      messageLines
          .expand((line) => line.tokens)
          .where((t) => t.secret)
          .single
          .text,
      'b',
    );
  });

  test('새 메시지 아래 줄만 변경 표시', () {
    final lines = ConversationCode.build(
      roomName: '방',
      members: members,
      messages: [
        message('1', 'cat', 'a', at(9, 0)),
        message('2', 'me', 'b', at(9, 5)),
      ],
      newMessagesAfter: at(9, 1),
    );

    expect(lines.firstWhere((line) => line.messageId == '1').changed, isFalse);
    expect(lines.firstWhere((line) => line.messageId == '2').changed, isTrue);
  });

  test('비밀 구간은 비밀 표시가 붙은 조각으로 나옴', () {
    final lines = ConversationCode.build(
      roomName: '방',
      members: members,
      messages: [message('1', 'cat', '내일 ||9시|| 정문', at(9, 0))],
    );

    final messageLine = lines.firstWhere((line) => line.messageId == '1');
    final secret = messageLine.tokens.where((token) => token.secret);
    expect(secret.map((token) => token.text), ['9시']);
  });
}
