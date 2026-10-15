import 'package:flutter/services.dart';

/// macOS에 화면 캡처와 화면 공유에서 앱 창을 제외해 달라고 요청한다.
///
/// 네이티브 구현은 `macos/Runner/MainFlutterWindow.swift`에 있다.
class CaptureGuard {
  const CaptureGuard();

  static const _channel = MethodChannel('capture_guard');

  Future<void> setEnabled({required bool enabled}) {
    return _channel.invokeMethod<void>('setEnabled', enabled);
  }
}
