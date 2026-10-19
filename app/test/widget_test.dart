import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/platform/screen_cover.dart';
import 'package:hush/features/chat/data/fake_chat_repository.dart';
import 'package:hush/features/chat/presentation/widgets/panel_resize_handle.dart';
import 'package:hush/features/chat/presentation/widgets/project_panel.dart';
import 'package:hush/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      HushApp(
        repository: FakeChatRepository(now: () => DateTime(2026, 10, 14, 15)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('첫 방의 대화를 코드 형식으로 보여 줌', (tester) async {
    await pumpApp(tester);

    expect(find.text('수행평가조.kt'), findsWidgets);
    expect(
      find.textContaining('val 수행평가조 = chat {', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('메시지를 입력하고 엔터를 누르면 대화에 추가됨', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), '9시 반 ㄱㄱ');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('"9시 반 ㄱㄱ"', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('한글 조합 중에 누른 엔터로는 보내지 않음', (tester) async {
    await pumpApp(tester);

    await tester.showKeyboard(find.byType(TextField));
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '안녕',
        selection: TextSelection.collapsed(offset: 2),
        composing: TextRange(start: 1, end: 2),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('"안녕"', findRichText: true), findsNothing);
  });

  testWidgets('Project 패널 경계를 끌면 너비가 바뀜', (tester) async {
    await pumpApp(tester);
    final panel = find.byType(ProjectPanel);
    final before = tester.getSize(panel).width;

    await tester.drag(find.byType(PanelResizeHandle), const Offset(100, 0));
    await tester.pumpAndSettle();

    expect(tester.getSize(panel).width, before + 100);
  });

  testWidgets('Project 패널을 아주 좁게 끌면 닫힘', (tester) async {
    await pumpApp(tester);

    await tester.drag(find.byType(PanelResizeHandle), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectPanel), findsNothing);
  });

  testWidgets('화면 가리기를 켜면 코드 화면으로 바뀜', (tester) async {
    addTearDown(() => screenCovered.value = false);
    await pumpApp(tester);

    screenCovered.value = true;
    await tester.pump();

    expect(find.byType(ScreenCover), findsOneWidget);
  });
}
