import 'package:flutter/material.dart';

import 'capture_guard.dart';

/// 화면 캡처 제외가 실제로 동작하는지 확인하기 위한 테스트 화면.
class CaptureTestPage extends StatefulWidget {
  const CaptureTestPage({super.key, this.guard = const CaptureGuard()});

  final CaptureGuard guard;

  @override
  State<CaptureTestPage> createState() => _CaptureTestPageState();
}

class _CaptureTestPageState extends State<CaptureTestPage> {
  bool _enabled = false;

  Future<void> _toggle(bool value) async {
    await widget.guard.setEnabled(enabled: value);
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _enabled ? Colors.red.shade100 : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _enabled ? '캡처 숨기기 ON' : '캡처 숨기기 OFF',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 16),
            Switch(value: _enabled, onChanged: _toggle),
          ],
        ),
      ),
    );
  }
}
