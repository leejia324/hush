import 'package:flutter/services.dart';

class GlobalHotKey {
  const GlobalHotKey();

  static const _channel = MethodChannel('global_hotkey');

  static const _spaceKeyCode = 49;

  static const _optionModifier = 0x0800;

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
