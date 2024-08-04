import Flutter
import UIKit

public class DualCameraPlugin: NSObject, FlutterPlugin , CameraViewControllerDelegate {
    
    private let CHANNEL = "com.example.camera_native"
    private var result: FlutterResult?
    
    var dataToSend: [String: Any]?

    
    func didCapturePhoto(with filePath: String) {
        var successResponse: [String: Any] = [:]
        successResponse["resultPath"] = filePath
                result?(successResponse)
       }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dual_camera", binaryMessenger: registrar.messenger())
    let instance = DualCameraPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "captureImage":

        self.dataToSend = call.arguments as? [String: Any]
        self.result = result
        self.showCameraViewController()
        
    default:
      result(FlutterMethodNotImplemented)
    }
  }


    
    private func showCameraViewController() {
        if let window = UIApplication.shared.keyWindow {
            
            guard let controller = window.rootViewController as? FlutterViewController else { return }
            let cameraViewController = CameraViewController()
            cameraViewController.modalPresentationStyle = .fullScreen
            cameraViewController.receivedData = dataToSend
            cameraViewController.delegate = self
            controller.present(cameraViewController, animated: true, completion: nil)
        }
    }
}






