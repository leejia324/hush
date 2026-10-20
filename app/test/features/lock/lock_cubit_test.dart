import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hush/features/lock/presentation/lock_cubit.dart';

import '../../support/fake_authenticator.dart';

void main() {
  test('처음에는 잠긴 상태', () {
    final cubit = LockCubit(FakeAuthenticator());
    addTearDown(cubit.close);

    expect(cubit.state, LockStatus.locked);
  });

  test('인증에 성공하면 풀림', () async {
    final cubit = LockCubit(FakeAuthenticator());
    addTearDown(cubit.close);

    await cubit.unlock();

    expect(cubit.state, LockStatus.unlocked);
  });

  test('인증에 실패하면 계속 잠김', () async {
    final cubit = LockCubit(FakeAuthenticator(result: false));
    addTearDown(cubit.close);

    await cubit.unlock();

    expect(cubit.state, LockStatus.locked);
  });

  test('인증 중에 다시 눌러도 인증 창은 하나만', () async {
    final authenticator = FakeAuthenticator()..pending = Completer<bool>();
    final cubit = LockCubit(authenticator);
    addTearDown(cubit.close);

    final first = cubit.unlock();
    await cubit.unlock();
    authenticator.pending!.complete(true);
    await first;

    expect(authenticator.calls, 1);
    expect(cubit.state, LockStatus.unlocked);
  });

  test('풀린 상태에서 잠그면 잠김', () async {
    final cubit = LockCubit(FakeAuthenticator(), locked: false);
    addTearDown(cubit.close);

    cubit.lock();

    expect(cubit.state, LockStatus.locked);
  });
}
