import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/mail_monitor/report/summary_speaker.dart';

/// The device speaker over the app's own channel com.kassapos.maleva/tts (change `mail-summary-language`;
/// replaces flutter_tts, owner 2026-10-13).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(TtsSummarySpeaker.channelName);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  /// The native side telling Dart that speech ended.
  Future<void> nativeSays(String method, [Object? argument]) => messenger.handlePlatformMessage(
        TtsSummarySpeaker.channelName,
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, argument)),
        (_) {},
      );

  test('the channel missing from the running app (hot restart) asks for a full restart', () async {
    expect(await TtsSummarySpeaker().speak('Hello', voice: 'en-US'), SpeakResult.needsRebuild);
  });

  test('speaks in the asked language and ends when the device says it is done', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
    final speaking = TtsSummarySpeaker().speak('வணக்கம்', voice: 'ta-IN');
    await Future<void>.delayed(Duration.zero);
    await nativeSays('onDone');

    expect(await speaking.timeout(const Duration(seconds: 1)), SpeakResult.spoken);
    expect(calls.map((c) => c.method), ['isLanguageAvailable', 'speak']);
    expect(calls.last.arguments, {'text': 'வணக்கம்', 'language': 'ta-IN'});
  });

  test('Stop ends the speech even if the device never reports it', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });
    final speaker = TtsSummarySpeaker();
    final speaking = speaker.speak('Hello', voice: 'ta-IN');
    await Future<void>.delayed(Duration.zero);
    await speaker.stop();

    expect(await speaking.timeout(const Duration(seconds: 1)), SpeakResult.spoken);
    expect(calls, ['isLanguageAvailable', 'speak', 'stop']);
  });

  test('a speech error from the device ends it as failed', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => true);
    final speaking = TtsSummarySpeaker().speak('Hello', voice: 'en-US');
    await Future<void>.delayed(Duration.zero);
    await nativeSays('onError', 'speech failed (-3)');

    expect(await speaking.timeout(const Duration(seconds: 1)), SpeakResult.failed);
  });

  test('a speech the device cannot start fails at once', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'isLanguageAvailable');
    expect(await TtsSummarySpeaker().speak('Hello', voice: 'en-US'), SpeakResult.failed);
  });

  test('no voice for the language', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'isLanguageAvailable' ? false : true);
    expect(await TtsSummarySpeaker().speak('Hello', voice: 'ms-MY'), SpeakResult.noVoice);
  });
}
