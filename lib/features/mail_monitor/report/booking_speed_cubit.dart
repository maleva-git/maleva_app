import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/network/api_failure.dart';

import 'response_rules.dart';

class BookingSpeedState {
  const BookingSpeedState({
    required this.range,
    this.preset = RangePreset.last7,
    this.report,
    this.loading = false,
    this.error,
    this.errorCode,
  });

  final ReportRange range;

  /// Null for custom dates.
  final RangePreset? preset;

  /// Kept while a reload runs, so the page does not blank out.
  final BookingSpeedReport? report;
  final bool loading;
  final String? error;

  /// 403 (not the Super Admin) or 503 (db/mail-booking-speed.sql not run yet), to word the error.
  final int? errorCode;
}

/// Booking speed for a range (change mail-reading-and-booking-speed): the shared Java
/// `/api/mail-monitor/booking-speed`, the same answer the web page reads. Bookings are recorded by the
/// server's 15-minute scan, so there is no timer.
class BookingSpeedCubit extends Cubit<BookingSpeedState> {
  BookingSpeedCubit(this._api, {DateTime Function()? clock, ReportRange? range, RangePreset? preset})
      : _clock = clock ?? DateTime.now,
        super(BookingSpeedState(
          range: range ?? rangeOf(RangePreset.last7, (clock ?? DateTime.now)()),
          preset: range == null ? RangePreset.last7 : preset,
        ));

  final MailMonitorApi _api;
  final DateTime Function() _clock;

  Future<void> load() async {
    final range = state.range;
    emit(BookingSpeedState(range: range, preset: state.preset, report: state.report, loading: true));
    try {
      final report = await _api.bookingSpeed(range);
      if (!isClosed && state.range == range) {
        emit(BookingSpeedState(range: range, preset: state.preset, report: report));
      }
    } catch (e) {
      if (isClosed || state.range != range) return;
      emit(BookingSpeedState(
        range: range,
        preset: state.preset,
        report: state.report,
        error: '$e',
        errorCode: e is ApiFailure ? e.statusCode : null,
      ));
    }
  }

  Future<void> choosePreset(RangePreset preset) => _changeRange(rangeOf(preset, _clock()), preset);

  Future<void> chooseDates(DateTime from, DateTime to) => _changeRange(rangeFromDates(from, to), null);

  Future<void> _changeRange(ReportRange range, RangePreset? preset) async {
    if (range == state.range) return;
    emit(BookingSpeedState(range: range, preset: preset, report: state.report));
    await load();
  }
}
