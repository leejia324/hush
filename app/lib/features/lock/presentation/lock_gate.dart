import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ide_colors.dart';
import 'disguise_screen.dart';
import 'lock_cubit.dart';

class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child, this.unlockOnStart = true});

  final Widget child;
  final bool unlockOnStart;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    if (widget.unlockOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<LockCubit>().unlock();
      });
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    final lock = context.read<LockCubit>();
    if (!lock.isLocked) return false;
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      lock.unlock();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BlocBuilder<LockCubit, LockStatus>(
          builder: (context, status) {
            final locked = status != LockStatus.unlocked;
            return ExcludeFocus(
              excluding: locked,
              child: Visibility(
                visible: !locked,
                maintainState: true,
                child: widget.child,
              ),
            );
          },
        ),
        Overlay.wrap(
          child: BlocBuilder<LockCubit, LockStatus>(
            builder: (context, status) => status == LockStatus.unlocked
                ? const SizedBox.shrink()
                : LockScreen(unlocking: status == LockStatus.unlocking),
          ),
        ),
      ],
    );
  }
}

class LockScreen extends StatelessWidget {
  const LockScreen({super.key, required this.unlocking});

  final bool unlocking;

  @override
  Widget build(BuildContext context) {
    final colors = IdeColors.of(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DisguiseScreen(),
          Positioned(
            right: 12,
            bottom: 8,
            child: IconButton(
              onPressed: unlocking ? null : context.read<LockCubit>().unlock,
              tooltip: '잠금 해제 (Enter)',
              iconSize: 16,
              color: colors.comment,
              disabledColor: colors.lineNumber,
              icon: const Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
    );
  }
}
