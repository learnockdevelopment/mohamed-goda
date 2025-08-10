import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var secureView: UIView?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // Add a secure view to block screenshots
        addSecureView()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func addSecureView() {
        if secureView == nil {
            secureView = UIView(frame: UIScreen.main.bounds)
            secureView?.backgroundColor = .black
            secureView?.alpha = 0.5 // Optional: Adjust transparency
            self.window?.addSubview(secureView!)
        }
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        secureView?.isHidden = false // Show overlay when app is inactive
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        secureView?.isHidden = true // Hide overlay when app becomes active
    }
}
