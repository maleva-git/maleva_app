import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import 'ceo_analytics_api.dart';

/// The three Super Admin reports the web CEO page shows after the CEO tabs (Forwarding, Performance, Driver
/// Salary), from the same shared Java endpoints the web calls (change `ceo-analytics-dashboard`, app tabs
/// 2026-10-19). The answers are read as Java sends them; nothing is reshaped on the server for the app.
class CeoSuperReportsApi {
  CeoSuperReportsApi(this._dio);

  final Dio _dio;

  /// `GET /api/dashboard/forwarding/{comId}?fromDate&toDate` (`{success, data}`): K1/K2/K3/K8 in the days.
  Future<CeoForwarding> forwarding(int comid, {required String fromDate, required String toDate}) async {
    final data = await _dashboard(() => _dio.get<dynamic>('/api/dashboard/forwarding/$comid',
        queryParameters: {'fromDate': fromDate, 'toDate': toDate}));
    return CeoForwarding.fromJava(data);
  }

  /// `GET /api/dashboard/employee-sales-current-month/{comId}?baseDate` (`{success, data}`): invoice sales per
  /// employee in [baseDate]'s month, most first.
  Future<CeoLeaderboard> leaderboard(int comid, {required String baseDate}) async {
    final data = await _dashboard(() => _dio.get<dynamic>('/api/dashboard/employee-sales-current-month/$comid',
        queryParameters: {'baseDate': baseDate}));
    return CeoLeaderboard.fromJava(data);
  }

  /// `POST /api/rti/driver-report` (`{IsSuccess, StatusCode, Message, Data1}`): every RTI of every driver in the
  /// days. The server answers 404 "No records found" when there are none; that is an empty list here.
  Future<List<CeoRtiRow>> driverSalary(int comid, {required String fromDate, required String toDate}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>('/api/rti/driver-report',
          data: {'comid': comid, 'driverId': 0, 'truckId': 0, 'fromDate': fromDate, 'toDate': toDate});
    } on DioException catch (e) {
      final failure = JavaResponse.fromDio(e);
      if (failure.statusCode == 404) return const [];
      throw failure;
    }
    try {
      return [for (final m in JsonRead.listOfMaps(CeoAnalyticsApi.payload(response.data))) CeoRtiRow.fromJava(m)];
    } on ApiFailure catch (f) {
      if (f.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<dynamic> _dashboard(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> response;
    try {
      response = await call();
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    if (body['success'] != true) {
      throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Request failed',
          statusCode: JsonRead.intOrNull(body['statusCode']));
    }
    return body['data'];
  }
}

/// One forwarding stage (K1, K2, K3, K8) in the days. The Java names: `kNCount` all, `kNWithRelease` with an
/// exit reference (released), `kNRelease` without one (not released yet).
class CeoForwardingStage {
  const CeoForwardingStage({required this.name, this.count = 0, this.released = 0, this.notReleased = 0});

  final String name;
  final int count;
  final int released;
  final int notReleased;

  double get releasedShare => count <= 0 ? 0 : released / count;
}

class CeoForwarding {
  const CeoForwarding({this.stages = const []});

  factory CeoForwarding.fromJava(dynamic json) {
    final m = JsonRead.map(json);
    int n(String k) => JsonRead.integer(m[k]);
    return CeoForwarding(stages: [
      for (final k in const ['k1', 'k2', 'k3', 'k8'])
        CeoForwardingStage(
          name: k.toUpperCase(),
          count: n('${k}Count'),
          released: n('${k}WithRelease'),
          notReleased: n('${k}Release'),
        ),
    ]);
  }

  final List<CeoForwardingStage> stages;

  int get count => stages.fold(0, (a, s) => a + s.count);
  int get released => stages.fold(0, (a, s) => a + s.released);
  int get notReleased => stages.fold(0, (a, s) => a + s.notReleased);
}

class CeoLeader {
  const CeoLeader({this.name = '', this.sales = 0, this.amount = 0});

  final String name;
  final int sales;
  final double amount;
}

/// `{totalEmployees, totalSales, employees: [{employeeName, currentMonthSales, salesCount}], period}`.
class CeoLeaderboard {
  const CeoLeaderboard({this.period = '', this.total = 0, this.employees = const []});

  factory CeoLeaderboard.fromJava(dynamic json) {
    final m = JsonRead.map(json);
    return CeoLeaderboard(
      period: JsonRead.string(m['period']).trim(),
      total: JsonRead.number(m['totalSales']),
      employees: [
        for (final e in JsonRead.listOfMaps(m['employees']))
          CeoLeader(
            name: JsonRead.string(e['employeeName']).trim(),
            sales: JsonRead.integer(e['salesCount']),
            amount: JsonRead.number(e['currentMonthSales']),
          ),
      ],
    );
  }

  final String period;
  final double total;
  final List<CeoLeader> employees;
}

/// One RTI of the driver report (camelCase Java fields).
class CeoRtiRow {
  const CeoRtiRow({
    this.driverName = '',
    this.salary = 0,
    this.pickup = 0,
    this.drop = 0,
    this.sleeping = 0,
    this.emptyPickup = 0,
    this.emptyDelivery = 0,
    this.manpower = 0,
    this.amount = 0,
  });

  factory CeoRtiRow.fromJava(Map<String, dynamic> m) {
    double n(String k) => JsonRead.number(m[k]);
    return CeoRtiRow(
      driverName: JsonRead.string(m['driverName']).trim(),
      salary: n('salary'),
      pickup: n('pickupAmount'),
      drop: n('dropAmount'),
      sleeping: n('sleepingAmount'),
      emptyPickup: n('exitAmount'),
      emptyDelivery: n('emptyDeliveryAmount'),
      manpower: n('manpwAmount'),
      amount: n('amount'),
    );
  }

  final String driverName;
  final double salary;
  final double pickup;
  final double drop;
  final double sleeping;
  final double emptyPickup;
  final double emptyDelivery;
  final double manpower;
  final double amount;
}

/// One driver's RTIs added up (the web Driver Salary table, grouped the same way).
class CeoDriverSalary {
  CeoDriverSalary(this.driverName);

  final String driverName;
  int rtis = 0;
  int zeroRtis = 0;
  double salary = 0;
  double pickup = 0;
  double drop = 0;
  double sleeping = 0;
  double emptyPickup = 0;
  double emptyDelivery = 0;
  double manpower = 0;
  double amount = 0;

  void add(CeoRtiRow r) {
    rtis++;
    if (r.amount == 0) zeroRtis++;
    salary += r.salary;
    pickup += r.pickup;
    drop += r.drop;
    sleeping += r.sleeping;
    emptyPickup += r.emptyPickup;
    emptyDelivery += r.emptyDelivery;
    manpower += r.manpower;
    amount += r.amount;
  }

  /// Per driver, most RTIs first (as the web).
  static List<CeoDriverSalary> group(List<CeoRtiRow> rows) {
    final by = <String, CeoDriverSalary>{};
    for (final r in rows) {
      final name = r.driverName.isEmpty ? 'NO DRIVER' : r.driverName;
      (by[name] ??= CeoDriverSalary(name)).add(r);
    }
    return by.values.toList()..sort((a, b) => b.rtis != a.rtis ? b.rtis.compareTo(a.rtis) : b.amount.compareTo(a.amount));
  }
}
