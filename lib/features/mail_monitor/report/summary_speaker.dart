import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// How a read-aloud ended.
enum SpeakResult {
  spoken,
  noVoice,

  /// The speech plugin is not in the running app: it was hot-restarted after the package was added.
  needsRebuild,
  failed,
}

/// Reads the AI summary aloud. An interface so tests use a fake (changes `mail-response-report-tab`,
/// `mail-summary-language`).
abstract interface class SummarySpeaker {
  /// Speaks [text] in the [voice] locale (e.g. "ta-IN") and completes when it is finished or stopped.
  /// [SpeakResult.noVoice] when the device has no voice for that language.
  Future<SpeakResult> speak(String text, {required String voice});

  Future<void> stop();
}

/// The device's own text-to-speech voice (flutter_tts).
///
/// The end of speech is taken from the plugin's completion, cancel and error handlers, not from
/// `awaitSpeakCompletion`: on iOS the plugin never answers an awaited speak that is stopped, which would
/// leave the caller waiting for ever.
class TtsSummarySpeaker implements SummarySpeaker {
  TtsSummarySpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;
  Completer<SpeakResult>? _speaking;

  void _finish(SpeakResult result) {
    final c = _speaking;
    _speaking = null;
    if (c != null && !c.isCompleted) c.complete(result);
  }

  Future<void> _setUp() async {
    if (_ready) return;
    _tts.setCompletionHandler(() => _finish(SpeakResult.spoken));
    _tts.setCancelHandler(() => _finish(SpeakResult.spoken));
    _tts.setErrorHandler((message) {
      debugPrint('Read aloud error: $message');
      _finish(SpeakResult.failed);
    });
    await _tts.setSpeechRate(0.5);
    if (!kIsWeb && Platform.isIOS) {
      // Speak even with the ring/silent switch on, and lower other audio while speaking.
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }
    _ready = true;
  }

  @override
  Future<SpeakResult> speak(String text, {required String voice}) async {
    try {
      await _setUp();
      final available = await _tts.isLanguageAvailable(voice);
      if (available != true && available != 1) return SpeakResult.noVoice;
      await _tts.setLanguage(voice);
      _finish(SpeakResult.spoken);
      final done = _speaking = Completer<SpeakResult>();
      final started = await _tts.speak(text);
      if (started != 1) _finish(SpeakResult.failed);
      return await done.future;
    } on MissingPluginException {
      return SpeakResult.needsRebuild;
    } catch (e) {
      debugPrint('Read aloud failed: $e');
      _finish(SpeakResult.failed);
      return SpeakResult.failed;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing is speaking, or the plugin is not in this build.
    }
    _finish(SpeakResult.spoken);
  }
}
