import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/mail_monitor/report/summary_speaker.dart';

/// The device speaker over the flutter_tts channel (change `mail-summary-language`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('the plugin missing from the running app (hot restart) asks for a full restart', () async {
    expect(await TtsSummarySpeaker().speak('Hello', voice: 'en-US'), SpeakResult.needsRebuild);
  });

  test('Stop ends the speech even though iOS never answers a stopped speak', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'isLanguageAvailable' => true,
        _ => 1,
      };
    });
    final speaker = TtsSummarySpeaker();
    final speaking = speaker.speak('Hello', voice: 'ta-IN');
    await Future<void>.delayed(Duration.zero);
    await speaker.stop();

    expect(await speaking.timeout(const Duration(seconds: 1)), SpeakResult.spoken);
    expect(calls, containsAllInOrder(['isLanguageAvailable', 'setLanguage', 'speak', 'stop']));
    expect(calls, isNot(contains('awaitSpeakCompletion')));
  });

  test('no voice for the language', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'isLanguageAvailable' ? false : 1);
    expect(await TtsSummarySpeaker().speak('Hello', voice: 'ms-MY'), SpeakResult.noVoice);
  });
}
