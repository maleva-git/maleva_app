import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/planning/plans/data/plans_repository.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/models/plans_filter.dart';
import 'package:maleva/features/planning/plans/models/plans_notice.dart';

part 'plans_event.dart';
part 'plans_state.dart';

/// Opens a report URL (the device browser in the app; a fake in tests).
typedef PlansUrlOpener = Future<void> Function(String url);

/// Planning View (`P/PlanningView.tsx`): the saved plans of the filters, with the web's checks
/// and messages. The list loads on open and on View / search / chip (decision: on Apply, not on
/// every keystroke as React does, K11).
class PlansBloc extends Bloc<PlansEvent, PlansState> {
  PlansBloc({required PlansRepository repository, required PlansUrlOpener openUrl, DateTime Function()? today})
      : _repository = repository,
        _openUrl = openUrl,
        _today = today ?? Fmt.today,
        super(_initial((today ?? Fmt.today)())) {
    on<PlansStarted>(_onStarted);
    on<PlansDraftChanged>((e, emit) => emit(state.copyWith(draft: e.filter)));
    on<PlansApplied>((e, emit) => _load(state.draft, emit));
    on<PlansCleared>((e, emit) => _load(PlansFilter.initial(_today()).copyWith(reportDate: state.draft.reportDate), emit));
    on<PlansSearchSubmitted>((e, emit) => _load(state.draft.copyWith(planningNo: e.planningNo.trim()), emit));
    on<PlansQuickFilterChanged>((e, emit) => _load(e.filter, emit));
    on<PlansRefreshed>((e, emit) => _load(state.applied.copyWith(reportDate: state.draft.reportDate), emit));
    on<PlansReportDateChanged>((e, emit) => emit(state.copyWith(draft: state.draft.copyWith(reportDate: e.date))));
    on<PlanSelected>((e, emit) => emit(state.copyWith(selectedId: () => e.id)));
    on<PlanReportRequested>(_onReport);
  }

  static const companyMissing = 'Company is not available yet';
  static const datesOutOfOrder = 'From date cannot be greater than to date';
  static const loadFailed = 'Failed to load planning list';
  static const reportDetailsMissing = 'Planning details are missing for the Planning report.';
  static const reportFailed = 'Could not open the Planning report';

  final PlansRepository _repository;
  final PlansUrlOpener _openUrl;
  final DateTime Function() _today;
  int _request = 0;
  int _noticeId = 0;

  static PlansState _initial(DateTime today) {
    final f = PlansFilter.initial(today);
    return PlansState(draft: f, applied: f);
  }

  Future<void> _onStarted(PlansStarted event, Emitter<PlansState> emit) async {
    await Future.wait([_load(state.draft, emit), _loadEmployees(emit)]);
  }

  Future<void> _loadEmployees(Emitter<PlansState> emit) async {
    try {
      final list = await _repository.employees();
      if (!emit.isDone) emit(state.copyWith(employees: list));
    } catch (_) {
      // The picker stays empty; the list itself still works.
    }
  }

  /// `handleView` (`PlanningView.tsx:92-120`).
  Future<void> _load(PlansFilter filter, Emitter<PlansState> emit) async {
    emit(state.copyWith(draft: filter));
    if (_repository.companyId <= 0) {
      emit(state.copyWith(notice: _notice(companyMissing)));
      return;
    }
    if (!filter.datesInOrder) {
      emit(state.copyWith(notice: _notice(datesOutOfOrder)));
      return;
    }
    final request = ++_request;
    emit(state.copyWith(status: PlansStatus.loading, applied: filter));
    try {
      final rows = await _repository.list(
        from: filter.fromDate,
        to: filter.toDate,
        search: filter.planningNo.trim(),
        employeeId: filter.loginEmployee ? _repository.employeeId : filter.employeeId,
      );
      if (request != _request || emit.isDone) return;
      final keep = rows.any((r) => r.id == state.selectedId);
      emit(state.copyWith(status: PlansStatus.success, rows: rows, selectedId: keep ? null : () => null));
    } catch (_) {
      if (request != _request || emit.isDone) return;
      emit(state.copyWith(status: PlansStatus.failure, notice: _notice(loadFailed)));
    }
  }

  /// `planningReportApi.openReport` with the page's Report Date.
  Future<void> _onReport(PlanReportRequested event, Emitter<PlansState> emit) async {
    final plan = event.plan;
    if (_repository.companyId <= 0 || plan.id <= 0) {
      emit(state.copyWith(notice: _notice(reportDetailsMissing)));
      return;
    }
    if (state.reportBusyId != null) return;
    emit(state.copyWith(reportBusyId: () => plan.id));
    String? error;
    try {
      final url = await _repository.reportUrl(plan.id, state.draft.reportDate);
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

  PlansNotice _notice(String message, {PlansNoticeKind kind = PlansNoticeKind.error}) => PlansNotice(++_noticeId, message, kind: kind);
}
