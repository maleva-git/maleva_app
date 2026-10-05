import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/rti/list/data/rti_list_repository.dart';
import 'package:maleva/features/rti/list/models/rti_list_filter.dart';
import 'package:maleva/features/rti/list/models/rti_list_notice.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';

part 'rti_list_event.dart';
part 'rti_list_state.dart';

/// Opens a report URL (the device browser in the app; a fake in tests).
typedef RtiUrlOpener = Future<void> Function(String url);

/// The RTI list (`R/pages/RTIViewPage.tsx`, rows RLs1–RLs8, RS1, RS2) on `/with-jobs`.
class RtiListBloc extends Bloc<RtiListEvent, RtiListState> {
  RtiListBloc({
    required RtiListRepository repository,
    required RtiUrlOpener openUrl,
    DateTime Function()? today,
    this.slowAfter = const Duration(seconds: 30),
  })  : _repository = repository,
        _openUrl = openUrl,
        _today = today ?? Fmt.today,
        super(_initial((today ?? Fmt.today)(), repository.isDriver)) {
    on<RtiListStarted>(_onStarted);
    on<RtiListDraftChanged>((e, emit) => emit(state.copyWith(draft: e.filter.copyWith(notSalary: state.applied.notSalary))));
    on<RtiListApplied>((e, emit) => _load(state.draft, emit));
    on<RtiListQuickFilterChanged>((e, emit) => _load(e.filter, emit));
    on<RtiListCleared>((e, emit) => _load(RtiListFilter.cleared(_today()), emit));
    on<RtiListRetried>((e, emit) => _load(state.applied, emit));
    on<RtiListNotSalaryToggled>((e, emit) => emit(state.copyWith(
        draft: state.draft.copyWith(notSalary: e.value), applied: state.applied.copyWith(notSalary: e.value))));
    on<RtiListFindChanged>((e, emit) => emit(state.copyWith(find: e.text)));
    on<RtiListRowSelected>(_onSelected);
    on<RtiListPreviewClosed>((e, emit) => emit(state.copyWith(preview: () => null)));
    on<RtiShareRequested>(_onShare);
    on<RtiReportRequested>(_onReport);
    on<_RtiListSlow>((e, emit) {
      if (e.request == _request && state.status == RtiListStatus.loading) emit(state.copyWith(status: RtiListStatus.slow));
    });
  }

  static const reportDetailsMissing = 'RTI details are missing for the RTI report.';
  static const reportFailed = 'Could not open the RTI report';
  static const notSent = 'The message was not sent';
  static const shareFailed = 'Could not share this RTI';

  /// "Send {rtiNo} to the truck's WhatsApp group?" (`RtiShareWhatsAppButton.tsx:25`).
  static String shareQuestion(String rtiNo) => "Send $rtiNo to the truck's WhatsApp group?";

  /// "{rtiNo} sent to the group of {truck | 'the truck'}".
  static String sentMessage(String rtiNo, String truck) =>
      '$rtiNo sent to the group of ${truck.trim().isEmpty ? 'the truck' : truck}';

  /// How long a load runs before "Still loading records" (React's `LOADING_TIMEOUT_MS`).
  final Duration slowAfter;
  final RtiListRepository _repository;
  final RtiUrlOpener _openUrl;
  final DateTime Function() _today;
  Timer? _slowTimer;
  int _request = 0;
  int _noticeId = 0;

  static RtiListState _initial(DateTime today, bool isDriver) {
    final f = RtiListFilter.initial(today);
    return RtiListState(draft: f, applied: f, isDriver: isDriver);
  }

  Future<void> _onStarted(RtiListStarted event, Emitter<RtiListState> emit) async {
    await Future.wait([_load(state.draft, emit), if (!state.isDriver) _loadPickers(emit)]);
  }

  Future<void> _loadPickers(Emitter<RtiListState> emit) async {
    try {
      final drivers = await _repository.drivers();
      if (!emit.isDone) emit(state.copyWith(drivers: drivers));
    } catch (_) {}
    try {
      final trucks = await _repository.trucks();
      if (!emit.isDone) emit(state.copyWith(trucks: trucks));
    } catch (_) {}
  }

  Future<void> _load(RtiListFilter filter, Emitter<RtiListState> emit) async {
    final f = filter.copyWith(myRtis: state.isDriver ? false : filter.myRtis);
    emit(state.copyWith(draft: f));
    if (_repository.companyId <= 0) return; // React waits for the company ("Waiting for login...")
    final request = ++_request;
    _slowTimer?.cancel();
    _slowTimer = Timer(slowAfter, () {
      if (!isClosed) add(_RtiListSlow(request));
    });
    emit(state.copyWith(status: RtiListStatus.loading, applied: f, error: ''));
    try {
      final rows = await _repository.list(f);
      if (request != _request || emit.isDone) return;
      _slowTimer?.cancel();
      emit(state.copyWith(status: RtiListStatus.success, rows: rows));
    } catch (e) {
      if (request != _request || emit.isDone) return;
      _slowTimer?.cancel();
      final message = e is ApiFailure ? e.message : e.toString();
      emit(state.copyWith(status: RtiListStatus.failure, rows: const [], error: message));
    }
  }

  Future<void> _onSelected(RtiListRowSelected event, Emitter<RtiListState> emit) async {
    if (event.toggle && state.preview?.id == event.id) {
      emit(state.copyWith(preview: () => null));
      return;
    }
    emit(state.copyWith(preview: () => RtiPreviewState(id: event.id)));
    RtiPreviewData? data;
    try {
      data = await _repository.preview(event.id);
    } catch (_) {
      data = null; // React shows '-' for what it could not read
    }
    if (emit.isDone || state.preview?.id != event.id) return;
    emit(state.copyWith(preview: () => RtiPreviewState(id: event.id, loading: false, data: data)));
  }

  /// `RtiShareWhatsAppButton.onClick` after the confirm.
  Future<void> _onShare(RtiShareRequested event, Emitter<RtiListState> emit) async {
    final row = event.row;
    if (state.shareBusyId != null) return;
    emit(state.copyWith(shareBusyId: () => row.id));
    RtiListNotice notice;
    try {
      final r = await _repository.share(row.id);
      if (r.sent) {
        final skipped = r.documentSkipped?.trim() ?? '';
        notice = _notice(sentMessage(r.rtiNo.isEmpty ? row.rtiNo : r.rtiNo, r.truck),
            kind: RtiNoticeKind.success,
            followUp: skipped.isEmpty ? null : _notice(skipped, kind: RtiNoticeKind.info, duration: const Duration(seconds: 10)));
      } else {
        notice = _notice(r.detail.isEmpty ? notSent : r.detail, duration: const Duration(seconds: 8));
      }
    } on ApiFailure catch (e) {
      notice = _notice(e.message.trim().isEmpty ? shareFailed : e.message, duration: const Duration(seconds: 8));
    } catch (_) {
      notice = _notice(shareFailed, duration: const Duration(seconds: 8));
    }
    if (emit.isDone) return;
    emit(state.copyWith(shareBusyId: () => null, notice: notice));
  }

  /// `rtiReportApi.openReport`.
  Future<void> _onReport(RtiReportRequested event, Emitter<RtiListState> emit) async {
    final row = event.row;
    if (_repository.companyId <= 0 || row.id <= 0) {
      emit(state.copyWith(notice: _notice(reportDetailsMissing)));
      return;
    }
    if (state.reportBusyId != null) return;
    emit(state.copyWith(reportBusyId: () => row.id));
    String? error;
    try {
      final url = await _repository.reportUrl(row.id);
      if (url.isEmpty) {
        error = reportFailed;
      } else {
        await _openUrl(url);
      }
    } on ApiFailure catch (e) {
      error = e.message.trim().isEmpty ? reportFailed : e.message;
    } catch (_) {
      error = reportFailed;
    }
    if (emit.isDone) return;
    emit(state.copyWith(reportBusyId: () => null, notice: error == null ? null : _notice(error)));
  }

  RtiListNotice _notice(String message, {RtiNoticeKind kind = RtiNoticeKind.error, Duration? duration, RtiListNotice? followUp}) =>
      RtiListNotice(++_noticeId, message, kind: kind, duration: duration, followUp: followUp);

  @override
  Future<void> close() {
    _slowTimer?.cancel();
    return super.close();
  }
}
