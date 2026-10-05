import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// The plan's form (the web's `formData`, `planningConstants.ts` `createDefaultForm`): dates are
/// `yyyy-MM-dd` text or '' like the web's date inputs; [employee] is the id as text or ''.
class PlanHeader {
  const PlanHeader({
    this.planningNo = '',
    this.planningDate = '',
    this.pickupFromDate = '',
    this.pickupToDate = '',
    this.port = '',
    this.employee = '',
    this.remarks = '',
    this.searchText = '',
  });

  /// A new plan: every date today.
  factory PlanHeader.fresh(DateTime today) {
    final d = ymd(today);
    return PlanHeader(planningDate: d, pickupFromDate: d, pickupToDate: d);
  }

  final String planningNo;
  final String planningDate;
  final String pickupFromDate;
  final String pickupToDate;
  final String port;
  final String employee;
  final String remarks;
  final String searchText;

  PlanHeader copyWith({
    String? planningNo,
    String? planningDate,
    String? pickupFromDate,
    String? pickupToDate,
    String? port,
    String? employee,
    String? remarks,
    String? searchText,
  }) =>
      PlanHeader(
        planningNo: planningNo ?? this.planningNo,
        planningDate: planningDate ?? this.planningDate,
        pickupFromDate: pickupFromDate ?? this.pickupFromDate,
        pickupToDate: pickupToDate ?? this.pickupToDate,
        port: port ?? this.port,
        employee: employee ?? this.employee,
        remarks: remarks ?? this.remarks,
        searchText: searchText ?? this.searchText,
      );

  static String ymd(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// A saved plan as `GET /api/planing/edit` answers it, read like `mapPlanningEditResponse`
/// (`planningEditMapper.ts:145-183`).
class LoadedPlan {
  const LoadedPlan({required this.editId, required this.header, required this.lines});

  final int editId;

  /// Only the fields the edit answer carries; the caller lays them over its form.
  final Map<String, String> header;
  final List<PlanLine> lines;

  /// Null when the answer holds no plan ("Planning data not found").
  static LoadedPlan? fromJava(dynamic response) {
    final master = _extract(response);
    if (master == null) return null;
    dynamic details = Js.or(master, ['SaleDetails', 'saleDetails', 'PlanningDetails', 'planningDetails', 'items', 'Details']);
    details ??= const [];
    String s(List<String> keys) => Js.text(Js.nn(master, keys));
    final port = Js.nn(master, ['portRefId']) ?? master['PortRefid'];
    final employee = Js.nn(master, ['employeeRefId']) ?? master['EmployeeRefid'];
    final rows = details is List ? details : const [];
    return LoadedPlan(
      editId: Js.intOr0(Js.nn(master, ['id', 'Id']) ?? 0),
      header: {
        'planningNo': s([
          'CNumber',
          'cNumber',
          'PLANINGNo',
          'cNumberDisplay',
          'CNumberDisplay',
          'planningNoDisplay',
          'PlanningNoDisplay',
          'planningNo',
          'PLANINGNoDisplay'
        ]),
        'planningDate': dateForInput(Js.nn(master, ['saleDate', 'SaleDate', 'planningDate', 'SSaleDate', 'PLANINGDate'])),
        'pickupFromDate': dateForInput(Js.nn(master, ['fDate', 'FDate', 'pickupFromDate', 'SFDate', 'FromDate'])),
        'pickupToDate': dateForInput(Js.nn(master, ['tDate', 'TDate', 'pickupToDate', 'STDate', 'ToDate'])),
        'port': Js.truthy(port) ? Js.text(port) : '',
        'employee': Js.truthy(employee) ? Js.text(employee) : '',
        'remarks': s(['remarks', 'Remarks']),
        'searchText': s(['search', 'Search']),
      },
      lines: [
        for (var i = 0; i < rows.length; i++)
          if (rows[i] is Map) PlanLine.fromEdit(Map<String, dynamic>.from(rows[i] as Map), i),
      ],
    );
  }

  /// `extractPlanningRecord`, after the web's `normalizeResponse` took off an `ApiResponse` wrapper.
  static Map<String, dynamic>? _extract(dynamic response) {
    dynamic r = response;
    if (r is Map && (r['Data1'] != null || r['data1'] != null)) r = r['Data1'] ?? r['data1'];
    if (r == null) return null;
    Map<String, dynamic>? first(dynamic list) =>
        list is List && list.isNotEmpty && list.first is Map ? Map<String, dynamic>.from(list.first as Map) : null;
    if (r is List) return first(r);
    if (r is! Map) return null;
    final m = Map<String, dynamic>.from(r);
    if (m['salemaster'] is List) return first(m['salemaster']);
    final data = m['data'];
    if (data is Map && data['salemaster'] is List) return first(data['salemaster']);
    if (m['Data'] is List) return first(m['Data']);
    if (data is List) return first(data);
    if (m['result'] is List) return first(m['result']);
    if (data is Map) return Map<String, dynamic>.from(data);
    return m;
  }

  /// `formatDateForInput`: `dd/MM/yyyy` → `yyyy-MM-dd`; another date → its local day; else ''.
  static String dateForInput(dynamic value) {
    if (!Js.truthy(value)) return '';
    final text = Js.text(value).trim();
    final dmy = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (dmy != null) return '${dmy[3]}-${dmy[2]}-${dmy[1]}';
    final ymdSlash = RegExp(r'^(\d{4})/(\d{2})/(\d{2})').firstMatch(text);
    if (ymdSlash != null) return '${ymdSlash[1]}-${ymdSlash[2]}-${ymdSlash[3]}';
    final d = DateTime.tryParse(text);
    if (d == null) return '';
    return PlanHeader.ymd(d.isUtc ? d.toLocal() : d);
  }
}
