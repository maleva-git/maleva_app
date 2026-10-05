part of 'rti_list_bloc.dart';

/// `initial`: no company yet ("Waiting for login..."); `slow`: still loading after 30 s.
enum RtiListStatus { initial, loading, slow, success, failure }

class RtiPreviewState extends Equatable {
  const RtiPreviewState({required this.id, this.loading = true, this.data});

  final int id;
  final bool loading;

  /// Null while loading, or when the full RTI could not be read (the list row still shows).
  final RtiPreviewData? data;

  @override
  List<Object?> get props => [id, loading, data];
}

class RtiListState extends Equatable {
  const RtiListState({
    required this.draft,
    required this.applied,
    this.status = RtiListStatus.initial,
    this.rows = const [],
    this.error = '',
    this.find = '',
    this.preview,
    this.drivers = const [],
    this.trucks = const [],
    this.isDriver = false,
    this.shareBusyId,
    this.reportBusyId,
    this.notice,
  });

  final RtiListFilter draft;
  final RtiListFilter applied;
  final RtiListStatus status;

  /// The server's rows for [applied].
  final List<RtiListRow> rows;
  final String error;
  final String find;
  final RtiPreviewState? preview;
  final List<PickOption<int>> drivers;
  final List<PickOption<int>> trucks;

  /// A driver login: no My RTIs, pickers, share or edit (the server keeps a driver to their own RTIs).
  final bool isDriver;
  final int? shareBusyId;
  final int? reportBusyId;
  final RtiListNotice? notice;

  bool get loading => status == RtiListStatus.loading || status == RtiListStatus.slow;

  /// The rows shown: Not Salary Entered (amount 0) and the find (RTI or job number).
  List<RtiListRow> get visible {
    final q = find.trim().toLowerCase();
    return [
      for (final r in rows)
        if ((!applied.notSalary || r.salaryMissing) &&
            (q.isEmpty || r.rtiNo.toLowerCase().contains(q) || r.jobs.any((j) => j.jobNo.toLowerCase().contains(q))))
          r,
    ];
  }

  /// "Total Amount" of the rows shown.
  double get totalAmount => visible.fold(0, (sum, r) => sum + r.amount);

  /// The previewed row (it must still be shown).
  RtiListRow? get selected {
    final id = preview?.id;
    if (id == null) return null;
    for (final r in visible) {
      if (r.id == id) return r;
    }
    return null;
  }

  RtiListState copyWith({
    RtiListFilter? draft,
    RtiListFilter? applied,
    RtiListStatus? status,
    List<RtiListRow>? rows,
    String? error,
    String? find,
    RtiPreviewState? Function()? preview,
    List<PickOption<int>>? drivers,
    List<PickOption<int>>? trucks,
    int? Function()? shareBusyId,
    int? Function()? reportBusyId,
    RtiListNotice? notice,
  }) =>
      RtiListState(
        draft: draft ?? this.draft,
        applied: applied ?? this.applied,
        status: status ?? this.status,
        rows: rows ?? this.rows,
        error: error ?? this.error,
        find: find ?? this.find,
        preview: preview == null ? this.preview : preview(),
        drivers: drivers ?? this.drivers,
        trucks: trucks ?? this.trucks,
        isDriver: isDriver,
        shareBusyId: shareBusyId == null ? this.shareBusyId : shareBusyId(),
        reportBusyId: reportBusyId == null ? this.reportBusyId : reportBusyId(),
        notice: notice ?? this.notice,
      );

  @override
  List<Object?> get props =>
      [draft, applied, status, rows, error, find, preview, drivers, trucks, isDriver, shareBusyId, reportBusyId, notice];
}
