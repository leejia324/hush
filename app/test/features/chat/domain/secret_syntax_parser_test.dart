import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/domain/message_segment.dart';
import 'package:hush/features/chat/domain/secret_syntax_parser.dart';

void main() {
  test('문법이 없으면 글자 그대로 한 조각', () {
    expect(SecretSyntaxParser.parse('안녕'), [const MessageSegment('안녕')]);
  });

  test('||로 감싼 부분만 비밀', () {
    expect(SecretSyntaxParser.parse('내일 ||9시 반|| 정문'), [
      const MessageSegment('내일 '),
      const MessageSegment('9시 반', secret: true),
      const MessageSegment(' 정문'),
    ]);
  });

  test('굵게, 기울임, 취소선', () {
    expect(SecretSyntaxParser.parse('**굵게** *기울임* ~~취소~~'), [
      const MessageSegment('굵게', bold: true),
      const MessageSegment(' '),
      const MessageSegment('기울임', italic: true),
      const MessageSegment(' '),
      const MessageSegment('취소', strike: true),
    ]);
  });

  test('비밀 안에 굵게가 겹칠 수 있음', () {
    expect(SecretSyntaxParser.parse('||진짜 **비밀**||'), [
      const MessageSegment('진짜 ', secret: true),
      const MessageSegment('비밀', secret: true, bold: true),
    ]);
  });

  test('굵게 안의 별표 하나는 기울임으로 보지 않음', () {
    expect(SecretSyntaxParser.parse('**a*b**'), [
      const MessageSegment('a*b', bold: true),
    ]);
  });

  test('닫히지 않은 기호는 글자 그대로', () {
    expect(SecretSyntaxParser.parse('||열기만'), [const MessageSegment('||열기만')]);
    expect(SecretSyntaxParser.parse('2*3=6'), [const MessageSegment('2*3=6')]);
  });

  test('빈 비밀은 글자 그대로', () {
    expect(SecretSyntaxParser.parse('||||'), [const MessageSegment('||||')]);
  });

  test('비밀이 있는지 확인', () {
    expect(SecretSyntaxParser.hasSecret('a ||b||'), isTrue);
    expect(SecretSyntaxParser.hasSecret('a **b**'), isFalse);
  });
}
