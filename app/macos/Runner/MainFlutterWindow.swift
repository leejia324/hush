import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerCaptureGuardChannel(messenger: flutterViewController.engine.binaryMessenger)

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
}
