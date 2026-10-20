import 'dart:async';

import 'package:hush/features/lock/domain/authenticator.dart';

class FakeAuthenticator implements Authenticator {
  FakeAuthenticator({this.result = true});

  bool result;
  int calls = 0;
  Completer<bool>? pending;

  @override
  Future<bool> authenticate(String reason) {
    calls++;
    final completer = pending;
    if (completer != null) return completer.future;
    return Future.value(result);
  }
}
