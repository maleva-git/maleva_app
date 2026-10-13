import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// How a read-aloud ended.
enum SpeakResult {
  spoken,
  noVoice,

  /// The speech channel is not in the running app: it was hot-restarted, not rebuilt, after it was added.
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

/// The device's own text-to-speech voice, through the app's own channel `com.kassapos.maleva/tts`
/// (Android TextToSpeech in MainActivity, AVSpeechSynthesizer in the iOS AppDelegate and the macOS window).
/// Replaces the flutter_tts package (owner, 2026-10-13: it applied the old Kotlin Gradle Plugin, which future
/// Flutter versions refuse). The native side reports the end of speech with `onDone`, `onCancel` and
/// `onError`, so a stopped speech always ends the wait.
class TtsSummarySpeaker implements SummarySpeaker {
  TtsSummarySpeaker({MethodChannel? channel}) : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'com.kassapos.maleva/tts';

  final MethodChannel _channel;
  bool _ready = false;
  Completer<SpeakResult>? _speaking;

  void _finish(SpeakResult result) {
    final c = _speaking;
    _speaking = null;
    if (c != null && !c.isCompleted) c.complete(result);
  }

  void _setUp() {
    if (_ready) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDone':
        case 'onCancel':
          _finish(SpeakResult.spoken);
        case 'onError':
          debugPrint('Read aloud error: ${call.arguments}');
          _finish(SpeakResult.failed);
      }
    });
    _ready = true;
  }

  @override
  Future<SpeakResult> speak(String text, {required String voice}) async {
    try {
      _setUp();
      final available = await _channel.invokeMethod<bool>('isLanguageAvailable', {'language': voice});
      if (available != true) return SpeakResult.noVoice;
      _finish(SpeakResult.spoken);
      final done = _speaking = Completer<SpeakResult>();
      final started = await _channel.invokeMethod<bool>('speak', {'text': text, 'language': voice});
      if (started != true) _finish(SpeakResult.failed);
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
      await _channel.invokeMethod<void>('stop');
    } catch (_) {
      // Nothing is speaking, or the channel is not in this build.
    }
    _finish(SpeakResult.spoken);
  }
}
