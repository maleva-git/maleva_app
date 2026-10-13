import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/network/api_failure.dart';

import 'response_rules.dart';
import 'summary_language.dart';
import 'summary_speaker.dart';

class ResponseReportState {
  const ResponseReportState({
    required this.range,
    this.preset = RangePreset.last7,
    this.fastestFirst = false,
    this.report,
    this.loading = false,
    this.error,
    this.errorCode,
    this.summary,
    this.summaryLoading = false,
    this.summaryError,
    this.speaking = false,
    this.speechProblem,
    this.language = SummaryLanguage.english,
  });

  final ReportRange range;

  /// Null for a custom From/To.
  final RangePreset? preset;
  final bool fastestFirst;

  /// Kept while a reload runs, so the page does not blank out.
  final ResponseReport? report;
  final bool loading;
  final String? error;

  /// 403 (not the Super Admin) or 503 (monitor not set up), to word the error.
  final int? errorCode;

  final ResponseSummary? summary;
  final bool summaryLoading;
  final String? summaryError;
  final bool speaking;

  /// Why the last read-aloud did not happen (no voice for the language on this device).
  final String? speechProblem;

  /// The language the summary is written and read aloud in.
  final SummaryLanguage language;

  ResponseReportState copyWith({
    ReportRange? range,
    RangePreset? Function()? preset,
    bool? fastestFirst,
    ResponseReport? Function()? report,
    bool? loading,
    String? Function()? error,
    int? Function()? errorCode,
    ResponseSummary? Function()? summary,
    bool? summaryLoading,
    String? Function()? summaryError,
    bool? speaking,
    String? Function()? speechProblem,
    SummaryLanguage? language,
  }) =>
      ResponseReportState(
        range: range ?? this.range,
        preset: preset != null ? preset() : this.preset,
        fastestFirst: fastestFirst ?? this.fastestFirst,
        report: report != null ? report() : this.report,
        loading: loading ?? this.loading,
        error: error != null ? error() : this.error,
        errorCode: errorCode != null ? errorCode() : this.errorCode,
        summary: summary != null ? summary() : this.summary,
        summaryLoading: summaryLoading ?? this.summaryLoading,
        summaryError: summaryError != null ? summaryError() : this.summaryError,
        speaking: speaking ?? this.speaking,
        speechProblem: speechProblem != null ? speechProblem() : this.speechProblem,
        language: language ?? this.language,
      );
}

/// The Mail Response tab: the report for a range, its order, and the AI summary written on request and
/// read aloud (change `mail-response-report-tab`). The report changes with the server's 15-minute scan,
/// so there is no timer.
class ResponseReportCubit extends Cubit<ResponseReportState> {
  ResponseReportCubit(this._api, this._speaker, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(ResponseReportState(range: rangeOf(RangePreset.last7, (clock ?? DateTime.now)())));

  final MailMonitorApi _api;
  final SummarySpeaker _speaker;
  final DateTime Function() _clock;

  MailMonitorApi get api => _api;

  Future<void> load() async {
    final range = state.range;
    emit(state.copyWith(loading: true, error: () => null, errorCode: () => null));
    try {
      final report = await _api.responseReport(range);
      if (!isClosed && state.range == range) emit(state.copyWith(report: () => report, loading: false));
    } catch (e) {
      if (isClosed || state.range != range) return;
      emit(state.copyWith(
        loading: false,
        error: () => '$e',
        errorCode: () => e is ApiFailure ? e.statusCode : null,
      ));
    }
  }

  Future<void> choosePreset(RangePreset preset) => _changeRange(rangeOf(preset, _clock()), preset);

  Future<void> chooseDates(DateTime from, DateTime to) => _changeRange(rangeFromDates(from, to), null);

  /// A new range: the summary was about the old numbers, so it goes, and speech stops.
  Future<void> _changeRange(ReportRange range, RangePreset? preset) async {
    if (range == state.range) return;
    await _stopSpeaking();
    emit(state.copyWith(range: range, preset: () => preset, summary: () => null, summaryError: () => null));
    await load();
  }

  void setFastestFirst(bool fastest) => emit(state.copyWith(fastestFirst: fastest));

  /// Asks the server's AI; only on the user's tap.
  Future<void> writeSummary() async {
    if (state.summaryLoading) return;
    final range = state.range;
    await _stopSpeaking();
    final language = state.language;
    emit(state.copyWith(summaryLoading: true, summaryError: () => null, speechProblem: () => null));
    try {
      final summary = await _api.responseSummary(range, language: language.code);
      if (!isClosed && state.range == range && state.language == language) {
        emit(state.copyWith(summary: () => summary, summaryLoading: false));
      }
    } catch (e) {
      if (!isClosed) emit(state.copyWith(summaryLoading: false, summaryError: () => '$e'));
    }
  }

  /// A new language: the shown summary was in the old one, so it is written again in the new one.
  Future<void> chooseLanguage(SummaryLanguage language) async {
    if (language == state.language) return;
    final hadSummary = state.summary != null;
    await _stopSpeaking();
    emit(state.copyWith(language: language, summary: () => null, summaryError: () => null, speechProblem: () => null));
    if (hadSummary) await writeSummary();
  }

  /// Read aloud in the summary's language, or Stop while speaking.
  Future<void> toggleSpeech() async {
    if (state.speaking) return _stopSpeaking();
    final points = state.summary?.points ?? const [];
    if (points.isEmpty) return;
    final language = state.language;
    emit(state.copyWith(speaking: true, speechProblem: () => null));
    final result = await _speaker.speak(state.summary!.speechText, voice: language.voice);
    if (isClosed) return;
    emit(state.copyWith(
      speaking: false,
      speechProblem: () => switch (result) {
        SpeakResult.spoken => null,
        SpeakResult.noVoice => 'This device has no ${language.name} voice. Add it in the phone\'s '
            'Settings > Text-to-speech (language packs), then try again.',
        SpeakResult.needsRebuild => 'Read aloud needs a full app restart after the update: close the app '
            'completely and open it again (a hot reload or hot restart is not enough).',
        SpeakResult.failed => 'Read aloud could not start on this device. Check the volume, then try again.',
      },
    ));
  }

  Future<void> _stopSpeaking() async {
    if (!state.speaking) return;
    await _speaker.stop();
    if (!isClosed) emit(state.copyWith(speaking: false));
  }

  @override
  Future<void> close() async {
    await _speaker.stop();
    return super.close();
  }
}

/// The sheet's lists: LATE (slowest and waiting), COUNTED or NOT_THEIRS (change mail-count-own-mail).
enum SheetTab { late, counted, notTheirs }

class LateMailState {
  const LateMailState({
    this.list,
    this.loading = true,
    this.error,
    this.tab = SheetTab.late,
    this.mails = const {},
    this.mailsLoading = false,
    this.mailsError,
  });

  final LateList? list;
  final bool loading;
  final String? error;
  final SheetTab tab;

  /// The loaded proof lists, by tab.
  final Map<SheetTab, MailList> mails;
  final bool mailsLoading;
  final String? mailsError;

  LateMailState copyWith({
    LateList? list,
    bool? loading,
    String? Function()? error,
    SheetTab? tab,
    Map<SheetTab, MailList>? mails,
    bool? mailsLoading,
    String? Function()? mailsError,
  }) =>
      LateMailState(
        list: list ?? this.list,
        loading: loading ?? this.loading,
        error: error != null ? error() : this.error,
        tab: tab ?? this.tab,
        mails: mails ?? this.mails,
        mailsLoading: mailsLoading ?? this.mailsLoading,
        mailsError: mailsError != null ? mailsError() : this.mailsError,
      );
}

/// One mailbox's late mail, for the sheet.
class LateMailCubit extends Cubit<LateMailState> {
  LateMailCubit(this._api, this.mailboxId, this.range) : super(const LateMailState());

  final MailMonitorApi _api;
  final int mailboxId;
  final ReportRange range;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: () => null));
    try {
      final list = await _api.responseLate(mailboxId, range);
      if (!isClosed) emit(state.copyWith(list: list, loading: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(loading: false, error: () => '$e'));
    }
  }

  /// Saves the Super Admin's correction of a mail, then reloads the lists. Answers the error text, or null.
  Future<String?> correct(int id, String? relevance) async {
    try {
      await _api.correctMail(id, relevance);
    } catch (e) {
      return '$e';
    }
    if (isClosed) return null;
    emit(state.copyWith(mails: const {}));
    await load();
    if (state.tab != SheetTab.late) await choose(state.tab);
    return null;
  }

  /// Shows a list; a proof list is loaded the first time it is opened.
  Future<void> choose(SheetTab tab) async {
    emit(state.copyWith(tab: tab, mailsError: () => null));
    if (tab == SheetTab.late || state.mails.containsKey(tab)) return;
    emit(state.copyWith(mailsLoading: true));
    try {
      final list = await _api.responseMails(mailboxId, range, tab == SheetTab.counted ? 'COUNTED' : 'NOT_THEIRS');
      if (!isClosed) emit(state.copyWith(mails: {...state.mails, tab: list}, mailsLoading: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(mailsLoading: false, mailsError: () => '$e'));
    }
  }
}
