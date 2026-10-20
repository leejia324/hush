import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/theme/ide_theme.dart';
import 'package:hush/features/lock/presentation/disguise_screen.dart';
import 'package:hush/features/lock/presentation/lock_cubit.dart';
import 'package:hush/features/lock/presentation/lock_gate.dart';
import 'package:hush/features/lock/presentation/lock_image_cubit.dart';

import '../../support/fake_authenticator.dart';
import '../../support/memory_lock_image_store.dart';
import '../../support/memory_settings_repository.dart';

void main() {
  Future<LockCubit> pumpGate(
    WidgetTester tester,
    FakeAuthenticator authenticator, {
    bool unlockOnStart = false,
    String? imagePath,
  }) async {
    final cubit = LockCubit(authenticator);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: IdeTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(
              create: (_) => LockImageCubit(
                MemorySettingsRepository(),
                MemoryLockImageStore(),
                initial: imagePath,
              ),
            ),
          ],
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

    expect(find.byType(DisguiseScreen), findsOneWidget);
    expect(find.text('대화 화면'), findsNothing);
  });

  testWidgets('자물쇠를 눌러 인증하면 대화가 보임', (tester) async {
    await pumpGate(tester, FakeAuthenticator());

    await tester.tap(find.byTooltip('잠금 해제 (Enter)'));
    await tester.pumpAndSettle();

    expect(find.byType(DisguiseScreen), findsNothing);
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

    expect(find.byType(DisguiseScreen), findsOneWidget);
  });

  testWidgets('앱을 켜면 바로 인증 창이 한 번 뜸', (tester) async {
    final authenticator = FakeAuthenticator();
    await pumpGate(tester, authenticator, unlockOnStart: true);

    expect(authenticator.calls, 1);
    expect(find.text('대화 화면'), findsOneWidget);
  });

  testWidgets('스크린샷을 골라 두면 잠금 화면에 그 이미지가 보임', (tester) async {
    await pumpGate(
      tester,
      FakeAuthenticator(result: false),
      imagePath: '/tmp/my_ide.png',
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as FileImage).file.path, '/tmp/my_ide.png');
    expect(image.fit, BoxFit.cover);
    expect(find.byType(DisguiseScreen), findsNothing);
  });
}
