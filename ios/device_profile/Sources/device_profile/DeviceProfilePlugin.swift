import Flutter
import Foundation
import UIKit

/// Reads the hardware identifier of the device ("iPhone13,1"). The Dart side turns it into a name
/// with its table: iOS has no public API that returns the marketing name.
public class DeviceProfilePlugin: NSObject, FlutterPlugin {
  private static let methodChannelName = "device_profile"
  private static let methodRead = "read"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(DeviceProfilePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == DeviceProfilePlugin.methodRead {
      result(["machine": DeviceProfilePlugin.machine(), "idiom": DeviceProfilePlugin.idiom()])
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  /// `UIDevice.userInterfaceIdiom` by name, for the Dart side to tell the kind of device by.
  static func idiom() -> String {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone: return "phone"
    case .pad: return "pad"
    case .tv: return "tv"
    case .carPlay: return "carPlay"
    case .mac: return "mac"
    case .vision: return "vision"
    default: return "unspecified"
    }
  }

  /// `utsname.machine`; on the simulator that is the Mac's architecture, so the identifier of the
  /// simulated device is taken from the environment instead.
  static func machine() -> String {
    if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"], !simulated.isEmpty {
      return simulated
    }
    var info = utsname()
    uname(&info)
    return withUnsafeBytes(of: &info.machine) { bytes in
      String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
    }
  }
}
