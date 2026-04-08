import Flutter
import UIKit
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Forzar registro APNs en arranque para evitar estados en los que
    // Firebase Messaging no llega a obtener token APNs en iOS.
    DispatchQueue.main.async {
      application.registerForRemoteNotifications()
      print("INFO[APNS_NATIVE]: registerForRemoteNotifications() called")
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    Messaging.messaging().apnsToken = deviceToken
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("INFO[APNS_NATIVE]: didRegisterForRemoteNotifications token=\(token.prefix(12))...")
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    print("ERROR[APNS_NATIVE]: didFailToRegisterForRemoteNotifications error=\(error.localizedDescription)")
  }
}
