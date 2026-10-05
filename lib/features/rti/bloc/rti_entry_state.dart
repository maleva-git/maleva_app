import 'package:equatable/equatable.dart';
import 'package:maleva/features/rti/data/rti_entry_repository.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

enum RtiLoadStatus { loading, ready, failed }

enum RtiNoticeKind { success, info, warning, error }

/// A one-time message for the screen (the web's toast or alert modal). [seq] makes each new.
class RtiNotice extends Equatable {
  const RtiNotice(this.text, this.kind, this.seq, {this.long = false});

  final String text;
  final RtiNoticeKind kind;
  final int seq;

  /// Shown longer (the web's 7–10 s toasts).
  final bool long;

  @override
  List<Object?> get props => [text, kind, seq, long];
}

/// One job value the revise changed: was → now (decision Q-REV = B).
class RtiReviseChange extends Equatable {
  const RtiReviseChange(this.label, this.was, this.now);

  final String label;
  final String was;
  final String now;

  @override
  List<Object?> get props => [label, was, now];
}

/// What the screen is busy with; one at a time, so a second Save is ignored.
enum RtiBusy { none, saving, deleting, revising, lookingUp }

class RtiEntryState extends Equatable {
  const RtiEntryState({
    this.status = RtiLoadStatus.loading,
    this.loadError,
    required this.form,
    this.grid = const [RtiJobRow()],
    this.stops = const [],
    this.refs = const RtiReferences(),
    this.refsLoading = true,
    this.refsError,
    this.busy = RtiBusy.none,
    this.lookupRow,
    this.errors = const [],
    this.licenceWarning,
    this.reviseChanges = const {},
    this.inRevise = false,
    this.step = 0,
    this.notice,
  });

  final RtiLoadStatus status;
  final String? loadError;
  final RtiForm form;
  final List<RtiJobRow> grid;
  final List<RtiStop> stops;
  final RtiReferences refs;
  final bool refsLoading;
  final String? refsError;
  final RtiBusy busy;

  /// The grid row whose Job No is being looked up.
  final int? lookupRow;

  /// The save checks that failed, all together (shown on Review / above the grid).
  final List<String> errors;

  /// The vehicle licence banner of a new RTI.
  final String? licenceWarning;

  /// Revise B: the changed values per job line, keyed by the line's sale order id.
  final Map<int, List<RtiReviseChange>> reviseChanges;

  /// The form holds a revise that is not yet saved.
  final bool inRevise;

  /// The phone wizard's step, 0–4.
  final int step;
  final RtiNotice? notice;

  double get total => RtiRules.total(form, grid);
  bool get isBusy => busy != RtiBusy.none;
  int get filledJobs => grid.where((r) => r.jobNo.isNotEmpty).length;
  double get salaryTotal => RtiRules.salaryTotal(grid);
  int get reviseChangeCount => reviseChanges.values.fold(0, (n, l) => n + l.length);

  Map<String, dynamic>? driverRow(String id) => _row(refs.drivers, id);
  Map<String, dynamic>? truckRow(String id) => _row(refs.trucks, id);

  static Map<String, dynamic>? _row(List<Map<String, dynamic>> rows, String id) {
    if (id.isEmpty) return null;
    for (final r in rows) {
      if ('${r['id'] ?? r['Id'] ?? ''}' == id) return r;
    }
    return null;
  }

  RtiEntryState copyWith({
    RtiLoadStatus? status,
    Object? loadError = _keep,
    RtiForm? form,
    List<RtiJobRow>? grid,
    List<RtiStop>? stops,
    RtiReferences? refs,
    bool? refsLoading,
    Object? refsError = _keep,
    RtiBusy? busy,
    Object? lookupRow = _keep,
    List<String>? errors,
    Object? licenceWarning = _keep,
    Map<int, List<RtiReviseChange>>? reviseChanges,
    bool? inRevise,
    int? step,
    Object? notice = _keep,
  }) =>
      RtiEntryState(
        status: status ?? this.status,
        loadError: identical(loadError, _keep) ? this.loadError : loadError as String?,
        form: form ?? this.form,
        grid: grid ?? this.grid,
        stops: stops ?? this.stops,
        refs: refs ?? this.refs,
        refsLoading: refsLoading ?? this.refsLoading,
        refsError: identical(refsError, _keep) ? this.refsError : refsError as String?,
        busy: busy ?? this.busy,
        lookupRow: identical(lookupRow, _keep) ? this.lookupRow : lookupRow as int?,
        errors: errors ?? this.errors,
        licenceWarning: identical(licenceWarning, _keep) ? this.licenceWarning : licenceWarning as String?,
        reviseChanges: reviseChanges ?? this.reviseChanges,
        inRevise: inRevise ?? this.inRevise,
        step: step ?? this.step,
        notice: identical(notice, _keep) ? this.notice : notice as RtiNotice?,
      );

  @override
  List<Object?> get props => [
        status, loadError, form, grid, stops, refs, refsLoading, refsError, busy, lookupRow, errors,
        licenceWarning, reviseChanges, inRevise, step, notice,
      ];
}

const Object _keep = Object();
