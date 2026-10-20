import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/lock/presentation/idle_lock.dart';
import 'package:hush/features/lock/presentation/lock_cubit.dart';

import '../../support/fake_authenticator.dart';

void main() {
  const timeout = Duration(minutes: 5);

  Future<LockCubit> pumpIdle(WidgetTester tester) async {
    final cubit = LockCubit(FakeAuthenticator(), locked: false);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const IdleLock(
            timeout: timeout,
            child: SizedBox.expand(child: Text('대화')),
          ),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('입력 없이 5분이 지나면 잠김', (tester) async {
    final cubit = await pumpIdle(tester);

    await tester.pump(timeout - const Duration(seconds: 1));
    expect(cubit.state, LockStatus.unlocked);

    await tester.pump(const Duration(seconds: 2));
    expect(cubit.state, LockStatus.locked);
  });

  testWidgets('마우스를 움직이면 시간이 다시 시작됨', (tester) async {
    final cubit = await pumpIdle(tester);

    await tester.pump(const Duration(minutes: 4));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(find.text('대화')));
    await gesture.moveBy(const Offset(5, 5));
    await tester.pump(const Duration(minutes: 4));

    expect(cubit.state, LockStatus.unlocked);
    await gesture.removePointer();
  });

  testWidgets('키보드를 누르면 시간이 다시 시작됨', (tester) async {
    final cubit = await pumpIdle(tester);

    await tester.pump(const Duration(minutes: 4));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump(const Duration(minutes: 4));

    expect(cubit.state, LockStatus.unlocked);
  });
}
