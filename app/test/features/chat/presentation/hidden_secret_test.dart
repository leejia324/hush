import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/presentation/widgets/hidden_secret.dart';

void main() {
  const style = TextStyle(fontSize: 14);

  Future<Size> pumpSecret(WidgetTester tester, String text) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: HiddenSecret(text: text, style: style, color: Colors.grey),
        ),
      ),
    );
    return tester.getSize(find.byType(HiddenSecret));
  }

  testWidgets('가린 상자는 원래 글자 폭만큼', (tester) async {
    final size = await pumpSecret(tester, '9시 반');

    final expected = HiddenSecret.measure(
      '9시 반',
      style.copyWith(height: 1.2),
      TextScaler.noScaling,
    );
    expect(size.width, expected.width);
  });

  testWidgets('긴 비밀은 짧은 비밀보다 넓음', (tester) async {
    final short = await pumpSecret(tester, '짧음');
    final long = await pumpSecret(tester, '이건 훨씬 더 긴 비밀 메시지');

    expect(long.width, greaterThan(short.width));
  });

  testWidgets('가린 상태에서는 글자가 화면에 없음', (tester) async {
    await pumpSecret(tester, '9시 반');

    expect(find.text('9시 반'), findsNothing);
    expect(find.bySemanticsLabel('9시 반'), findsNothing);
  });
}
