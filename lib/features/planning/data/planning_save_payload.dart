import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// The Save body, as `utils/planningSavePayload.ts` builds it (`POST /api/planing/save`, the body
/// is a list holding this one request). Rows without a sale order are left out; the from / to
/// dates fall back to the plan date.
abstract final class PlanningSavePayload {
  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// `parseCustomDate`: `yyyy-MM-dd[ HH:mm[:ss]]` (with `T`, `/` or `,`), `dd MMM yy[yy][ HH:mm]`,
  /// or another date the platform reads.
  static DateTime? parse(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final norm = text.replaceFirst('T', ' ').replaceFirst(RegExp(r'\.\d+$'), '');
    final ymd = RegExp(r'^(\d{4})[-/](\d{2})[-/](\d{2})(?:[ ,]+(\d{2}):(\d{2})(?::(\d{2}))?)?$').firstMatch(norm);
    if (ymd != null) {
      return DateTime(
          int.parse(ymd[1]!), int.parse(ymd[2]!), int.parse(ymd[3]!), int.parse(ymd[4] ?? '0'), int.parse(ymd[5] ?? '0'), int.parse(ymd[6] ?? '0'));
    }
    final disp = RegExp(r'^(\d{2})[ /-]([A-Za-z]{3})[ /-](\d{2,4})(?:[ ,]+(\d{2}):(\d{2}))?$').firstMatch(norm);
    if (disp != null) {
      final month = _months[disp[2]!.toLowerCase()];
      if (month != null) {
        final y = int.parse(disp[3]!);
        return DateTime(disp[3]!.length == 2 ? 2000 + y : y, month, int.parse(disp[1]!), int.parse(disp[4] ?? '0'), int.parse(disp[5] ?? '0'));
      }
    }
    final d = DateTime.tryParse(norm);
    return d == null ? null : (d.isUtc ? d.toLocal() : d);
  }

  /// `formatDate`: `yyyy/MM/dd`, or ''.
  static String date(String? value) {
    final d = parse(value);
    return d == null ? '' : '${d.year}/${_two(d.month)}/${_two(d.day)}';
  }

  /// `formatDateTime`: `yyyy/MM/dd HH:mm`, or null.
  static String? dateTime(String? value) {
    final d = parse(value);
    return d == null ? null : '${d.year}/${_two(d.month)}/${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
  }

  /// `extractPlanningNumber`: the digits of the plan number, or 0.
  static int planningNumber(String planningNo) {
    final digits = planningNo.trim().replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  /// `buildPlanningDetailPayload`; null for a row without a sale order.
  static Map<String, dynamic>? detail(PlanLine row) {
    final saleOrderMasterRefId = Js.positiveInt(row.saleOrderMasterRefId);
    if (saleOrderMasterRefId == 0) return null;
    final sortSource = [row.sortByD, row.originalSortByD].firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    final sortNumber = Js.number(sortSource);
    final driverRefId = Js.positiveInt(row.driverRefid);
    return {
      'saleOrderMasterRefId': saleOrderMasterRefId,
      'truckRefid': Js.positiveInt(row.truckRefid),
      'driverRefid': driverRefId,
      'DriverRefId': driverRefId,
      'remarks': row.remarks.trim(),
      'originD': Js.firstText([row.originD, row.origin]),
      'destinationD': Js.firstText([row.destinationD, row.destination]),
      'truckNameD': Js.firstText([row.truckName, row.truckNameD]),
      'driverNameD': Js.firstText([row.driverName, row.driverNameD]),
      'driverName': Js.firstText([row.driverName, row.driverNameD]),
      'sortBy': sortNumber.isNaN ? 0 : (sortNumber == sortNumber.truncateToDouble() ? sortNumber.toInt() : sortNumber),
      // `row.pickupDateD ?? row.pickupDate`: a row always has the D field (maybe ''), so it wins
      'pickupDateD': dateTime(row.pickupDateD),
      'deliveryDateD': dateTime(row.deliveryDateD),
      'pickuptimelist': row.pickuptimelist.trim(),
      'pickupQuantitylist': row.pickupQuantitylist.trim(),
      'deliveryQuantitylist': row.deliveryQuantitylist.trim(),
      'delivertimelist': row.delivertimelist.trim(),
    };
  }

  /// `buildPlanningSavePayload`: the one request (the API wraps it in a list).
  static Map<String, dynamic> build({
    required int companyId,
    required int editId,
    required PlanHeader header,
    required List<PlanLine> rows,
    required int userId,
    required int employeeId,
  }) {
    final planningNo = header.planningNo.trim();
    final planningDate = date(header.planningDate);
    final fromDate = date(header.pickupFromDate);
    final toDate = date(header.pickupToDate);
    final resolvedEmployee = Js.positiveInt(Js.truthy(header.employee) ? header.employee : employeeId);
    return {
      'id': Js.positiveInt(editId),
      'companyRefId': Js.positiveInt(companyId),
      'userRefId': Js.positiveInt(userId) == 0 ? null : Js.positiveInt(userId),
      'employeeRefId': resolvedEmployee == 0 ? null : resolvedEmployee,
      'fDate': fromDate.isNotEmpty ? fromDate : planningDate,
      'tDate': toDate.isNotEmpty ? toDate : planningDate,
      'saleDate': planningDate,
      'cNumberDisplay': planningNo,
      'cNumber': planningNumber(planningNo),
      'remarks': header.remarks.trim(),
      'search': header.searchText.trim(),
      'saleDetails': [for (final r in rows) detail(r)].whereType<Map<String, dynamic>>().toList(),
    };
  }

  /// `validatePlanningSavePayload`: every refusal in order; the first is shown
  /// (fallback "Invalid planning payload").
  static List<String> validate(Map<String, dynamic> request) {
    final errors = <String>[];
    if (!Js.truthy(request['companyRefId'])) errors.add('Company ID is required');
    if (!Js.truthy(request['saleDate'])) errors.add('Planning date is required');
    if (!Js.truthy(request['fDate'])) errors.add('From date is required');
    if (!Js.truthy(request['tDate'])) errors.add('To date is required');
    final details = request['saleDetails'];
    if (details is! List || details.isEmpty) errors.add('Please add at least one valid row in the table before saving');
    return errors;
  }

  /// The first refusal, or null when the plan may be sent.
  static String? refusal(Map<String, dynamic> request) {
    final errors = validate(request);
    if (errors.isEmpty) return null;
    return errors.first.isNotEmpty ? errors.first : 'Invalid planning payload';
  }
}
