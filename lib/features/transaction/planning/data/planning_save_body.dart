import 'package:intl/intl.dart';

/// The Java `PlanningRequest` the Planning page saves (`POST /api/planing/save`), built as the
/// web's `buildPlanningSavePayload`: dates `yyyy/MM/dd`, row dates `yyyy/MM/dd HH:mm`, the plan
/// number and its digits, one row per planned job (a line without a job is left out).
///
/// [lines] are the page's lines (`saleOrderId`, `truck`, `driver`, `pDate`, `dDate`, `origin`,
/// `destination`, `remarks`, `SortByD`); [truckId] and [driverId] find the picked names' ids.
Map<String, dynamic> planningSaveBody({
  required int id,
  required int companyId,
  required String planNo,
  required String planDate,
  required String fromDate,
  required String toDate,
  required String remarks,
  required List<Map<String, dynamic>> lines,
  required int Function(String name) truckId,
  required int Function(String name) driverId,
  int employeeId = 0,
  int userId = 0,
  String search = '',
}) {
  final day = planDateOf(planDate) ?? DateTime.now();
  return {
    'id': id,
    'companyRefId': companyId,
    'userRefId': userId > 0 ? userId : null,
    'employeeRefId': employeeId > 0 ? employeeId : null,
    'fDate': _slashDate(planDateOf(fromDate) ?? day),
    'tDate': _slashDate(planDateOf(toDate) ?? day),
    'saleDate': _slashDate(day),
    'cNumberDisplay': planNo.trim(),
    'cNumber': int.tryParse(planNo.replaceAll(RegExp(r'\D'), '')) ?? 0,
    'remarks': remarks.trim(),
    'search': search,
    'saleDetails': [
      for (final line in lines)
        if (_int(line['saleOrderId']) > 0) _detail(line, truckId, driverId),
    ],
  };
}

Map<String, dynamic> _detail(Map<String, dynamic> line, int Function(String) truckId, int Function(String) driverId) {
  final truck = '${line['truck'] ?? ''}'.trim();
  final driver = '${line['driver'] ?? ''}'.trim();
  final driverRef = driver.isEmpty ? 0 : driverId(driver);
  final pickup = planDateOf('${line['pDate'] ?? ''}');
  final delivery = planDateOf('${line['dDate'] ?? ''}');
  return {
    'saleOrderMasterRefId': _int(line['saleOrderId']),
    'truckRefid': truck.isEmpty ? 0 : truckId(truck),
    // the web sends both spellings; the server reads DriverRefId
    'driverRefid': driverRef,
    'DriverRefId': driverRef,
    'remarks': '${line['remarks'] ?? ''}'.trim(),
    'originD': '${line['origin'] ?? ''}'.trim(),
    'destinationD': '${line['destination'] ?? ''}'.trim(),
    'truckNameD': truck,
    'driverNameD': driver,
    'driverName': driver,
    'sortBy': _int(line['SortByD']),
    'pickupDateD': pickup == null ? null : DateFormat('yyyy/MM/dd HH:mm').format(pickup),
    'deliveryDateD': delivery == null ? null : DateFormat('yyyy/MM/dd HH:mm').format(delivery),
  };
}

/// A date as the page holds it (`dd/MM/yyyy`, `dd/MM/yyyy HH:mm`) or as Java answers it
/// (`yyyy-MM-dd HH:mm[:ss]`, ISO); null when blank or not a date.
DateTime? planDateOf(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  for (final pattern in ['dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy HH:mm', 'dd/MM/yyyy']) {
    try {
      return DateFormat(pattern).parseStrict(text);
    } catch (_) {}
  }
  return DateTime.tryParse(text.replaceAll('/', '-'));
}

String _slashDate(DateTime d) => DateFormat('yyyy/MM/dd').format(d);

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
