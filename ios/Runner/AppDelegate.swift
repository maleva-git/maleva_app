import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var summarySpeech: SummarySpeech?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
          if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
              }
    if let registrar = self.registrar(forPlugin: "MalevaSummarySpeech") {
      summarySpeech = SummarySpeech(messenger: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Reads the mail report summary aloud with AVSpeechSynthesizer, for `TtsSummarySpeaker` in Dart (channel
/// com.kassapos.maleva/tts). Replaces the flutter_tts plugin (owner, 2026-10-13). Methods:
/// isLanguageAvailable {language}, speak {text, language}, stop; calls back onDone, onCancel, onError.
final class SummarySpeech: NSObject, AVSpeechSynthesizerDelegate {
  private let channel: FlutterMethodChannel
  private let synthesizer = AVSpeechSynthesizer()

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "com.kassapos.maleva/tts", binaryMessenger: messenger)
    super.init()
    synthesizer.delegate = self
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return result(nil) }
      let args = call.arguments as? [String: Any]
      switch call.method {
      case "isLanguageAvailable":
        result(AVSpeechSynthesisVoice(language: args?["language"] as? String) != nil)
      case "speak":
        result(self.speak(args?["text"] as? String, language: args?["language"] as? String))
      case "stop":
        self.synthesizer.stopSpeaking(at: .immediate)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func speak(_ text: String?, language: String?) -> Bool {
    guard let text = text, !text.isEmpty, let voice = AVSpeechSynthesisVoice(language: language) else { return false }
    // Speak even with the ring/silent switch on, and lower other audio while speaking.
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    try? AVAudioSession.sharedInstance().setActive(true)
    synthesizer.stopSpeaking(at: .immediate)
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = voice
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    synthesizer.speak(utterance)
    return true
  }

  private func ended(_ method: String) {
    try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    channel.invokeMethod(method, arguments: nil)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    ended("onDone")
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    ended("onCancel")
  }
}
