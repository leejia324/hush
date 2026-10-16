import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hush/main.dart';
import 'package:hush/native_check/screen_cover.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('capture_guard');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('스위치를 켜면 캡처 제외를 요청한다', (tester) async {
    await tester.pumpWidget(const HushApp());
    expect(find.text('캡처 숨기기 OFF'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('캡처 숨기기 ON'), findsOneWidget);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'setEnabled');
    expect(calls.single.arguments, isTrue);
  });

  testWidgets('화면 가리기를 켜면 코드 화면으로 바뀐다', (tester) async {
    addTearDown(() => screenCovered.value = false);
    await tester.pumpWidget(const HushApp());

    screenCovered.value = true;
    await tester.pump();

    expect(find.byType(ScreenCover), findsOneWidget);
    expect(find.text('캡처 숨기기 OFF'), findsNothing);
  });
}
