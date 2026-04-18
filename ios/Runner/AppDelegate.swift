import Flutter
import QuickLook
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Quick Look veri kaynağı; önizleme kapanınca temizlenir.
  private var quickLookItem: PreviewQLItem?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()
    let channel = FlutterMethodChannel(
      name: "com.agu.agumobile/downloads",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "openLocalFile" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let path = call.arguments as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
        return
      }
      self?.presentQuickLook(at: path, result: result)
    }
  }

  private func presentQuickLook(at path: String, result: @escaping FlutterResult) {
    let fileURL = URL(fileURLWithPath: path)
    guard FileManager.default.isReadableFile(atPath: path) else {
      result(FlutterError(code: "NOT_FOUND", message: "File not found", details: nil))
      return
    }
    let home = NSHomeDirectory()
    guard path.hasPrefix(home) else {
      result(FlutterError(code: "INVALID_PATH", message: "Outside app sandbox", details: nil))
      return
    }
    guard let rootVC = Self.topViewController() else {
      result(FlutterError(code: "NO_VC", message: "No view controller", details: nil))
      return
    }

    let item = PreviewQLItem(url: fileURL)
    quickLookItem = item

    let ql = QLPreviewController()
    ql.dataSource = self
    ql.delegate = self
    rootVC.present(ql, animated: true)
    result(true)
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene =
      scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
    guard let windowScene = scene else { return nil }
    guard var root =
      windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
      ?? windowScene.windows.first?.rootViewController
    else {
      return nil
    }
    while let presented = root.presentedViewController {
      root = presented
    }
    return root
  }
}

private final class PreviewQLItem: NSObject, QLPreviewItem {
  let url: URL
  init(url: URL) { self.url = url }
  var previewItemURL: URL? { url }
}

extension AppDelegate: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    quickLookItem == nil ? 0 : 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    quickLookItem!
  }
}

extension AppDelegate: QLPreviewControllerDelegate {
  func previewControllerDidDismiss(_ controller: QLPreviewController) {
    quickLookItem = nil
  }
}
