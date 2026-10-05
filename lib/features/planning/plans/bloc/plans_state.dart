part of 'plans_bloc.dart';

enum PlansStatus { initial, loading, success, failure }

class PlansState extends Equatable {
  const PlansState({
    required this.draft,
    required this.applied,
    this.status = PlansStatus.initial,
    this.rows = const [],
    this.employees = const [],
    this.selectedId,
    this.reportBusyId,
    this.notice,
  });

  /// What the filter form shows.
  final PlansFilter draft;

  /// The filters of the rows shown.
  final PlansFilter applied;
  final PlansStatus status;
  final List<PlanRow> rows;
  final List<PickOption<int>> employees;
  final int? selectedId;

  /// The plan whose report is being prepared.
  final int? reportBusyId;
  final PlansNotice? notice;

  bool get loading => status == PlansStatus.loading;

  /// "From date cannot be greater than to date", shown under the dates.
  bool get dateError => !draft.datesInOrder;

  /// The tablet's preview: the picked plan, else the first one.
  PlanRow? get selected {
    if (rows.isEmpty) return null;
    for (final r in rows) {
      if (r.id == selectedId) return r;
    }
    return rows.first;
  }

  PlansState copyWith({
    PlansFilter? draft,
    PlansFilter? applied,
    PlansStatus? status,
    List<PlanRow>? rows,
    List<PickOption<int>>? employees,
    int? Function()? selectedId,
    int? Function()? reportBusyId,
    PlansNotice? notice,
  }) =>
      PlansState(
        draft: draft ?? this.draft,
        applied: applied ?? this.applied,
        status: status ?? this.status,
        rows: rows ?? this.rows,
        employees: employees ?? this.employees,
        selectedId: selectedId == null ? this.selectedId : selectedId(),
        reportBusyId: reportBusyId == null ? this.reportBusyId : reportBusyId(),
        notice: notice ?? this.notice,
      );

  @override
  List<Object?> get props => [draft, applied, status, rows, employees, selectedId, reportBusyId, notice];
}
