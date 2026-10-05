import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

/// The grid and route-activity edits of the RTI page (`R/hooks/useRTIState.ts`,
/// `R/hooks/useRTIOperations.ts:295-339`), as pure functions.
abstract final class RtiGridRules {
  /// `fillItemsByJobNo`'s skip: the row already holds this job, looked up.
  static bool alreadyLoaded(List<RtiJobRow> grid, int rowIndex, String jobNo) {
    if (rowIndex < 0 || rowIndex >= grid.length) return false;
    final row = grid[rowIndex];
    return row.jobNo == jobNo && row.customerName.isNotEmpty;
  }

  /// `fillItemsByJobNo`'s replace: blank rows and other rows of this job go; the row looked
  /// up takes the first match; further matches go right below it.
  static List<RtiJobRow> applyLookup(List<RtiJobRow> grid, int rowIndex, String jobNo, List<RtiJobRow> matches) {
    final current = rowIndex >= 0 && rowIndex < grid.length ? grid[rowIndex] : null;
    final clean = <RtiJobRow>[];
    var newIndex = -1;
    for (var i = 0; i < grid.length; i++) {
      final row = grid[i];
      if (i == rowIndex) {
        newIndex = clean.length;
        clean.add(row);
        continue;
      }
      if (row.jobNo.isEmpty && row.customerName.isEmpty) continue;
      if (row.jobNo == jobNo) continue;
      clean.add(row);
    }
    final safe = newIndex >= 0 ? newIndex : rowIndex.clamp(0, clean.length);
    final first = matches.first.copyWith(editMode: 1);
    if (current == null || safe >= clean.length) {
      clean.add(first);
    } else {
      clean[safe] = first;
    }
    final at = current == null || safe >= clean.length ? clean.length : safe + 1;
    clean.insertAll(at.clamp(0, clean.length), matches.skip(1));
    return clean.isEmpty ? [const RtiJobRow()] : clean;
  }

  /// `deleteGridRow`: the last row leaves one blank row.
  static List<RtiJobRow> deleteRow(List<RtiJobRow> grid, int index) {
    final next = [for (var i = 0; i < grid.length; i++) if (i != index) grid[i]];
    return next.isEmpty ? [const RtiJobRow()] : next;
  }

  /// `replaceGridData` / `loadRTI`: never an empty grid.
  static List<RtiJobRow> nonEmpty(List<RtiJobRow> grid) => grid.isEmpty ? [const RtiJobRow()] : grid;

  /// `pasteGridCells`: a multi-cell paste fills the editable columns from [column] on,
  /// adding rows as needed; Salary and PWD become numbers.
  static List<RtiJobRow> paste(List<RtiJobRow> grid, int rowIndex, String column, String text) {
    final start = RtiJobColumns.editable.indexOf(column);
    final matrix = RtiJobColumns.parseClipboard(text);
    if (start < 0 || matrix.isEmpty) return grid;
    final next = [...grid];
    for (var r = 0; r < matrix.length; r++) {
      final target = rowIndex + r;
      while (next.length <= target) {
        next.add(const RtiJobRow());
      }
      var row = next[target].copyWith(editMode: 1);
      for (var c = 0; c < matrix[r].length; c++) {
        final col = start + c;
        if (col >= RtiJobColumns.editable.length) break;
        final name = RtiJobColumns.editable[col];
        row = row.withCell(name, RtiJobColumns.coerce(name, matrix[r][c]));
      }
      next[target] = row;
    }
    return next;
  }

  /// `addRouteActivity`: the next sequence number (`last + 1`, so the first stop is 1, as
  /// React's code does), the RTI's destination as the full route, row 1's driver number.
  static List<RtiStop> addStop(List<RtiStop> stops, String destination) {
    final last = stops.isEmpty ? 0 : stops.last.sequenceNo;
    final first = stops.isEmpty ? '' : stops.first.driverNumber;
    return [...stops, RtiStop(sequenceNo: last + 1, fullRoute: destination, driverNumber: first)];
  }

  /// `updateRouteActivity`: editing row 1's driver number copies it to every other row.
  static List<RtiStop> editStop(List<RtiStop> stops, int index, RtiStop Function(RtiStop) change) {
    if (index < 0 || index >= stops.length) return stops;
    final next = [...stops];
    final before = next[index];
    next[index] = change(before);
    if (index == 0 && next[0].driverNumber != before.driverNumber) {
      for (var i = 1; i < next.length; i++) {
        next[i] = next[i].copyWith(driverNumber: next[0].driverNumber);
      }
    }
    return next;
  }

  /// `handleEmployeeChange`: an employee sets `employeeRefId`, clears `agentName` and copies
  /// the mobile number; a typed name sets `agentName`; nothing clears all three.
  static RtiStop pickAgent(RtiStop s, {RtiEmployee? employee, String? typed}) {
    if (employee != null && employee.id != 0) {
      return s.copyWith(employeeRefId: employee.id, agentName: '', agentMobileNo: employee.mobileNo ?? '');
    }
    if (typed != null && typed.isNotEmpty) {
      return s.copyWith(employeeRefId: null, agentName: typed, agentMobileNo: '');
    }
    return s.copyWith(employeeRefId: null, agentName: '', agentMobileNo: '');
  }

  /// `updateField('destination')`: every stop's full route becomes the destination.
  static List<RtiStop> withDestination(List<RtiStop> stops, String destination) =>
      [for (final s in stops) s.copyWith(fullRoute: destination)];
}
