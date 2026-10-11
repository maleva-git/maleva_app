import 'package:flutter_tts/flutter_tts.dart';

/// Reads the AI summary aloud. An interface so tests use a fake (change `mail-response-report-tab`).
abstract interface class SummarySpeaker {
  /// Speaks [text] and completes when it is finished or stopped. False when the device cannot speak.
  Future<bool> speak(String text);

  Future<void> stop();
}

/// The device's own text-to-speech voice (flutter_tts), in English.
class TtsSummarySpeaker implements SummarySpeaker {
  TtsSummarySpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> _setUp() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    _ready = true;
  }

  @override
  Future<bool> speak(String text) async {
    try {
      await _setUp();
      final result = await _tts.speak(text);
      return result == 1;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing is speaking, or the device has no voice.
    }
  }
}
