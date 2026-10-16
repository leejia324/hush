import Carbon
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let globalHotKey = GlobalHotKey()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerCaptureGuardChannel(messenger: flutterViewController.engine.binaryMessenger)
    registerGlobalHotKeyChannel(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  /// 화면 캡처와 화면 공유에서 이 창을 제외할지 Flutter에서 설정할 수 있게 한다.
  private func registerCaptureGuardChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "capture_guard", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setEnabled", let enabled = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.sharingType = enabled ? .none : .readOnly
      result(nil)
    }
  }

  /// 앱이 포커스를 갖지 않아도 동작하는 전역 단축키를 Flutter에서 등록할 수 있게 한다.
  private func registerGlobalHotKeyChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "global_hotkey", binaryMessenger: messenger)
    globalHotKey.onPressed = {
      channel.invokeMethod("onPressed", arguments: nil)
    }
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "register",
        let args = call.arguments as? [String: Any],
        let keyCode = args["keyCode"] as? Int,
        let modifiers = args["modifiers"] as? Int
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.globalHotKey.register(keyCode: UInt32(keyCode), modifiers: UInt32(modifiers)) ?? false)
    }
  }
}

/// Carbon `RegisterEventHotKey`로 전역 단축키를 등록한다.
///
/// 모든 키 입력을 감시하는 `addGlobalMonitorForEvents`와 달리
/// 손쉬운 사용 권한 없이 샌드박스에서 동작한다.
final class GlobalHotKey {
  var onPressed: (() -> Void)?

  private var hotKeyRef: EventHotKeyRef?
  private var handlerRef: EventHandlerRef?

  func register(keyCode: UInt32, modifiers: UInt32) -> Bool {
    unregister()

    var eventType = EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed)
    )
    let userData = Unmanaged.passUnretained(self).toOpaque()
    let handlerStatus = InstallEventHandler(
      GetApplicationEventTarget(),
      { _, _, userData in
        guard let userData else { return noErr }
        let hotKey = Unmanaged<GlobalHotKey>.fromOpaque(userData).takeUnretainedValue()
        hotKey.onPressed?()
        return noErr
      },
      1,
      &eventType,
      userData,
      &handlerRef
    )
    guard handlerStatus == noErr else { return false }

    // 'hush'를 4바이트 서명으로 쓴다.
    let hotKeyID = EventHotKeyID(signature: OSType(0x6875_7368), id: 1)
    let status = RegisterEventHotKey(
      keyCode,
      modifiers,
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &hotKeyRef
    )
    return status == noErr
  }

  func unregister() {
    if let hotKeyRef {
      UnregisterEventHotKey(hotKeyRef)
    }
    if let handlerRef {
      RemoveEventHandler(handlerRef)
    }
    hotKeyRef = nil
    handlerRef = nil
  }
}
