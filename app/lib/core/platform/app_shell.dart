import 'dart:async';
import 'dart:ui';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'global_hotkey.dart';
import 'screen_cover.dart';

class AppShell with WindowListener {
  TrayIcon? _trayIcon;
  Menu? _unlockedMenu;
  Menu? _lockedMenu;
  void Function()? _onLock;
  Future<void> Function()? _onUnlock;
  StreamSubscription<bool>? _lockSubscription;

  Future<void> start() async {
    await windowManager.setPreventClose(true);
    await windowManager.setMinimumSize(const Size(800, 560));
    windowManager.addListener(this);
    _createTrayIcon();
    coverHotKeyRegistered.value = await const GlobalHotKey()
        .registerOptionSpace(
          onPressed: () => screenCovered.value = !screenCovered.value,
        );
  }

  void _createTrayIcon() {
    final unlockedMenu = Menu.create()!
      ..addItem(_menuItem('열기', _showWindow))
      ..addItem(_menuItem('지금 잠그기', () async => _onLock?.call()))
      ..addSeparator()
      ..addItem(_menuItem('종료', _quit));
    final lockedMenu = Menu.create()!
      ..addItem(_menuItem('잠금 해제', _unlock))
      ..addSeparator()
      ..addItem(_menuItem('종료', _quit));

    final trayIcon = TrayIcon.create()!
      ..setTitle('{ }')
      ..setTooltip('hush')
      ..setContextMenu(lockedMenu)
      ..setContextMenuTrigger(ContextMenuTrigger.clicked)
      ..setVisible(true);

    _unlockedMenu = unlockedMenu;
    _lockedMenu = lockedMenu;
    _trayIcon = trayIcon;
  }

  void bindLock({
    required bool locked,
    required Stream<bool> lockedChanges,
    required void Function() onLock,
    required Future<void> Function() onUnlock,
  }) {
    _onLock = onLock;
    _onUnlock = onUnlock;
    _showMenuFor(locked: locked);
    _lockSubscription?.cancel();
    _lockSubscription = lockedChanges.listen(
      (locked) => _showMenuFor(locked: locked),
    );
  }

  void _showMenuFor({required bool locked}) {
    _trayIcon?.setContextMenu(locked ? _lockedMenu : _unlockedMenu);
  }

  Future<void> _unlock() async {
    await _showWindow();
    await _onUnlock?.call();
  }

  MenuItem _menuItem(String label, Future<void> Function() onClick) {
    final item = MenuItem.createWithLabelAndType(label, MenuItemType.normal)!;
    item.addListener((event) {
      if (event is MenuItemClickedEvent) {
        onClick();
      }
    });
    return item;
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    await _lockSubscription?.cancel();
    _trayIcon?.dispose();
    _unlockedMenu?.dispose();
    _lockedMenu?.dispose();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  @override
  void onWindowClose() {
    windowManager.hide();
  }
}
