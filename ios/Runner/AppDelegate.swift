import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var userDataImportDelegate: UserDataImportPicker?

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

    let importChannel = FlutterMethodChannel(
      name: "app.sustainablelivingguide/user_data_import",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    importChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "pickJsonFile" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self else {
        result(FlutterError(
          code: "PICKER_UNAVAILABLE",
          message: "The document picker is unavailable.",
          details: nil
        ))
        return
      }
      let rootViewController = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?
        .rootViewController ?? self.window?.rootViewController
      guard let rootViewController else {
        result(FlutterError(
          code: "PICKER_UNAVAILABLE",
          message: "The document picker is unavailable.",
          details: nil
        ))
        return
      }

      let picker = UIDocumentPickerViewController(
        documentTypes: ["public.json"],
        in: .import
      )
      let pickerDelegate = UserDataImportPicker { [weak self] value in
        self?.userDataImportDelegate = nil
        result(value)
      }
      self.userDataImportDelegate = pickerDelegate
      picker.delegate = pickerDelegate
      rootViewController.present(picker, animated: true)
    }
  }
}

private final class UserDataImportPicker: NSObject, UIDocumentPickerDelegate {
  private let completion: (Any?) -> Void

  init(completion: @escaping (Any?) -> Void) {
    self.completion = completion
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    guard let url = urls.first else {
      completion(nil)
      return
    }
    let hasAccess = url.startAccessingSecurityScopedResource()
    defer {
      if hasAccess {
        url.stopAccessingSecurityScopedResource()
      }
    }
    do {
      completion(FlutterStandardTypedData(bytes: try Data(contentsOf: url)))
    } catch {
      completion(FlutterError(
        code: "FILE_READ_FAILED",
        message: error.localizedDescription,
        details: nil
      ))
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    completion(nil)
  }
}
