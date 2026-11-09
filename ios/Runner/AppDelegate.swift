import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let privacyChannel = FlutterMethodChannel(
      name: "app.sustainablelivingguide/privacy",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    privacyChannel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let paths = call.arguments as? [String] else {
        result(FlutterError(
          code: "INVALID_PATHS",
          message: "Expected database file paths.",
          details: nil
        ))
        return
      }

      let documentsDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      )[0].appendingPathComponent("sustainable_living_app.sqlite").standardizedFileURL
      let allowedPaths = Set([
        documentsDirectory.path,
        documentsDirectory.path + "-wal",
        documentsDirectory.path + "-shm",
        documentsDirectory.path + "-journal"
      ])
      do {
        for path in paths {
          let fileURL = URL(fileURLWithPath: path).standardizedFileURL
          guard allowedPaths.contains(fileURL.path) else {
            result(FlutterError(
              code: "INVALID_PATH",
              message: "The path is not a supported app database file.",
              details: nil
            ))
            return
          }
          var resourceURL = fileURL
          try resourceURL.setResourceValue(true, forKey: .isExcludedFromBackupKey)
        }
        result(nil)
      } catch {
        result(FlutterError(
          code: "BACKUP_EXCLUSION_FAILED",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
  }
}
