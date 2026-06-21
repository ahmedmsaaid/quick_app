import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.quick.app/launcher",
                                       binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "launchMap" {
        guard let args = call.arguments as? [String: Any],
              let lat = args["latitude"] as? Double,
              let lng = args["longitude"] as? Double else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing coordinates", details: nil))
          return
        }
        let urlString = "http://maps.apple.com/?daddr=\(lat),\(lng)"
        if let url = URL(string: urlString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
          result(true)
        } else {
          result(FlutterError(code: "URL_ERROR", message: "Cannot create URL", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

