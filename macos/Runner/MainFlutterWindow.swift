import Cocoa
import FlutterMacOS
import AVFoundation

class MainFlutterWindow: NSWindow {
  private var summarySpeech: SummarySpeech?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    summarySpeech = SummarySpeech(
      messenger: flutterViewController.registrar(forPlugin: "MalevaSummarySpeech").messenger)

    super.awakeFromNib()
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
    synthesizer.stopSpeaking(at: .immediate)
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = voice
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
    synthesizer.speak(utterance)
    return true
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    channel.invokeMethod("onDone", arguments: nil)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    channel.invokeMethod("onCancel", arguments: nil)
  }
}
