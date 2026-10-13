import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';

import 'summary_language.dart';
import 'summary_speaker.dart';

class BookingSummaryState {
  const BookingSummaryState({
    this.summary,
    this.loading = false,
    this.error,
    this.speaking = false,
    this.speechProblem,
    this.language = SummaryLanguage.english,
  });

  final BookingSummary? summary;
  final bool loading;
  final String? error;
  final bool speaking;
  final String? speechProblem;
  final SummaryLanguage language;
}

/// The booking speed AI summary (change booking-speed-insights): written on the user's tap from the numbers only, in
/// the chosen language, and read aloud with the device voice. A new range or language drops the old summary.
class BookingSummaryCubit extends Cubit<BookingSummaryState> {
  BookingSummaryCubit(this._api, this._speaker) : super(const BookingSummaryState());

  final MailMonitorApi _api;
  final SummarySpeaker _speaker;

  Future<void> write(ReportRange range) async {
    if (state.loading) return;
    await _stop();
    final language = state.language;
    emit(BookingSummaryState(summary: state.summary, loading: true, language: language));
    try {
      final summary = await _api.bookingSummary(range, language: language.code);
      if (!isClosed && state.language == language) emit(BookingSummaryState(summary: summary, language: language));
    } catch (e) {
      if (!isClosed) emit(BookingSummaryState(error: '$e', language: language));
    }
  }

  /// A new language: a shown summary is written again in it.
  Future<void> chooseLanguage(SummaryLanguage language, ReportRange range) async {
    if (language == state.language || state.loading) return;
    final had = state.summary != null;
    await _stop();
    emit(BookingSummaryState(language: language));
    if (had) await write(range);
  }

  /// The range changed: the summary was about other numbers.
  Future<void> clear() async {
    await _stop();
    if (!isClosed) emit(BookingSummaryState(language: state.language));
  }

  Future<void> toggleSpeech() async {
    if (state.speaking) return _stop();
    final summary = state.summary;
    if (summary == null || summary.points.isEmpty) return;
    final language = state.language;
    emit(BookingSummaryState(summary: summary, speaking: true, language: language));
    final result = await _speaker.speak(summary.speechText, voice: language.voice);
    if (isClosed) return;
    emit(BookingSummaryState(
      summary: state.summary,
      language: state.language,
      speechProblem: switch (result) {
        SpeakResult.spoken => null,
        SpeakResult.noVoice => 'This device has no ${language.name} voice. Add it in the phone\'s Settings > '
            'Text-to-speech (language packs), then try again.',
        SpeakResult.needsRebuild => 'Read aloud needs a full app restart after the update.',
        SpeakResult.failed => 'Read aloud could not start on this device. Check the volume, then try again.',
      },
    ));
  }

  Future<void> _stop() async {
    if (!state.speaking) return;
    await _speaker.stop();
    if (!isClosed) {
      emit(BookingSummaryState(summary: state.summary, language: state.language));
    }
  }

  @override
  Future<void> close() async {
    await _speaker.stop();
    return super.close();
  }
}
