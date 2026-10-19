import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/chat/presentation/widgets/secret_press.dart';

void main() {
  Widget subject() => MaterialApp(
    home: Center(
      child: SecretPress(
        builder: (context, revealed) => SizedBox(
          width: 200,
          height: 40,
          child: Text(revealed ? '보임' : '가림'),
        ),
      ),
    ),
  );

  testWidgets('0.3초 누르고 있으면 보임', (tester) async {
    await tester.pumpWidget(subject());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('가림')),
    );

    await tester.pump(const Duration(milliseconds: 299));
    expect(find.text('가림'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2));
    expect(find.text('보임'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(find.text('가림'), findsOneWidget);
  });

  testWidgets('0.3초 전에 떼면 안 보임', (tester) async {
    await tester.pumpWidget(subject());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('가림')),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('가림'), findsOneWidget);
  });

  testWidgets('누른 채 밖으로 나가도 계속 보임', (tester) async {
    await tester.pumpWidget(subject());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('가림')),
    );
    await tester.pump(const Duration(milliseconds: 350));

    await gesture.moveTo(const Offset(1, 1));
    await tester.pump();

    expect(find.text('보임'), findsOneWidget);
    await gesture.up();
  });

  testWidgets('앱이 비활성화되면 바로 가림', (tester) async {
    await tester.pumpWidget(subject());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('가림')),
    );
    await tester.pump(const Duration(milliseconds: 350));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(find.text('가림'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await gesture.up();
  });
}
