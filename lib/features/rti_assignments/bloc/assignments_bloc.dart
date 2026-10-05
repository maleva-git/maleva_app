import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/employee_assignments_api.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';
import 'package:maleva/features/rti_assignments/data/assignments_repository.dart';
import 'package:maleva/features/rti_assignments/models/assignments_filter.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';

part 'assignments_event.dart';

typedef AssignmentsUrlOpener = Future<void> Function(String url);

/// `idle`: nothing searched yet (React loads only on Search / Refresh).
enum AssignmentsStatus { idle, loading, success, failure }

class AssignmentsNotice extends Equatable {
  const AssignmentsNotice(this.id, this.message);

  final int id;
  final String message;

  @override
  List<Object?> get props => [id, message];
}

class AssignmentsState extends Equatable {
  const AssignmentsState({
    required this.filter,
    this.status = AssignmentsStatus.idle,
    this.rows = const [],
    this.error = '',
    this.employees = const [],
    this.userName = '',
    this.reportBusyId,
    this.notice,
  });

  final AssignmentsFilter filter;
  final AssignmentsStatus status;
  final List<EmployeeAssignment> rows;
  final String error;
  final List<PickOption<int>> employees;
  final String userName;
  final int? reportBusyId;
  final AssignmentsNotice? notice;

  /// The rows shown: with "My Job Only" ticked, the jobs whose employee or driver name is the
  /// user's (`activeJobs`, applied at once as React does).
  List<EmployeeAssignment> get visible =>
      filter.myJobOnly ? [for (final r in rows) if (r.employeeName == userName || r.driverName == userName) r] : rows;

  AssignmentsState copyWith({
    AssignmentsFilter? filter,
    AssignmentsStatus? status,
    List<EmployeeAssignment>? rows,
    String? error,
    List<PickOption<int>>? employees,
    int? Function()? reportBusyId,
    AssignmentsNotice? notice,
  }) =>
      AssignmentsState(
        filter: filter ?? this.filter,
        status: status ?? this.status,
        rows: rows ?? this.rows,
        error: error ?? this.error,
        employees: employees ?? this.employees,
        userName: userName,
        reportBusyId: reportBusyId == null ? this.reportBusyId : reportBusyId(),
        notice: notice ?? this.notice,
      );

  @override
  List<Object?> get props => [filter, status, rows, error, employees, userName, reportBusyId, notice];
}

/// Employee Assignments (`R/pages/EmployeeAssignmentsPage.tsx`, rows EA1–EA3). Export (EA4) is
/// not built: React's button has no handler.
class AssignmentsBloc extends Bloc<AssignmentsEvent, AssignmentsState> {
  AssignmentsBloc({required AssignmentsRepository repository, required AssignmentsUrlOpener openUrl, DateTime Function()? today})
      : _repository = repository,
        _openUrl = openUrl,
        _today = today ?? Fmt.today,
        super(AssignmentsState(filter: AssignmentsFilter.initial((today ?? Fmt.today)()), userName: repository.userName)) {
    on<AssignmentsStarted>(_onStarted);
    on<AssignmentsFilterChanged>((e, emit) => emit(state.copyWith(filter: e.filter)));
    on<AssignmentsSearchRequested>(_onSearch);
    on<AssignmentsCleared>((e, emit) => emit(state.copyWith(filter: AssignmentsFilter.initial(_today()))));
    on<AssignmentReportRequested>(_onReport);
  }

  static const datesRequired = 'Please select both From and To dates';
  static const rtiNumberMissing = 'RTI Number is missing';
  static const reportDetailsMissing = 'RTI details are missing for the RTI report.';
  static const reportFailed = 'Could not open the RTI report';
  static const reportError = 'Failed to open RTI report';

  final AssignmentsRepository _repository;
  final AssignmentsUrlOpener _openUrl;
  final DateTime Function() _today;
  int _request = 0;
  int _noticeId = 0;

  Future<void> _onStarted(AssignmentsStarted event, Emitter<AssignmentsState> emit) async {
    try {
      final list = await _repository.employees();
      if (!emit.isDone) emit(state.copyWith(employees: list));
    } catch (_) {
      // The picker stays empty.
    }
  }

  /// `handleSearch`.
  Future<void> _onSearch(AssignmentsSearchRequested event, Emitter<AssignmentsState> emit) async {
    final f = state.filter;
    if (f.fromDate == null || f.toDate == null) {
      emit(state.copyWith(notice: AssignmentsNotice(++_noticeId, datesRequired)));
      return;
    }
    final employeeId = f.myJobOnly ? _repository.employeeId : f.employeeId;
    final request = ++_request;
    emit(state.copyWith(status: AssignmentsStatus.loading, error: ''));
    try {
      final rows = await _repository.fetch(from: f.fromDate!, to: f.toDate!, employeeId: employeeId);
      if (request != _request || emit.isDone) return;
      emit(state.copyWith(status: AssignmentsStatus.success, rows: rows));
    } catch (e) {
      if (request != _request || emit.isDone) return;
      final message = e is ApiFailure && e.message.trim().isNotEmpty ? e.message : EmployeeAssignmentsApi.fallbackError;
      emit(state.copyWith(status: AssignmentsStatus.failure, rows: const [], error: message));
    }
  }

  /// `handleViewReport`.
  Future<void> _onReport(AssignmentReportRequested event, Emitter<AssignmentsState> emit) async {
    final job = event.job;
    if (job.rtiNumber.isEmpty) {
      emit(state.copyWith(notice: AssignmentsNotice(++_noticeId, rtiNumberMissing)));
      return;
    }
    if (_repository.companyId <= 0 || job.rtiMasterRefId <= 0) {
      emit(state.copyWith(notice: AssignmentsNotice(++_noticeId, reportDetailsMissing)));
      return;
    }
    if (state.reportBusyId != null) return;
    emit(state.copyWith(reportBusyId: () => job.rtiMasterRefId));
    String? error;
    try {
      final url = await _repository.reportUrl(job.rtiMasterRefId);
      if (url.isEmpty) {
        error = reportFailed;
      } else {
        await _openUrl(url);
      }
    } on ApiFailure catch (e) {
      error = e.message.trim().isEmpty ? reportFailed : e.message;
    } catch (_) {
      error = reportError;
    }
    if (emit.isDone) return;
    emit(state.copyWith(reportBusyId: () => null, notice: error == null ? null : AssignmentsNotice(++_noticeId, error)));
  }
}
