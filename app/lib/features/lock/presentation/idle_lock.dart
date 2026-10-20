import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lock_cubit.dart';

class IdleLock extends StatefulWidget {
  const IdleLock({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
  });

  final Widget child;
  final Duration timeout;

  @override
  State<IdleLock> createState() => _IdleLockState();
}

class _IdleLockState extends State<IdleLock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (mounted) context.read<LockCubit>().lock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerHover: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}
