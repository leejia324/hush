import 'package:flutter/services.dart';

class CaptureGuard {
  const CaptureGuard();

  static const _channel = MethodChannel('capture_guard');

  Future<void> setEnabled({required bool enabled}) {
    return _channel.invokeMethod<void>('setEnabled', enabled);
  }
}
