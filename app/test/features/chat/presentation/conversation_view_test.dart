import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/chat/domain/member.dart';
import 'package:hush/features/chat/domain/message.dart';
import 'package:hush/features/chat/presentation/conversation/conversation_code.dart';
import 'package:hush/features/chat/presentation/widgets/conversation_view.dart';

void main() {
  testWidgets('줄바꿈된 메시지도 들여쓰기 위치에서 시작함', (tester) async {
    final lines = ConversationCode.build(
      roomName: '방',
      members: const [Member(id: 'cat', nickname: '고양이발', colorIndex: 1)],
      messages: [
        Message(
          id: '1',
          roomId: 'room',
          senderId: 'cat',
          text: '아주 긴 메시지 ' * 20,
          sentAt: DateTime(2026, 10, 14, 9),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: IdeTheme.dark(),
        home: Center(
          child: SizedBox(
            width: 500,
            height: 600,
            child: ConversationView(lines: lines),
          ),
        ),
      ),
    );

    final top = find.textContaining('package', findRichText: true);
    final wrapped = find.textContaining('아주 긴 메시지', findRichText: true);

    expect(tester.getSize(wrapped).height, greaterThan(IdeTheme.lineHeight));
    expect(
      tester.getTopLeft(wrapped).dx,
      greaterThan(tester.getTopLeft(top).dx),
    );
  });
}
