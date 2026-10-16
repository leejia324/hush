import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../capture_guard/capture_guard.dart';
import 'screen_cover.dart';

/// macOS 네이티브 기능이 실제로 동작하는지 확인하기 위한 테스트 화면.
class NativeCheckPage extends StatefulWidget {
  const NativeCheckPage({super.key, this.guard = const CaptureGuard()});

  final CaptureGuard guard;

  @override
  State<NativeCheckPage> createState() => _NativeCheckPageState();
}

class _NativeCheckPageState extends State<NativeCheckPage> {
  bool _captureHidden = false;
  final _auth = LocalAuthentication();
  String? _unlockResult;

  Future<void> _toggleCapture(bool value) async {
    await widget.guard.setEnabled(enabled: value);
    setState(() => _captureHidden = value);
  }

  Future<void> _unlock() async {
    String result;
    try {
      final unlocked = await _auth.authenticate(
        localizedReason: 'hush 잠금을 해제합니다',
        biometricOnly: true,
      );
      result = unlocked ? '잠금 해제 성공' : '잠금 해제 실패';
    } on LocalAuthException catch (e) {
      result = '오류: ${e.code.name}';
    }
    setState(() => _unlockResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: screenCovered,
      builder: (context, covered, _) {
        return covered ? const ScreenCover() : _buildChecks();
      },
    );
  }

  Widget _buildChecks() {
    return Scaffold(
      backgroundColor: _captureHidden ? Colors.red.shade100 : Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _Section(
            title: _captureHidden ? '캡처 숨기기 ON' : '캡처 숨기기 OFF',
            child: Switch(value: _captureHidden, onChanged: _toggleCapture),
          ),
          ValueListenableBuilder(
            valueListenable: coverHotKeyRegistered,
            builder: (context, registered, _) {
              return _Section(
                title: '⌥Space 화면 가리기',
                child: Text(switch (registered) {
                  null => '등록 중',
                  true => '등록됨. 다른 앱을 보고 있을 때도 ⌥Space로 가리고 다시 누르면 돌아온다',
                  false => '등록 실패. 다른 앱이 ⌥Space를 쓰고 있을 수 있다',
                }),
              );
            },
          ),
          _Section(
            title: 'Touch ID 잠금 해제',
            child: Row(
              children: [
                FilledButton(
                  onPressed: _unlock,
                  child: const Text('Touch ID로 잠금 해제'),
                ),
                const SizedBox(width: 16),
                Text(_unlockResult ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
