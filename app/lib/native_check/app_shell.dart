import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'global_hotkey.dart';
import 'screen_cover.dart';

/// 메뉴 막대 아이콘, 창 닫기 동작, 화면 가리기 단축키를 관리한다.
///
/// 창을 닫으면 앱을 끝내지 않고 창만 숨긴다. 메뉴 막대의 "종료"로만 끝난다.
class AppShell with WindowListener {
  TrayIcon? _trayIcon;
  Menu? _menu;

  Future<void> start() async {
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
    _createTrayIcon();
    coverHotKeyRegistered.value = await const GlobalHotKey()
        .registerOptionSpace(
          onPressed: () => screenCovered.value = !screenCovered.value,
        );
  }

  void _createTrayIcon() {
    final menu = Menu.create()!
      ..addItem(_menuItem('열기', _showWindow))
      ..addSeparator()
      ..addItem(_menuItem('종료', _quit));

    final trayIcon = TrayIcon.create()!
      ..setTitle('{ }')
      ..setTooltip('hush')
      ..setContextMenu(menu)
      ..setContextMenuTrigger(ContextMenuTrigger.clicked)
      ..setVisible(true);

    // 참조가 사라지면 네이티브 객체가 해제되므로 필드에 보관한다.
    _menu = menu;
    _trayIcon = trayIcon;
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
    _trayIcon?.dispose();
    _menu?.dispose();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  @override
  void onWindowClose() {
    windowManager.hide();
  }
}
