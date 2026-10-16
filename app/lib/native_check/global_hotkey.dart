import 'package:flutter/services.dart';

/// 앱이 포커스를 갖지 않아도 동작하는 전역 단축키.
///
/// 네이티브 구현은 `macos/Runner/MainFlutterWindow.swift`의 `GlobalHotKey`에 있다.
class GlobalHotKey {
  const GlobalHotKey();

  static const _channel = MethodChannel('global_hotkey');

  /// Carbon 가상 키 코드 `kVK_Space`
  static const _spaceKeyCode = 49;

  /// Carbon 수식 키 `optionKey`
  static const _optionModifier = 0x0800;

  /// ⌥Space를 등록하고, 성공하면 true를 돌려준다.
  Future<bool> registerOptionSpace({required void Function() onPressed}) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPressed') {
        onPressed();
      }
    });
    final registered = await _channel.invokeMethod<bool>('register', {
      'keyCode': _spaceKeyCode,
      'modifiers': _optionModifier,
    });
    return registered ?? false;
  }
}
