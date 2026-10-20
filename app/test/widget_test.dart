import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/chat/data/fake_chat_repository.dart';
import 'package:hush/features/chat/presentation/widgets/editor_tab_bar.dart';
import 'package:hush/features/chat/presentation/widgets/ide_toolbar.dart';
import 'package:hush/features/chat/presentation/widgets/panel_resize_handle.dart';
import 'package:hush/features/chat/presentation/widgets/project_panel.dart';
import 'package:hush/features/chat/presentation/widgets/terminal_composer.dart';
import 'package:hush/features/settings/domain/theme_preference.dart';
import 'package:hush/features/lock/presentation/lock_cubit.dart';
import 'package:hush/features/lock/presentation/lock_gate.dart';
import 'package:hush/main.dart';

import 'support/fake_authenticator.dart';
import 'support/memory_settings_repository.dart';

void main() {
  late MemorySettingsRepository settings;
  late LockCubit lock;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    settings = MemorySettingsRepository();
    lock = LockCubit(FakeAuthenticator(), locked: false);
    addTearDown(lock.close);

    await tester.pumpWidget(
      HushApp(
        repository: FakeChatRepository(now: () => DateTime(2026, 10, 14, 15)),
        settingsRepository: settings,
        lockCubit: lock,
        unlockOnStart: false,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('잠긴 상태로 켜도 오류 없이 잠금 화면이 보임', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      HushApp(
        repository: FakeChatRepository(now: () => DateTime(2026, 10, 14, 15)),
        settingsRepository: MemorySettingsRepository(),
        lockCubit: LockCubit(FakeAuthenticator(result: false)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('잠긴 상태에서 Enter를 누르면 다시 인증 창이 뜸', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final authenticator = FakeAuthenticator(result: false);

    await tester.pumpWidget(
      HushApp(
        repository: FakeChatRepository(now: () => DateTime(2026, 10, 14, 15)),
        settingsRepository: MemorySettingsRepository(),
        lockCubit: LockCubit(authenticator),
      ),
    );
    await tester.pumpAndSettle();
    expect(authenticator.calls, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(authenticator.calls, 2);
  });

  testWidgets('첫 방의 대화를 코드 형식으로 보여 줌', (tester) async {
    await pumpApp(tester);

    expect(find.text('수행평가조.kt'), findsWidgets);
    expect(find.textContaining('디코에서 리허설', findRichText: true), findsOneWidget);
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

    await tester.drag(
      find.byWidgetPredicate(
        (w) => w is PanelResizeHandle && w.axis == Axis.horizontal,
      ),
      const Offset(100, 0),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(panel).width, before + 100);
  });

  testWidgets('Project 패널을 아주 좁게 끌면 닫힘', (tester) async {
    await pumpApp(tester);

    await tester.drag(
      find.byWidgetPredicate(
        (w) => w is PanelResizeHandle && w.axis == Axis.horizontal,
      ),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProjectPanel), findsNothing);
  });

  testWidgets('터미널 위쪽 경계를 끌면 높이가 바뀜', (tester) async {
    await pumpApp(tester);
    final terminal = find.byType(TerminalComposer);
    final before = tester.getSize(terminal).height;

    await tester.drag(
      find.byWidgetPredicate(
        (w) => w is PanelResizeHandle && w.axis == Axis.vertical,
      ),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(terminal).height, greaterThan(before));
  });

  testWidgets('다른 방을 열면 편집기 탭이 쌓이고 닫을 수 있음', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('동아리방.kt').first);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    final tabs = find.byType(EditorTabBar);
    expect(
      find.descendant(of: tabs, matching: find.text('수행평가조.kt')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tabs, matching: find.text('동아리방.kt')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: tabs, matching: find.byIcon(Icons.close)).last,
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: tabs, matching: find.text('동아리방.kt')),
      findsNothing,
    );
  });

  for (final width in [800.0, 600.0, 400.0]) {
    testWidgets('창 폭 $width에서 툴바가 넘치지 않음', (tester) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: IdeTheme.dark(),
          home: Scaffold(
            body: IdeToolbar(onLock: () {}, onSettings: () {}),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('지금 잠그기 ⌥Space'), findsOneWidget);
    });
  }

  testWidgets('설정 창에서 테마를 고르고 확인을 누르면 적용되고 저장됨', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OS와 동기화'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('라이트'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다크').last);
    await tester.pumpAndSettle();

    expect(settings.saved, ThemePreference.system);

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(settings.saved, ThemePreference.dark);
  });

  testWidgets('설정 창에서 취소하면 바뀌지 않음', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OS와 동기화'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(settings.saved, ThemePreference.system);
  });

  testWidgets('잠갔다가 풀어도 열어 둔 탭이 남아 있음', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('동아리방.kt').first);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    lock.lock();
    await tester.pump();
    await lock.unlock();
    await tester.pumpAndSettle();

    final tabs = find.byType(EditorTabBar);
    expect(
      find.descendant(of: tabs, matching: find.text('수행평가조.kt')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tabs, matching: find.text('동아리방.kt')),
      findsOneWidget,
    );
  });

  testWidgets('툴바 자물쇠를 누르면 잠김', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('지금 잠그기 ⌥Space'));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
  });
}
