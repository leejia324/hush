import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/authenticator.dart';

enum LockStatus { locked, unlocking, unlocked }

class LockCubit extends Cubit<LockStatus> {
  LockCubit(this._authenticator, {bool locked = true})
    : super(locked ? LockStatus.locked : LockStatus.unlocked);

  final Authenticator _authenticator;

  bool get isLocked => state != LockStatus.unlocked;

  void lock() {
    if (state == LockStatus.unlocked) emit(LockStatus.locked);
  }

  Future<void> unlock() async {
    if (state != LockStatus.locked) return;
    emit(LockStatus.unlocking);
    final unlocked = await _authenticator.authenticate('hush 잠금을 해제합니다');
    if (isClosed) return;
    emit(unlocked ? LockStatus.unlocked : LockStatus.locked);
  }
}
