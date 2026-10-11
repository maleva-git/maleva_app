import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/network/api_failure.dart';

import 'response_rules.dart';
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
    this.speechUnavailable = false,
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
  final bool speechUnavailable;

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
    bool? speechUnavailable,
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
        speechUnavailable: speechUnavailable ?? this.speechUnavailable,
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
    emit(state.copyWith(summaryLoading: true, summaryError: () => null));
    try {
      final summary = await _api.responseSummary(range);
      if (!isClosed && state.range == range) emit(state.copyWith(summary: () => summary, summaryLoading: false));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(summaryLoading: false, summaryError: () => '$e'));
    }
  }

  /// Read aloud, or Stop while speaking.
  Future<void> toggleSpeech() async {
    if (state.speaking) return _stopSpeaking();
    final points = state.summary?.points ?? const [];
    if (points.isEmpty) return;
    emit(state.copyWith(speaking: true, speechUnavailable: false));
    final ok = await _speaker.speak(points.join('. '));
    if (!isClosed) emit(state.copyWith(speaking: false, speechUnavailable: !ok));
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

class LateMailState {
  const LateMailState({this.list, this.loading = true, this.error});

  final LateList? list;
  final bool loading;
  final String? error;
}

/// One mailbox's late mail, for the sheet.
class LateMailCubit extends Cubit<LateMailState> {
  LateMailCubit(this._api, this.mailboxId, this.range) : super(const LateMailState());

  final MailMonitorApi _api;
  final int mailboxId;
  final ReportRange range;

  Future<void> load() async {
    emit(const LateMailState());
    try {
      final list = await _api.responseLate(mailboxId, range);
      if (!isClosed) emit(LateMailState(list: list, loading: false));
    } catch (e) {
      if (!isClosed) emit(LateMailState(loading: false, error: '$e'));
    }
  }
}
