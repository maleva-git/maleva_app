import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/bloc/plan_cubit_base.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/data/sale_order_update.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';

/// The grid's row actions: tick, assign, edit, clone, remove, sort, reorder.
/// Truck and driver are never changed by anything but the user's own pick.
mixin PlanRowOps on Cubit<PlanState>, PlanCubitBase {
  void selectRow(int? uid) => emit(state.copyWith(selectedUid: () => uid));

  /// The tick (`togglePrint`); read-only roles cannot tick.
  void toggleTick(int uid) {
    if (!state.access.canWrite) return;
    final rows = mapRows({uid}, (r) => r.copyWith(print: !r.print));
    final row = rows.firstWhere((r) => r.uid == uid);
    emit(state.copyWith(rows: rows, dirtyJobIds: {...state.dirtyJobIds, if (row.saleOrderMasterRefId != 0) row.saleOrderMasterRefId}));
  }

  /// Ticks or unticks [uids] together (multi-select on the phone and the board).
  void setTicks(Set<int> uids, bool ticked) {
    if (!state.access.canWrite) return;
    emit(state.copyWith(rows: mapRows(uids, (r) => r.copyWith(print: ticked))));
  }

  void clearTicks() => emit(state.copyWith(rows: [for (final r in state.rows) r.print ? r.copyWith(print: false) : r]));

  void _edit(Set<int> uids, PlanLine Function(PlanLine) change) {
    if (!guardWrite()) return;
    final rows = mapRows(uids, change);
    emit(markEdited(state.copyWith(rows: rows), rows.where((r) => uids.contains(r.uid))));
  }

  /// A truck from the picker (`handleTruckSelect`): only TRUCK changes, on [uids] only. The
  /// truck's expiry warnings follow, as the web's toast after the pick.
  void assignTruck(Set<int> uids, TruckOption truck, {DateTime? today}) {
    if (!guardWrite()) return;
    _edit(uids, (r) => r.copyWith(truckName: truck.name, truckRefid: truck.id));
    emit(state.copyWith(recentTrucks: {...state.recentTrucks, truck.id}));
    final exp = truck.expiry(today: today);
    if (exp.warnings.isNotEmpty) {
      notify(exp.warnings.map((w) => w.message).join('\n'), exp.severity == ExpirySeverity.critical ? NoticeKind.error : NoticeKind.info);
    }
  }

  /// The X on TRUCK: id 0 and every truck name cleared.
  void clearTruck(Set<int> uids) => _edit(uids, (r) => r.copyWith(truckRefid: 0, truckName: '', truckNameD: ''));

  /// A driver from the picker (`handleDriverSelect`): only DRIVER changes. An OUTSIDE DRIVER
  /// entry carries the typed [outsideName] with that entry's id.
  void assignDriver(Set<int> uids, DriverOption driver, {String outsideName = '', DateTime? today}) {
    if (!guardWrite()) return;
    final name = (outsideName.isNotEmpty ? outsideName : driver.name).trim();
    _edit(uids, (r) => r.copyWith(driverName: name, driverRefid: driver.id));
    emit(state.copyWith(recentDrivers: {...state.recentDrivers, driver.id}));
    if (outsideName.isNotEmpty) return;
    final exp = driver.expiry(today: today);
    if (exp.warnings.isNotEmpty) {
      final loud = exp.severity == ExpirySeverity.critical || exp.severity == ExpirySeverity.leaveApproved;
      notify(exp.warnings.map((w) => w.message).join('\n'), loud ? NoticeKind.error : NoticeKind.info);
    }
  }

  /// A typed driver name (no truck, or the OUTSIDE DRIVER truck): the name and no driver id.
  void typeDriver(Set<int> uids, String name) => _edit(uids, (r) => r.copyWith(driverName: name, driverNameD: name, driverRefid: 0));

  /// The X on DRIVER: id 0 and every driver name cleared.
  void clearDriver(Set<int> uids) => _edit(uids, (r) => r.copyWith(driverRefid: 0, driverName: '', driverNameD: ''));

  void editRemarks(int uid, String value) => _edit({uid}, (r) => r.copyWith(remarks: value));

  void editSort(int uid, String value) => _edit({uid}, (r) => r.copyWith(sortByD: value));

  /// Sort (`sortPlanningRows`).
  void sort() {
    if (!guardWrite()) return;
    emit(state.copyWith(rows: PlanningRules.sortRows(state.rows), structureChanged: true));
  }

  /// Clone's check before its confirm: the refusal is shown and false answered.
  bool canClone([int? uid]) {
    if (!guardWrite()) return false;
    final row = uid == null ? state.selected : state.rows.where((r) => r.uid == uid).firstOrNull;
    final refusal = PlanningRules.cloneRefusal(row);
    if (refusal != null) {
      notify(refusal, NoticeKind.error);
      return false;
    }
    return true;
  }

  /// Clone, after "Duplicate Planning Row?": the copy goes to the end with no truck.
  void clone([int? uid]) {
    if (!canClone(uid)) return;
    final row = uid == null ? state.selected! : state.rows.firstWhere((r) => r.uid == uid);
    final copy = PlanningRules.cloneOf(row);
    emit(state.copyWith(rows: [...state.rows, copy], structureChanged: true));
    notify('Row duplicated successfully');
    syncRtiStatuses();
  }

  /// Remove, after "Delete Record".
  void remove(int uid) {
    if (!guardWrite()) return;
    emit(state.copyWith(
      rows: [
        for (final r in state.rows)
          if (r.uid != uid) r
      ],
      structureChanged: true,
      selectedUid: state.selectedUid == uid ? () => null : null,
    ));
    notify('Row removed');
    syncRtiStatuses();
  }

  /// Drag or move up / down: only the order changes; the selection keeps its row.
  void reorder(int from, int to) {
    if (!state.access.canWrite) return;
    final next = PlanningRules.moveRow(state.rows, from, to);
    if (identical(next, state.rows)) return;
    emit(state.copyWith(rows: next, structureChanged: true));
  }

  /// "Update" before its window: the refusal, or null when the selected row may be updated.
  String? updateRefusal([int? uid]) {
    if (!state.access.canWrite) return state.access.deniedReason;
    final row = uid == null ? state.selected : state.rows.where((r) => r.uid == uid).firstOrNull;
    if (row == null) return 'Please select a row first';
    if (row.saleOrderMasterRefId == 0) return 'Selected row does not have a sale order to update';
    return null;
  }

  /// The Update window's saved values onto every row of that job (no reload).
  void applySaleOrderUpdate(Map<String, dynamic> saved) {
    final next = SaleOrderUpdateRules.applyToRows(state.rows, saved);
    if (!identical(next, state.rows)) emit(state.copyWith(rows: next));
  }

  /// A copied value (`Copied: {value}`).
  void copied(String value) => notify('Copied: $value');

  void setTile(TileFilter tile) => emit(state.copyWith(tile: tile));

  void setFind(String value) => emit(state.copyWith(find: value));
}
