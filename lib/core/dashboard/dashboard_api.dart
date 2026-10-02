import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The dashboard numbers, from the Java `/api/dashboard` endpoints the web
/// app uses (one API per feature, shared by React and the app - change
/// `dashboard-on-shared-java-api`).
///
/// Every method answers the Java `data` as it is: the field names are the
/// Java ones and the screens read them directly. Those endpoints answer
/// `{success, statusCode, message, data}`; a refusal is
/// `{success: false, message}`, thrown as [ApiFailure].
class DashboardApi {
  DashboardApi(this._dio);

  final Dio _dio;

  /// Today / yesterday / week / month totals and the last 12 months:
  /// `{TodaySales, TodayAmount, ..., MonthAmount, monthlySales: [{SalesCount, SalesAmount, MonthName}]}`,
  /// months newest first. [type]: 0 invoices, 1 all sale orders, 2 those
  /// with an invoice, 3 those without.
  Future<Map<String, dynamic>> sales(int comid, int type) async =>
      JsonRead.map(await _get('/api/dashboard/sales/$comid', {'type': type}));

  /// `[{EmployeeName, SalesCount, Amount}]` of sale orders. [type] is
  /// `block * 15 + period` (block 0 all, 1 with invoice, 2 without; period
  /// 0 today, 1 yesterday, 2 week, 3 month).
  Future<List<Map<String, dynamic>>> employeeSales(int comid, int type) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/employee-sales/$comid', {'type': type}));

  /// `[{EmployeeName, SalesCount, Amount}]` for the invoice desk, same [type].
  Future<List<Map<String, dynamic>>> employeeInvoices(int comid, int type) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/employee-invoice/$comid', {'type': type}));

  /// Expense totals (today / yesterday / week / month, fixed periods) and the
  /// breakdown by expense name in the date range:
  /// `{TodaySales, TodayAmount, ..., expenses: [{ExpenseName, ExpCount, ExpAmount}]}`.
  Future<Map<String, dynamic>> expenses(int comid, String fromDate, String toDate) async => JsonRead.map(
      await _get('/api/dashboard/expense/$comid', {'fromDate': fromDate, 'toDate': toDate}));

  /// Forwarding counts: the period block (`todayCount`, `todayRelease`,
  /// `todayWithRelease`, ... `month*`, fixed periods) and the K1/K2/K3/K8
  /// block in the date range (`k1Count`, `k1Release`, `k1WithRelease`, ...).
  Future<Map<String, dynamic>> forwarding(int comid, String fromDate, String toDate) async => JsonRead.map(
      await _get('/api/dashboard/forwarding/$comid', {'fromDate': fromDate, 'toDate': toDate}));

  /// `[{Id, BillNoDisplay, DayCount, Remarks}]`: forwarding numbers not yet released.
  Future<List<Map<String, dynamic>>> unreleased(int comid) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/unreleased/$comid'));

  /// `[{Id, BillNoDisplay, DayCount, Remarks}]`: K8 numbers not yet released.
  Future<List<Map<String, dynamic>>> k8Unreleased(int comid) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/k8-unreleased/$comid'));

  /// `[{Id, AccountName}]`: the employees [employeeId] may look at (self and subordinates).
  Future<List<Map<String, dynamic>>> employeeRules(int comid, int employeeId) async => JsonRead.listOfMaps(
      await _get('/api/dashboard/employee-rules/$comid', {'employeeId': employeeId}));

  /// `[{Id, JobStatus, DayCount}]`: open sale orders by status.
  Future<List<Map<String, dynamic>>> salesOrderStatus(int comid, int employeeId) async => JsonRead.listOfMaps(
      await _get('/api/dashboard/sales-order-status/$comid', {'employeeId': employeeId}));

  /// The sale orders matching the filter (camelCase rows); the desks show
  /// only how many. [remarks]: 0 all, 1 with invoice, 2 without.
  Future<List<Map<String, dynamic>>> invoiceCheck(int comid,
      {required String fromDate, required String toDate, required int remarks, required int employeeId}) async {
    final body = await _send(() => _dio.post<dynamic>('/api/dashboard/check-invoice-count/$comid', data: {
          'comId': comid,
          'fromDate': fromDate,
          'toDate': toDate,
          'remarks': remarks,
          'statusId': 0,
          'employeeId': employeeId,
          'completeStatusNotShow': false,
          'invoice': false,
        }));
    return JsonRead.listOfMaps(body);
  }

  /// The four counts and the status list a sales desk shows for [employeeId]
  /// (with subordinates): sale orders without invoice since 2024-10-01 (the
  /// date the invoice number replaced the remarks rule), and this month's
  /// total, billed and unbilled.
  Future<SalesDeskNumbers> salesDesk(int comid, int employeeId, {DateTime? today}) async {
    final now = today ?? DateTime.now();
    final to = _ymd(now);
    final monthStart = _ymd(DateTime(now.year, now.month, 1));
    final results = await Future.wait<dynamic>([
      invoiceCheck(comid, fromDate: '2024-10-01', toDate: to, remarks: 2, employeeId: employeeId),
      invoiceCheck(comid, fromDate: monthStart, toDate: to, remarks: 0, employeeId: employeeId),
      invoiceCheck(comid, fromDate: monthStart, toDate: to, remarks: 1, employeeId: employeeId),
      invoiceCheck(comid, fromDate: monthStart, toDate: to, remarks: 2, employeeId: employeeId),
      salesOrderStatus(comid, employeeId),
    ]);
    return SalesDeskNumbers(
      withoutInvoice: (results[0] as List).length,
      total: (results[1] as List).length,
      billed: (results[2] as List).length,
      unbilled: (results[3] as List).length,
      statuses: results[4] as List<Map<String, dynamic>>,
    );
  }

  /// Air freight jobs whose flight time is in the range (camelCase rows:
  /// `id`, `jobNo`, `awbNo`, `port`, `loadingVesselName`, `jobStatus`,
  /// `setb`, `soetb` as `yyyy-MM-dd HH:mm:ss` or '').
  Future<List<Map<String, dynamic>>> airFreight(int comid,
      {required String fromDate, required String toDate, String search = '', int statusId = 0}) async {
    final body = await _send(() => _dio.post<dynamic>('/api/dashboard/air-freight/$comid', data: {
          'comId': comid,
          'employeeId': 0,
          'etaType': 5,
          'fromDate': fromDate,
          'toDate': toDate,
          'search': search,
          'statusId': statusId,
        }));
    return JsonRead.listOfMaps(body);
  }

  /// `[{Description, PStatus (bill count), Amount}]`: maintenance bills by kind
  /// (BREAKDOWN, REPAIR, SERVICE, SPARE PARTS) in the range.
  Future<List<Map<String, dynamic>>> maintenanceStatus(int comid, String fromDate, String toDate) async =>
      JsonRead.listOfMaps(await _get(
          '/api/dashboard/maintenance-status/$comid', {'fromDate': fromDate, 'toDate': toDate}));

  /// `[{Description, Amount}]`: LEVI, AUTOPASS, TOLL and FUEL totals in the range.
  Future<List<Map<String, dynamic>>> runningExpenses(int comid, String fromDate, String toDate) async =>
      JsonRead.listOfMaps(await _get(
          '/api/dashboard/running-expenses/$comid', {'fromDate': fromDate, 'toDate': toDate}));

  /// `[{Id, SDueDate, SupplierName, Amount, PStatus}]`: unpaid maintenance bills,
  /// PStatus 2 due or past, 1 due within five days, 0 later; most urgent first.
  Future<List<Map<String, dynamic>>> supplierExpenses(int comid) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/supplier-expense/$comid'));

  /// `[{CustomerRefId, CustomerName, Revenue, Volume}]`, top 20. [filterType]:
  /// SGD, RM, USD, TRANSPORT or VOLUME.
  Future<List<Map<String, dynamic>>> topCustomers(int comid,
          {required String fromDate, required String toDate, required String filterType}) async =>
      JsonRead.listOfMaps(await _get('/api/dashboard/top-customers/$comid',
          {'fromDate': fromDate, 'toDate': toDate, 'filterType': filterType}));

  /// The vessel planning board (camelCase rows: `id`, `jobNo`, `port`,
  /// `loadingVesselName`, `offVesselName`, `customerName`, `seta`, ...,
  /// `boardingOfficerRefId` ... `oBoardingAmount2`). [etaType] 1 OETA, 2 ETA,
  /// other each vessel by its own date.
  Future<List<Map<String, dynamic>>> vesselPlanning(int comid,
      {required String fromDate, required String toDate, String search = '', int employeeId = 0, int etaType = 0}) async {
    final body = await _send(() => _dio.post<dynamic>('/api/dashboard/vessel-planning/$comid', data: {
          'comId': comid,
          'employeeId': employeeId,
          'etaType': etaType,
          'fromDate': fromDate,
          'toDate': toDate,
          'search': search,
          'statusId': 0,
        }));
    return JsonRead.listOfMaps(body);
  }

  /// Jobs picked up in the range (rows `Id`, `CustomerName`, `JobNo`, ...),
  /// one per job, those not picked up on [fromDate] first.
  Future<List<Map<String, dynamic>>> pickups(int comid,
      {required String fromDate, required String toDate, String search = '', int employeeId = 0}) async {
    final body = await _send(() => _dio.post<dynamic>('/api/dashboard/planing-search', data: {
          'comid': comid,
          'search': search,
          'employeeid': employeeId == 0 ? '' : employeeId.toString(),
          'fromdate': fromDate,
          'todate': toDate,
        }));
    return JsonRead.listOfMaps(body);
  }

  /// The planning screen's job list for the range (`/api/planing/search`, a
  /// bare list; rows `Id`, `CustomerName`, `JobNo`, ...), by pickup date.
  Future<List<Map<String, dynamic>>> planningJobs(int comid,
      {required String fromDate, required String toDate, String search = '', int employeeId = 0}) async {
    try {
      final response = await _dio.post<dynamic>('/api/planing/search', data: {
        'comid': comid,
        'search': search,
        'employeeid': employeeId == 0 ? '' : employeeId.toString(),
        'fromdate': fromDate,
        'todate': toDate,
      });
      return JsonRead.listOfMaps(response.data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The transport list of a day [dayOffset] days from today: today's pickups
  /// (`/planing-search`) or, for a later day, the planning list
  /// (`/api/planing/search`), as .NET's PLANINGSearchDB / PLANINGSearch.
  Future<List<Map<String, dynamic>>> transportList(int comid, int dayOffset, {DateTime? today}) {
    final day = _ymd((today ?? DateTime.now()).add(Duration(days: dayOffset)));
    return dayOffset == 0
        ? pickups(comid, fromDate: day, toDate: day)
        : planningJobs(comid, fromDate: day, toDate: day);
  }

  /// Sale orders still waiting for an invoice (`/api/sale-orders/check-invoice`
  /// with `invoice: true`: from 2024-10-01, status 6 or 15). camelCase rows.
  Future<List<Map<String, dynamic>>> waitingInvoices(int comid) async {
    try {
      final response = await _dio.post<dynamic>('/api/sale-orders/check-invoice', data: {
        'comid': comid,
        'invoice': true,
        'employeeid': 0,
        'dashboardStatus': 0,
        'remarks': 2,
        'completestatusnotshow': false,
      });
      return JsonRead.listOfMaps(JavaResponse.data(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  // ---------------------------------------------------------------- helpers

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  /// The `data` of a successful answer.
  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> response;
    try {
      response = await call();
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map) {
      throw const ApiFailure('Unexpected response from server');
    }
    if (body['success'] != true) {
      throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Request failed',
          statusCode: JsonRead.intOrNull(body['statusCode']));
    }
    return body['data'];
  }
}

/// What a sales desk shows: four counts and the open orders by status.
class SalesDeskNumbers {
  const SalesDeskNumbers({
    required this.withoutInvoice,
    required this.total,
    required this.billed,
    required this.unbilled,
    required this.statuses,
  });

  final int withoutInvoice;
  final int total;
  final int billed;
  final int unbilled;

  /// `[{Id, JobStatus, DayCount}]`.
  final List<Map<String, dynamic>> statuses;
}
