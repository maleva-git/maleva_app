import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/planning_access.dart';

enum PlanPhase { loading, ready, employeesFailed }

enum NoticeKind { success, info, error }

/// A one-off message for the screen (the web's toasts). [seq] makes each one new.
class PlanNotice {
  const PlanNotice(this.message, this.kind, this.seq);

  final String message;
  final NoticeKind kind;
  final int seq;
}

/// The summary tiles that filter the list (phone and tablet).
enum TileFilter { all, unassigned, assigned, inRti }

/// Create RTI's sheet: review → working → done / refused.
enum RtiCreateStage { idle, working, done, refused }

class PlanState {
  const PlanState({
    this.phase = PlanPhase.loading,
    this.actions = const {'VIEW'},
    this.editId = 0,
    this.header = const PlanHeader(),
    this.rows = const [],
    this.dirtyJobIds = const {},
    this.changedUids = const {},
    this.structureChanged = false,
    this.headerChanged = false,
    this.selectedUid,
    this.employees = const [],
    this.ports = const [],
    this.trucks = const [],
    this.drivers = const [],
    this.searching = false,
    this.saving = false,
    this.deleting = false,
    this.fetchingPlan = false,
    this.searchError,
    this.tile = TileFilter.all,
    this.find = '',
    this.notice,
    this.rtiKey = '',
    this.rtiStage = RtiCreateStage.idle,
    this.rtiMessage = '',
    this.recentTrucks = const {},
    this.recentDrivers = const {},
  });

  final PlanPhase phase;

  /// The role's Screen Access actions (VIEW only until they arrive).
  final Set<String> actions;
  final int editId;
  final PlanHeader header;
  final List<PlanLine> rows;

  /// The web's `dirtyRowIds`: jobs edited here, kept when the same plan is read again.
  final Set<int> dirtyJobIds;

  /// Rows changed since the plan was loaded or saved (the "N changes" bar).
  final Set<int> changedUids;
  final bool structureChanged;
  final bool headerChanged;

  /// The row the detail pane, Update, Clone and the Delete key act on.
  final int? selectedUid;
  final List<EmployeeOption> employees;
  final List<String> ports;
  final List<TruckOption> trucks;
  final List<DriverOption> drivers;
  final bool searching;
  final bool saving;
  final bool deleting;
  final bool fetchingPlan;

  /// The search refusal shown under the form ("Please enter at least one search criteria").
  final String? searchError;
  final TileFilter tile;
  final String find;
  final PlanNotice? notice;
  final String rtiKey;
  final RtiCreateStage rtiStage;
  final String rtiMessage;
  final Set<int> recentTrucks;
  final Set<int> recentDrivers;

  PlanningAccess get access => PlanningAccess.resolve(actions, planningModeFor(editId));

  int get changeCount => changedUids.length + (structureChanged ? 1 : 0) + (headerChanged ? 1 : 0);
  bool get hasChanges => changeCount > 0;
  bool get busy => saving || deleting;

  PlanLine? get selected => selectedUid == null ? null : rows.where((r) => r.uid == selectedUid).firstOrNull;
  List<PlanLine> get ticked => rows.where((r) => r.print).toList();

  /// Q-COUNT: the selected counter counts the ticked rows.
  int get tickedCount => rows.where((r) => r.print).length;

  int get unassignedCount => rows.where(isUnassigned).length;
  int get assignedCount => rows.length - unassignedCount;
  int get inRtiCount => rows.where((r) => r.rtiNo.isNotEmpty).length;

  static bool isUnassigned(PlanLine r) => r.truckName.trim().isEmpty || r.driverName.trim().isEmpty;

  /// The rows the tiles and the find box leave (find filters the loaded rows only).
  List<PlanLine> get visibleRows {
    final q = find.trim().toLowerCase();
    return rows.where((r) {
      switch (tile) {
        case TileFilter.unassigned:
          if (!isUnassigned(r)) return false;
        case TileFilter.assigned:
          if (isUnassigned(r)) return false;
        case TileFilter.inRti:
          if (r.rtiNo.isEmpty) return false;
        case TileFilter.all:
          break;
      }
      if (q.isEmpty) return true;
      return [r.truckName, r.driverName, r.customerName, r.vesselName, r.jobNo, r.status].join(' ').toLowerCase().contains(q);
    }).toList();
  }

  /// Other rows on the selected row's truck (`PlanningList.tsx:132-151`; "ASSIGN" is not a truck).
  List<PlanLine> sameTruckAs(PlanLine row) {
    final truck = row.truckName.trim().toUpperCase();
    if (truck.isEmpty || truck == 'ASSIGN') return const [];
    return rows.where((r) => r.uid != row.uid && r.truckName.trim().toUpperCase() == truck).toList();
  }

  PlanState copyWith({
    PlanPhase? phase,
    Set<String>? actions,
    int? editId,
    PlanHeader? header,
    List<PlanLine>? rows,
    Set<int>? dirtyJobIds,
    Set<int>? changedUids,
    bool? structureChanged,
    bool? headerChanged,
    int? Function()? selectedUid,
    List<EmployeeOption>? employees,
    List<String>? ports,
    List<TruckOption>? trucks,
    List<DriverOption>? drivers,
    bool? searching,
    bool? saving,
    bool? deleting,
    bool? fetchingPlan,
    String? Function()? searchError,
    TileFilter? tile,
    String? find,
    PlanNotice? notice,
    String? rtiKey,
    RtiCreateStage? rtiStage,
    String? rtiMessage,
    Set<int>? recentTrucks,
    Set<int>? recentDrivers,
  }) =>
      PlanState(
        phase: phase ?? this.phase,
        actions: actions ?? this.actions,
        editId: editId ?? this.editId,
        header: header ?? this.header,
        rows: rows ?? this.rows,
        dirtyJobIds: dirtyJobIds ?? this.dirtyJobIds,
        changedUids: changedUids ?? this.changedUids,
        structureChanged: structureChanged ?? this.structureChanged,
        headerChanged: headerChanged ?? this.headerChanged,
        selectedUid: selectedUid != null ? selectedUid() : this.selectedUid,
        employees: employees ?? this.employees,
        ports: ports ?? this.ports,
        trucks: trucks ?? this.trucks,
        drivers: drivers ?? this.drivers,
        searching: searching ?? this.searching,
        saving: saving ?? this.saving,
        deleting: deleting ?? this.deleting,
        fetchingPlan: fetchingPlan ?? this.fetchingPlan,
        searchError: searchError != null ? searchError() : this.searchError,
        tile: tile ?? this.tile,
        find: find ?? this.find,
        notice: notice ?? this.notice,
        rtiKey: rtiKey ?? this.rtiKey,
        rtiStage: rtiStage ?? this.rtiStage,
        rtiMessage: rtiMessage ?? this.rtiMessage,
        recentTrucks: recentTrucks ?? this.recentTrucks,
        recentDrivers: recentDrivers ?? this.recentDrivers,
      );
}
