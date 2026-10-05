import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';

/// The plan screen's pure rules, ported from the web with the file each comes from.
abstract final class PlanningRules {
  /// `helpers.ts:264-271` `hasSearchCriteria`.
  static bool hasSearchCriteria(PlanHeader h) =>
      h.searchText.trim().isNotEmpty || h.employee.isNotEmpty || h.pickupFromDate.isNotEmpty || h.pickupToDate.isNotEmpty;

  /// `helpers.ts:138-145` `canSubmitDateRange`: null when the search may run.
  static String? searchDateError(PlanHeader h) => h.planningDate.isEmpty ? 'Please select a Planning Date' : null;

  /// The search's refusal, in the web's order (`usePlanningListPage.ts:572-586`), or null.
  static String? searchRefusal(PlanHeader h) => searchDateError(h) ?? (hasSearchCriteria(h) ? null : 'Please enter at least one search criteria');

  /// `helpers.ts:295-303` `buildSearchPayload`.
  static Map<String, dynamic> searchPayload(int companyId, PlanHeader h) => {
        'comid': companyId,
        'search': h.searchText.trim(),
        'employeeid': Js.intOr0(h.employee),
        'fromdate': h.pickupFromDate,
        'todate': h.pickupToDate,
      };

  /// `planningNumber.ts` `parsePlanningNo`: digits only, 1..2147483647, else null.
  static int? parsePlanningNo(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final parsed = int.tryParse(digits);
    if (parsed == null || parsed <= 0 || parsed > 2147483647) return null;
    return parsed;
  }

  /// PORT "Add" (`usePlanningListPage.ts:416-422`): null when no port is chosen.
  static String? appendPort(PlanHeader h) {
    if (h.port.isEmpty) return null;
    return h.searchText.trim().isNotEmpty ? '${h.searchText},${h.port}' : h.port;
  }

  /// `sortPlanningRows` (`usePlanningOperations.ts:37-57`): drops a last row without a job
  /// number (when there is more than one row), then SORT ascending with 0 / empty last.
  static List<PlanLine> sortRows(List<PlanLine> rows) {
    var data = [...rows];
    if (data.length > 1 && data.last.jobNo.trim().isEmpty) data = data.sublist(0, data.length - 1);
    final indexed = [for (var i = 0; i < data.length; i++) (i, data[i])];
    indexed.sort((a, b) {
      double n(String v) => Js.number(v).isNaN ? 0 : Js.number(v);
      final va = n(a.$2.sortByD);
      final vb = n(b.$2.sortByD);
      if (va == 0 && vb != 0) return 1;
      if (vb == 0 && va != 0) return -1;
      final c = va.compareTo(vb);
      return c != 0 ? c : a.$1.compareTo(b.$1); // Array.sort is stable
    });
    return [for (final e in indexed) e.$2];
  }

  /// `planningRowOrder.ts` `moveRow`: the same list when nothing moves or an index is out of range.
  static List<T> moveRow<T>(List<T> rows, int from, int to) {
    final last = rows.length - 1;
    if (from == to || from < 0 || to < 0 || from > last || to > last) return rows;
    final next = [...rows];
    final moved = next.removeAt(from);
    next.insert(to, moved);
    return next;
  }

  /// The search answer laid over the grid (`usePlanningListPage.ts:189-231`). A new plan takes
  /// the rows as they are; a saved plan refreshes the jobs it has (keeping truck, driver,
  /// remarks, sort and tick) and adds the new ones with no truck and no remarks.
  static SearchMerge mergeSearch({required bool savedPlan, required List<PlanLine> current, required List<PlanLine> found}) {
    if (!savedPlan) return SearchMerge(found, found.length, 0);
    var refreshed = 0;
    final updated = [
      for (final row in current)
        () {
          final match = found.where((r) => r.saleOrderMasterRefId == row.saleOrderMasterRefId).firstOrNull;
          if (match == null) return row;
          refreshed++;
          return row.copyWith(
            sPickupDate: match.sPickupDate,
            sDeliveryDate: match.sDeliveryDate,
            wareHouseEnterDate: match.wareHouseEnterDate,
            wareHouseExitDate: match.wareHouseExitDate,
            wareHouseAddress: match.wareHouseAddress,
            pickupAddress: match.pickupAddress,
            deliveryAddress: match.deliveryAddress,
            pickuptimelist: match.pickuptimelist,
            pickupQuantitylist: match.pickupQuantitylist,
            deliveryQuantitylist: match.deliveryQuantitylist,
            delivertimelist: match.delivertimelist,
            status: match.status,
            picName: match.picName,
            loadingETA: match.loadingETA,
            offloadingETA: match.offloadingETA,
            pickupsList: match.pickupsList ?? row.pickupsList,
            deliveriesList: match.deliveriesList ?? row.deliveriesList,
          );
        }(),
    ];
    final existing = current.map((r) => r.saleOrderMasterRefId).toSet();
    final added = [
      for (final r in found.where((r) => !existing.contains(r.saleOrderMasterRefId))) r.copyWith(truckName: '', truckRefid: 0, remarks: ''),
    ];
    return SearchMerge([...updated, ...added], added.length, refreshed);
  }

  /// The newest RTI of each job onto the rows (`usePlanningListPage.ts:760-792`); the same list
  /// when nothing changed.
  static List<PlanLine> applyRtiStatuses(List<PlanLine> rows, List<Map<String, dynamic>> statuses) {
    final byJob = {for (final s in statuses) Js.intOr0(s['saleOrderMasterRefId']): s};
    var changed = false;
    final next = [
      for (final row in rows)
        () {
          final s = byJob[row.saleOrderMasterRefId];
          final id = s == null ? 0 : Js.intOr0(s['rtiMasterRefId']);
          final no = s == null ? '' : Js.text(s['rtiNo']);
          if (row.rtiMasterRefId == id && row.rtiNo == no) return row;
          changed = true;
          return row.copyWith(rtiMasterRefId: id, rtiNo: no);
        }(),
    ];
    return changed ? next : rows;
  }

  /// The sorted, distinct job ids of the rows: the RTI badges are fetched again when it changes.
  static String jobKey(List<PlanLine> rows) {
    final ids = rows.map((r) => r.saleOrderMasterRefId).where((id) => id > 0).toSet().toList()..sort();
    return ids.join(',');
  }

  /// Clone (`usePlanningOperations.ts:251-285`): the refusal, or null when [row] may be cloned.
  static String? cloneRefusal(PlanLine? row) {
    if (row == null) return 'Please select a row to duplicate';
    if (row.saleOrderMasterRefId == 0) return 'Cannot duplicate: Row does not have a valid sale order';
    return null;
  }

  /// The clone itself: the same row with a new identity and the truck cleared.
  static PlanLine cloneOf(PlanLine row) => row.copyWith(uid: PlanLine.nextUid(), id: 0, truckName: '', truckRefid: 0);

  /// Excel (`usePlanningListPage.ts:935-989`): the CSV text, 18 columns, every value quoted.
  static String csv(List<PlanLine> rows) {
    String q(Object? v) => '"${(v ?? '').toString().replaceAll('"', '""')}"';
    const headers = [
      'S.NO',
      'SORT',
      'REMARKS',
      'TRUCK',
      'DRIVER',
      'P.DATE',
      'D.DATE',
      'ORIGIN',
      'DEST',
      'PKG / WT',
      'CUSTOMER',
      'VESSEL',
      'JOB NO',
      'PIC',
      'L ETA',
      'O ETA',
      'STATUS',
      'RTI'
    ];
    final lines = [headers.join(',')];
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      lines.add([
        i + 1,
        Js.truthy(r.sortByD) ? r.sortByD : 0,
        r.remarks,
        r.truckName,
        r.driverName,
        Fmt.planningDateTime(r.sPickupDate),
        Fmt.planningDateTime(r.sDeliveryDate),
        r.origin,
        r.destination,
        r.packageType,
        r.customerName,
        r.vesselName,
        r.jobNo,
        r.picName,
        Fmt.planningDateTime(r.loadingETA),
        Fmt.planningDateTime(r.offloadingETA),
        r.status,
        r.rtiNo,
      ].map(q).join(','));
    }
    return lines.join('\n');
  }

  /// `Planning_Export_{yyyy-mm-dd}.csv` (the web uses the UTC day).
  static String csvFileName(DateTime now) => 'Planning_Export_${PlanHeader.ymd(now.toUtc())}.csv';

  /// The addresses of a job's stops, joined with `{@}` (`AddressHoverCell`).
  static List<String> stops(String joined) => joined.split('{@}').map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
}

class SearchMerge {
  const SearchMerge(this.rows, this.added, this.refreshed);

  final List<PlanLine> rows;
  final int added;
  final int refreshed;
}
