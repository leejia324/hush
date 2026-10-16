import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../capture_guard/capture_guard.dart';

/// macOS 네이티브 기능이 실제로 동작하는지 확인하기 위한 테스트 화면.
class NativeCheckPage extends StatefulWidget {
  const NativeCheckPage({super.key, this.guard = const CaptureGuard()});

  final CaptureGuard guard;

  @override
  State<NativeCheckPage> createState() => _NativeCheckPageState();
}

class _NativeCheckPageState extends State<NativeCheckPage> {
  bool _captureHidden = false;
  double _opacity = 1;

  Future<void> _toggleCapture(bool value) async {
    await widget.guard.setEnabled(enabled: value);
    setState(() => _captureHidden = value);
  }

  Future<void> _changeOpacity(double value) async {
    setState(() => _opacity = value);
    await windowManager.setOpacity(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _captureHidden ? Colors.red.shade100 : Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _Section(
            title: _captureHidden ? '캡처 숨기기 ON' : '캡처 숨기기 OFF',
            child: Switch(value: _captureHidden, onChanged: _toggleCapture),
          ),
          _Section(
            title: '창 불투명도 ${(_opacity * 100).round()}%',
            child: Slider(
              value: _opacity,
              min: 0.3,
              onChanged: _changeOpacity,
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
