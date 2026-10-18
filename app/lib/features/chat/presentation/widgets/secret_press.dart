import 'dart:async';

import 'package:flutter/widgets.dart';

class SecretPress extends StatefulWidget {
  const SecretPress({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 300),
  });

  final Widget Function(BuildContext context, bool revealed) builder;
  final Duration delay;

  @override
  State<SecretPress> createState() => _SecretPressState();
}

class _SecretPressState extends State<SecretPress> with WidgetsBindingObserver {
  Timer? _timer;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _hide();
  }

  void _press() {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _revealed = true);
    });
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    if (_revealed && mounted) setState(() => _revealed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _hide(),
      onPointerCancel: (_) => _hide(),
      child: widget.builder(context, _revealed),
    );
  }
}
