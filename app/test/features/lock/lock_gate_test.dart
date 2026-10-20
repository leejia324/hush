import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/platform/screen_cover.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/lock/presentation/lock_cubit.dart';
import 'package:hush/features/lock/presentation/lock_gate.dart';

import '../../support/fake_authenticator.dart';

void main() {
  Future<LockCubit> pumpGate(
    WidgetTester tester,
    FakeAuthenticator authenticator, {
    bool unlockOnStart = false,
  }) async {
    final cubit = LockCubit(authenticator);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: IdeTheme.dark(),
        home: BlocProvider.value(
          value: cubit,
          child: LockGate(
            unlockOnStart: unlockOnStart,
            child: const Text('대화 화면'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('잠겨 있으면 위장 코드만 보이고 대화는 안 보임', (tester) async {
    await pumpGate(tester, FakeAuthenticator(result: false));

    expect(find.byType(ScreenCover), findsOneWidget);
    expect(find.text('대화 화면'), findsNothing);
  });

  testWidgets('자물쇠를 눌러 인증하면 대화가 보임', (tester) async {
    await pumpGate(tester, FakeAuthenticator());

    await tester.tap(find.byTooltip('잠금 해제 (Enter)'));
    await tester.pumpAndSettle();

    expect(find.byType(ScreenCover), findsNothing);
    expect(find.text('대화 화면'), findsOneWidget);
  });

  testWidgets('Enter를 눌러도 인증 창이 뜸', (tester) async {
    final authenticator = FakeAuthenticator();
    await pumpGate(tester, authenticator);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(authenticator.calls, 1);
    expect(find.text('대화 화면'), findsOneWidget);
  });

  testWidgets('인증에 실패하면 계속 잠겨 있음', (tester) async {
    await pumpGate(tester, FakeAuthenticator(result: false));

    await tester.tap(find.byTooltip('잠금 해제 (Enter)'));
    await tester.pumpAndSettle();

    expect(find.byType(ScreenCover), findsOneWidget);
  });

  testWidgets('앱을 켜면 바로 인증 창이 한 번 뜸', (tester) async {
    final authenticator = FakeAuthenticator();
    await pumpGate(tester, authenticator, unlockOnStart: true);

    expect(authenticator.calls, 1);
    expect(find.text('대화 화면'), findsOneWidget);
  });
}
