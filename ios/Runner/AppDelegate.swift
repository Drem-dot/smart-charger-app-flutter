import UIKit
import Flutter
import GoogleMaps
// Thêm import cho dotenv
import flutter_dotenv

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lấy key từ dotenv
    let apiKey = DotEnv.env["GOOGLE_MAPS_API_KEY"]
    GMSServices.provideAPIKey(apiKey!)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}