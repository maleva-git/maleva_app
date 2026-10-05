import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A fake Java backend for the preview entry point (`tool/preview/preview_main.dart`) and the
/// preview smoke test: it answers the Planning, RTI, Levi and Employee Assignments calls with
/// canned JSON in the shapes the Java endpoints send (`ApiResponse {IsSuccess, StatusCode,
/// Message, Data1}` where the controller wraps, the bare DTO / list where it does not).
///
/// Requests are routed by method + path (the query is ignored unless noted). Every name, company,
/// truck and phone number here is made up. Writes answer success and are kept in memory, so a
/// saved RTI or Levi entry reads back.
class PreviewAdapter implements HttpClientAdapter {
  PreviewAdapter({this.delay = const Duration(milliseconds: 300), DateTime? today}) : _data = _PreviewData(today ?? DateTime.now());

  /// How long each answer waits, so loading states show.
  final Duration delay;

  final _PreviewData _data;

  /// `METHOD path` of each request that had no fixture (the tests assert it stays empty).
  final List<String> missing = [];

  /// `METHOD path` of every request, in order.
  final List<String> calls = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final method = options.method.toUpperCase();
    final path = options.uri.path;
    calls.add('$method $path');
    _Reply? reply;
    try {
      reply = _data.route(method, path, options);
    } catch (e, st) {
      debugPrint('preview: fixture for $method $path failed: $e\n$st');
      reply = _Reply(500, {'message': 'preview: fixture failed: $e'});
    }
    if (reply == null) {
      final message = 'preview: no fixture for $method $path';
      missing.add('$method $path');
      debugPrint(message);
      reply = _Reply(404, {'message': message});
    }
    final body = reply.body;
    final text = body == null ? '' : (body is String ? body : jsonEncode(body));
    return ResponseBody.fromString(text, reply.status, headers: {
      Headers.contentTypeHeader: [body is String ? 'text/plain; charset=utf-8' : Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _Reply {
  const _Reply(this.status, this.body);

  final int status;

  /// JSON-encodable, a plain-text String, or null (no body).
  final Object? body;
}

/// `ApiResponse.success(data, message)` as Jackson writes it.
Map<String, dynamic> _api(Object? data, [String message = 'Success']) =>
    {'IsSuccess': true, 'StatusCode': 200, 'Message': message, 'Data1': data, 'Data': null};

_Reply _ok(Object? body) => _Reply(200, body);

String _two(int n) => n.toString().padLeft(2, '0');
String _ymd(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
String _dmy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
String _iso(DateTime d) => '${_ymd(d)}T${_two(d.hour)}:${_two(d.minute)}:00';

/// `CONVERT(VARCHAR(16), date, 120)`: `yyyy-MM-dd HH:mm`.
String _sql120(DateTime d) => '${_ymd(d)} ${_two(d.hour)}:${_two(d.minute)}';

Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

// ------------------------------------------------------------------------------- sample data

class _Truck {
  const _Truck(this.id, this.name, this.type);

  final int id;
  final String name;
  final String type;
}

class _Driver {
  const _Driver(this.id, this.name, this.mobile);

  final int id;
  final String name;
  final String mobile;
}

class _Job {
  _Job({
    required this.n,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.pickup,
    required this.delivery,
    required this.status,
    this.truck,
    this.driver = '',
    this.size = '20FT',
    this.rtiId = 0,
  });

  final int n;
  final String customer;
  final String origin;
  final String destination;
  final DateTime pickup;
  final DateTime delivery;
  final String status;
  final _Truck? truck;
  final String driver;
  final String size;
  final int rtiId;

  int get soId => 20400 + n;
  String get jobNo => 'TR0026-04${_two(n)}';
  DateTime get jobDate => DateTime(2026, 10, 1 + n % 4);
  String get vessel => n.isEven ? 'MV SAMPLE STAR' : 'MV DEMO WAVE';
  String get pickupAddress => 'Gate ${n % 3 + 1}, $origin Container Yard';
  String get deliveryAddress => 'Lot ${10 + n}, Jalan Contoh ${n % 5 + 1}, $destination';
  String get quantity => '${n % 3 + 1}';
  String get weight => '${(n % 3 + 1) * 12000}';
  String get pic => n.isEven ? 'Siti A.' : 'Farid H.';
}

class _Rti {
  const _Rti(this.id, this.truck, this.driver, this.jobs, {this.remarks = '', this.outsideDriver = ''});

  final int id;
  final _Truck truck;
  final _Driver driver;
  final List<int> jobs;
  final String remarks;
  final String outsideDriver;

  String get no => 'RTI0000${12340 + id}';
}

class _PreviewData {
  _PreviewData(DateTime now) : today = DateTime(now.year, now.month, now.day) {
    _jobs = _buildJobs();
    _rtis = _buildRtis();
  }

  final DateTime today;

  static const companyId = 6;
  static const planId = 782;
  static const planNo = 'PL000000782';
  static final planDate = DateTime(2026, 10, 5);

  static const t1 = _Truck(101, 'WXY 1234', '20FT');
  static const t2 = _Truck(102, 'WXZ 5678', '40FT');
  static const t3 = _Truck(103, 'WYA 9012', '20FT');
  static const tOutside = _Truck(22, 'OUTSIDE DRIVER', '');
  static const tNone = _Truck(43, 'NONE', '');
  static const trucks = [t1, t2, t3, tOutside, tNone];

  static const ahmad = _Driver(201, 'Ahmad R.', '0100000201');
  static const kumar = _Driver(202, 'Kumar S.', '0100000202');
  static const rajesh = _Driver(203, 'Rajesh P.', '0100000203');
  static const lim = _Driver(204, 'Lim W.', '0100000204');
  static const outside = _Driver(36, 'OUTSIDE DRIVER', '0100000036');
  static const drivers = [ahmad, kumar, rajesh, lim, outside];

  static const employees = [
    (12, 'Siti A.', 'OPERATION'),
    (15, 'Farid H.', 'OPERATION'),
    (18, 'Mei Ling T.', 'ACCOUNTS'),
    (21, 'Arjun K.', 'BOARDING'),
  ];

  static const customers = ['Sample Trading Sdn Bhd', 'Demo Marine Supplies', 'Example Foods Sdn Bhd'];

  late final Map<int, _Job> _jobs;
  late final Map<int, _Rti> _rtis;

  /// RTIs saved during the session (POST / PUT bodies, with their lines and stops).
  final Map<int, Map<String, dynamic>> _savedRtis = {};
  int _nextRtiId = 11;

  /// Levi entries per RTI, so a save / delete reads back.
  final Map<int, List<Map<String, dynamic>>> _levi = {};
  int _nextLevi = 3241;

  Map<int, _Job> _buildJobs() {
    DateTime at(int day, int hour, int minute) => DateTime(2026, 10, day, hour, minute);
    const ports = ['WESTPORT', 'NORTHPORT', 'PTP', 'PKFZ'];
    const places = ['SHAH ALAM', 'NILAI', 'BANGI', 'KLANG', 'SELANGOR'];
    // n, status, truck, driver, rti
    final plan = <(int, String, _Truck?, String, int)>[
      (1, 'Assigned', t1, ahmad.name, 5),
      (2, 'In Transit', t1, ahmad.name, 5),
      (3, 'Delivered', t1, ahmad.name, 5),
      (4, 'Completed', t1, ahmad.name, 5),
      (5, 'Assigned', t2, kumar.name, 6),
      (6, 'Planned', t2, kumar.name, 6),
      (7, 'Planned', t3, rajesh.name, 0),
      (8, 'Booked', t3, rajesh.name, 0),
      (9, 'Planned', tOutside, 'Outside: Tan B.', 0),
      (10, 'Pending', null, '', 0),
      (11, 'Pending', null, '', 0),
      (12, 'Cancelled', tNone, '', 0),
      // not on the plan: new-plan search results and older RTIs
      (13, 'Pending', null, '', 0),
      (14, 'Booked', null, '', 0),
      (15, 'Pending', null, '', 0),
      (16, 'Pending', null, '', 0),
      (17, 'Completed', t3, rajesh.name, 7),
      (18, 'Completed', t3, rajesh.name, 7),
      (19, 'Delivered', tOutside, 'Outside: Tan B.', 8),
      (20, 'In Transit', t1, lim.name, 9),
      (21, 'Assigned', t1, lim.name, 9),
      (22, 'Assigned', t1, lim.name, 9),
      (23, 'Planned', t2, ahmad.name, 10),
    ];
    return {
      for (final p in plan)
        p.$1: _Job(
          n: p.$1,
          customer: customers[p.$1 % 3],
          origin: ports[p.$1 % 4],
          destination: places[p.$1 % 5],
          pickup: at(p.$1 > 16 ? 4 : 5, 7 + p.$1 % 8, p.$1.isEven ? 30 : 0),
          delivery: at(p.$1 > 16 ? 4 : (p.$1 % 4 == 0 ? 6 : 5), 13 + p.$1 % 6, 0),
          status: p.$2,
          truck: p.$3,
          driver: p.$4,
          size: p.$1 % 3 == 0 ? '40FT' : '20FT',
          rtiId: p.$5,
        ),
    };
  }

  Map<int, _Rti> _buildRtis() => {
        5: const _Rti(5, t1, ahmad, [1, 2, 3, 4], remarks: 'Seal at Westport, break seal at customer'),
        6: const _Rti(6, t2, kumar, [5, 6]),
        7: const _Rti(7, t3, rajesh, [17, 18], remarks: 'Return empty to depot'),
        8: const _Rti(8, tOutside, outside, [19], outsideDriver: 'Tan B.'),
        9: const _Rti(9, t1, lim, [20, 21, 22], remarks: 'Night delivery'),
        10: const _Rti(10, t2, ahmad, [23]),
      };

  List<_Job> get planJobs => [for (var n = 1; n <= 12; n++) _jobs[n]!];

  _Job? jobBySo(int soId) => _jobs[soId - 20400];

  // ----------------------------------------------------------------------------- routing

  _Reply? route(String method, String path, RequestOptions o) {
    final body = o.data;
    Match? m(String pattern) => RegExp('^$pattern\$').firstMatch(path);
    Match? r;

    // ---- access, people, places
    if (method == 'GET' && (r = m(r'/api/screen-access/([^/]+)/me')) != null) {
      return _ok(_api({'screen': r![1], 'roleId': 200, 'actions': ['VIEW', 'CREATE', 'EDIT', 'DELETE']}, 'Screen access'));
    }
    if (method == 'GET' && m(r'/api/employees/company/\d+/all') != null) return _ok(employeeRows());
    if (method == 'GET' && m(r'/api/port-masters/company/\d+/active') != null) {
      return _ok(_api([
        for (final (i, p) in ['WESTPORT', 'NORTHPORT', 'PTP', 'PKFZ'].indexed)
          {'id': i + 1, 'companyRefId': companyId, 'portName': p, 'portCode': p.substring(0, 3), 'active': 1},
      ]));
    }

    // ---- trucks and drivers
    if (method == 'GET' && path == '/api/truck-masters/alltruckdetatilcombo') return _ok(_api([for (final t in trucks) truckDto(t)]));
    if (method == 'GET' && path == '/api/truck-combo') {
      return _ok({'isSuccess': true, 'message': 'Success', 'data1': [for (final t in trucks) {'Id': t.id, 'AccountName': t.name}]});
    }
    if (method == 'GET' && path == '/api/truck-masters/search') {
      final id = _int(o.queryParameters['keyword']);
      final found = trucks.where((t) => t.id == id || id == 0).map(truckDto).toList();
      return _ok(_api({'items': found, 'totalCount': found.length}));
    }
    if (method == 'GET' && (r = m(r'/api/truck-masters/(\d+)')) != null) {
      final id = int.parse(r![1]!);
      final t = trucks.where((t) => t.id == id).firstOrNull;
      return t == null ? const _Reply(404, 'Not found') : _ok(truckDto(t));
    }
    if (method == 'GET' && path == '/api/driver-masters/selectalldriverDetails') return _ok(_api([for (final d in drivers) driverDto(d)]));
    if (method == 'GET' && path == '/api/driver-combo') {
      return _ok({
        'isSuccess': true,
        'message': 'Success',
        'data1': [for (final d in drivers) {'Id': d.id, 'AccountName': '${d.name}-${d.mobile}'}],
      });
    }
    if (method == 'GET' && path == '/api/driver-masters/search') {
      return _ok(_api({'items': [for (final d in drivers) driverDto(d)], 'totalCount': drivers.length}));
    }

    // ---- planning
    if (method == 'POST' && m(r'/api/planing/max-planning-no/\d+') != null) {
      return _ok({'sequenceNumber': 'PL000000783', 'companyId': companyId, 'success': true, 'error': null});
    }
    if (method == 'POST' && path == '/api/planing/select-planning') return _ok(selectPlanning());
    if (method == 'GET' && path == '/api/planing/edit') {
      final id = _int(o.queryParameters['id']);
      final no = _int(o.queryParameters['planningNo']);
      if (id == planId || no == planId || (id == 0 && no == 0)) return _ok(planEdit());
      if (id == 781 || no == 781 || id == 780 || no == 780) return _ok(olderPlanEdit(id > 0 ? id : no));
      return _ok(null);
    }
    if (method == 'POST' && path == '/api/planing/search') {
      final b = _map(body);
      final search = '${b['search'] ?? ''}'.trim().toUpperCase();
      final rows = [
        for (final j in _jobs.values)
          if (j.n <= 16 && (j.truck == null || j.n <= 12)) j,
      ];
      final filtered = search.isEmpty ? rows : rows.where((j) => search.split(',').any((p) => p.trim().isEmpty || j.origin.contains(p.trim()))).toList();
      return _ok([for (final j in filtered) planRow(j, edit: false)]);
    }
    if (method == 'POST' && path == '/api/planing/save') {
      final plan = body is List && body.isNotEmpty ? _map(body.first) : _map(body);
      final existing = _int(plan['id'] ?? plan['Id']) > 0;
      return _ok([
        {'ok': true, 'message': existing ? 'Planning updated successfully' : 'Planning saved successfully', 'name': planNo, 'id': planId},
      ]);
    }
    if (method == 'DELETE' && (r = m(r'/api/planing/(\d+)')) != null) {
      return _ok({'ok': true, 'message': 'Planning deleted successfully', 'name': planNo, 'id': int.parse(r![1]!)});
    }
    if (method == 'POST' && path == '/api/planing/update-dates') return _ok(updateDates(_map(body)));
    if (method == 'GET' && (r = m(r'/api/planing/(\d+)/rti-batch/preview')) != null) return _ok(_api(batchPreview(), 'RTI batch preview'));
    if (method == 'POST' && (r = m(r'/api/planing/(\d+)/rti-batch')) != null) return _ok(_api(batchCreate(_map(body)), 'RTIs created'));
    if (method == 'GET' && (r = m(r'/api/planning/reports/(\d+)/pdf-ticket')) != null) {
      return _ok(_api({'Ticket': 'preview', 'FileName': 'Planning_$planNo.pdf', 'Url': samplePdf}, 'Planning report ready'));
    }
    if (method == 'POST' && path == '/api/rti-details/rti-status') {
      final ids = body is List ? body.map(_int).toSet() : <int>{};
      return _ok([
        for (final j in _jobs.values)
          if (j.rtiId > 0 && ids.contains(j.soId)) {'saleOrderMasterRefId': j.soId, 'rtiMasterRefId': j.rtiId, 'rtiNo': _rtis[j.rtiId]!.no},
      ]);
    }

    // ---- sale orders
    if (method == 'GET' && path == '/api/sale-orders/edit') {
      final job = jobBySo(_int(o.queryParameters['id']));
      if (job == null) return const _Reply(404, {'Message': 'Sale order not found', 'IsSuccess': false});
      return _ok(_api({
        'saleOrderMaster': saleOrderMaster(job),
        'saleOrderDetails': const [],
        'pickupDetails': [
          {'id': job.soId * 10 + 1, 'pickupAddress': job.pickupAddress, 'pickupQuantity': job.quantity, 'pickupWeight': job.weight, 'pickupTime': _iso(job.pickup)},
        ],
        'deliveryDetails': [
          {'id': job.soId * 10 + 2, 'deliveryAddress': job.deliveryAddress, 'deliveryQuantity': job.quantity, 'deliveryWeight': job.weight, 'deliveryTime': _iso(job.delivery)},
        ],
        'forwardingDetails': const [],
      }));
    }
    if (method == 'POST' && path == '/api/sale-orders/search') {
      final wanted = '${_map(body)['Search'] ?? ''}'.trim().toUpperCase();
      return _ok(_api({
        'salemaster': [
          for (final j in _jobs.values)
            if (wanted.isEmpty || j.jobNo.toUpperCase() == wanted)
              {'Id': j.soId, 'CNumberDisplay': j.jobNo, 'BillNoDisplay': j.jobNo, 'BillDate': _dmy(j.jobDate), 'CustomerName': j.customer, 'JobStatus': j.status},
        ],
        'saledetails': const [],
      }));
    }
    if (method == 'GET' && (r = m(r'/api/sale-orders/(\d+)')) != null) {
      final job = jobBySo(int.parse(r![1]!));
      return job == null ? const _Reply(404, 'Sale order not found') : _ok({'saleOrderMaster': saleOrderMaster(job)});
    }

    // ---- RTIs
    if (method == 'GET' && path == '/api/rti-masters/with-jobs') {
      final search = '${o.queryParameters['search'] ?? ''}'.trim().toUpperCase();
      final list = [for (final id in rtiIds) rtiWithJobs(id)];
      return _ok(_api(search.isEmpty ? list : list.where((x) => '${x['rtiNoDisplay']}'.toUpperCase() == search).toList()));
    }
    if (method == 'GET' && (r = m(r'/api/rti-masters/company/\d+/job-search')) != null) {
      final wanted = '${o.queryParameters['jobNo'] ?? ''}'.trim().toUpperCase();
      return _ok(_api([
        for (final j in _jobs.values)
          if (j.jobNo.toUpperCase() == wanted) {'id': j.soId, 'jobNo': j.jobNo, 'jobDate': _iso(j.jobDate), 'customerName': j.customer},
      ]));
    }
    if (method == 'GET' && m(r'/api/rti-masters/company/\d+') != null) {
      return _ok([for (final id in rtiIds) {'id': id, 'cnumberDisplay': rtiNo(id), 'companyRefId': companyId}]);
    }
    if (method == 'GET' && (r = m(r'/api/rti-masters/(\d+)/revise')) != null) {
      final id = int.parse(r![1]!);
      if (!_known(id)) return const _Reply(404, {'IsSuccess': false, 'StatusCode': 404, 'Message': 'RTI not found'});
      return _ok(_api(revise(id), 'RTI revise data'));
    }
    if (method == 'GET' && (r = m(r'/api/rti-masters/(\d+)/report-ticket')) != null) {
      final id = int.parse(r![1]!);
      return _ok(_api({'Ticket': 'preview', 'FileName': '${rtiNo(id)}.pdf', 'Url': samplePdf}, 'RTI report ready'));
    }
    if (method == 'POST' && (r = m(r'/api/rti-masters/(\d+)/share-whatsapp')) != null) {
      final id = int.parse(r![1]!);
      final truck = _rtis[id]?.truck.name ?? t1.name;
      return _ok(_api({
        'sent': true,
        'rtiNo': rtiNo(id),
        'truck': truck,
        'group': '$truck Trip Group',
        'messages': 2,
        'detail': 'Sent to the $truck WhatsApp group (preview, nothing was sent)',
        'documentSkipped': null,
      }, 'RTI shared'));
    }
    if (method == 'GET' && (r = m(r'/api/rti-masters/(\d+)')) != null) {
      final id = int.parse(r![1]!);
      return _known(id) ? _ok(rtiMaster(id)) : _Reply(404, 'RTIMaster not found with ID: $id');
    }
    if (method == 'POST' && path == '/api/rti-masters') return _Reply(201, saveRti(0, _map(body)));
    if (method == 'PUT' && (r = m(r'/api/rti-masters/(\d+)')) != null) return _ok(saveRti(int.parse(r![1]!), _map(body)));
    if (method == 'DELETE' && (r = m(r'/api/rti-masters/(\d+)')) != null) return const _Reply(204, null);
    if (method == 'GET' && (r = m(r'/api/rti-details/rti-master/(\d+)')) != null) return _ok(rtiLines(int.parse(r![1]!)));
    if (method == 'GET' && m(r'/api/sequence-masters/company/\d+') != null) {
      return _ok([
        {'id': 1, 'companyRefId': companyId, 'sequenceName': 'RTIMaster', 'sequenceNo': 12340 + _nextRtiId - 1},
        {'id': 2, 'companyRefId': companyId, 'sequenceName': 'PLANINGMaster', 'sequenceNo': 782},
      ]);
    }
    if (method == 'GET' && path == '/api/rti-route-activities') return _ok(_api([for (final a in routeActivities(5)) {...a, 'rtinumber': rtiNo(5), 'lorryNo': t1.name}]));
    if (method == 'PUT' && m(r'/api/rti-route-activities/\d+/status') != null) return _ok(_api(1, 'Status updated'));
    if (method == 'POST' && path == '/api/rti/employee-assignments') return _ok(_api(assignments(), 'Employee assignments'));

    // ---- Levi
    if (method == 'GET' && (r = m(r'/api/levi-entries/by-rti/(\d+)')) != null) {
      final items = leviOf(int.parse(r![1]!));
      final total = items.fold<num>(0, (a, i) => a + (i['amount'] as num? ?? 0));
      return _ok(_api({'items': items, 'entriesTotal': total}));
    }
    if (method == 'GET' && path == '/api/levi-entries/next-no') return _ok(_api('LE00000$_nextLevi'));
    if (method == 'POST' && path == '/api/levi-entries') return _ok(_api(saveLevi(_map(body)), 'Levi entry saved'));
    if (method == 'DELETE' && (r = m(r'/api/levi-entries/(\d+)')) != null) {
      final id = int.parse(r![1]!);
      for (final list in _levi.values) {
        list.removeWhere((i) => i['id'] == id);
      }
      return _ok(_api(true, 'Levi entry deleted'));
    }

    // ---- attachments (the Levi sheet's files)
    if (path == '/api/attachments') {
      if (method == 'GET') return _ok(_api(const []));
      if (method == 'DELETE' || method == 'POST') return _ok(_api({'attachments': const []}));
    }
    return null;
  }

  static const samplePdf = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  // ---------------------------------------------------------------------------- people, fleet

  List<Map<String, dynamic>> employeeRows() => [
        for (final e in employees)
          {
            'id': e.$1,
            'companyRefId': companyId,
            'employeeName': e.$2,
            'employeeType': e.$3,
            'cNumberDisplay': 'EMP${_two(e.$1)}',
            'email': '${e.$2.split(' ').first.toLowerCase()}@example.com',
            'mobileNo': '01000000${_two(e.$1)}',
            'userName': e.$2.split(' ').first.toLowerCase(),
            'active': 1,
            'roleId': e.$1 == 12 ? 200 : 300,
          },
      ];

  String _day(int fromToday) => _ymd(today.add(Duration(days: fromToday)));

  Map<String, dynamic> truckDto(_Truck t) {
    final real = t.id > 100;
    String? exp(int days) => real ? _day(days) : null;
    return {
      'id': t.id,
      'companyRefId': companyId,
      'truckName': t.name,
      'truckNumber': t.name,
      'cNumberDisplay': 'TRK${t.id}',
      'truckType': t.type,
      'active': 1,
      'rotexMyExp': exp(220),
      'rotexSGExp': exp(240),
      // WYA 9012: Puspakom in 2 days (critical)
      'puspacomExp': t.id == 103 ? _day(2) : exp(180),
      'insuranceExp': exp(300),
      // WXZ 5678: service due in 4 days (a warning)
      'serviceExp': t.id == 102 ? _day(4) : exp(60),
      'alignmentExp': exp(90),
      'greeceExp': exp(45),
      'gearOilExp': exp(120),
      'ptpStickerExp': exp(150),
      'malevaTruck': real ? 1 : 0,
      'truckStatus': 'ACTIVE',
      'driverRefId': switch (t.id) { 101 => ahmad.id, 102 => kumar.id, 103 => rajesh.id, _ => null },
      'driverName': switch (t.id) { 101 => ahmad.name, 102 => kumar.name, 103 => rajesh.name, _ => null },
      'whatsAppGroup': real ? '${t.name} Trip Group' : null,
    };
  }

  Map<String, dynamic> driverDto(_Driver d) => {
        'id': d.id,
        'companyRefId': companyId,
        'driverName': d.name,
        'cNumberDisplay': 'DRV${d.id}',
        'mobileNo': d.mobile,
        'email': null,
        'active': 1,
        'licenseNo': d.id == 36 ? null : 'D${d.id}0000',
        'licenseExp': d.id == 36 ? null : _day(d.id == 202 ? 5 : 400),
        'gdlNo': d.id == 36 ? null : 'G${d.id}0000',
        'gdlExp': d.id == 36 ? null : _day(200),
        'truckRefId': switch (d.id) { 201 => 101, 202 => 102, 203 => 103, _ => null },
        'joiningDate': '2023-01-0${d.id % 9 + 1}',
        'leaves': d.id == 203
            ? [
                {
                  'Id': 77,
                  'CompanyRefId': companyId,
                  'ApplicantType': 2,
                  'ApplicantRefId': d.id,
                  'ApplicantName': d.name,
                  'LeaveTypeRefId': 1,
                  'LeaveTypeName': 'Annual Leave',
                  'FromDate': '${_day(1)}T00:00:00',
                  'ToDate': '${_day(3)}T00:00:00',
                  'TotalDays': 3,
                  'Reason': 'Family event',
                  'StatusRefId': 1,
                  'StatusName': 'PENDING',
                },
              ]
            : const [],
      };

  // -------------------------------------------------------------------------------- planning

  /// `PlanningDetailsModel` as `/api/planing/search` (edit: false) and the edit's `SaleDetails` send it.
  Map<String, dynamic> planRow(_Job j, {required bool edit}) {
    final truck = j.truck;
    return {
      'Id': edit ? 9000 + j.n : j.soId,
      'SDId': edit ? 9000 + j.n : 0,
      'PLANINGMasterRefId': edit ? planId : 0,
      'SaleOrderMasterRefId': j.soId,
      'TruckRefid': truck?.id ?? 0,
      'TruckName': truck?.name ?? '',
      'DriverName': j.driver,
      'JobNo': j.jobNo,
      'JobDate': _dmy(j.jobDate),
      'JobStatus': j.status,
      'JobName': 'TRANSPORT',
      'AWBNo': '',
      'BLCopy': '',
      'CustomerName': j.customer,
      'Remarks': j.n == 7 ? 'Call PIC before arrival' : '',
      'Origin': j.origin,
      'Destination': j.destination,
      'OriginD': j.origin,
      'DestinationD': j.destination,
      'VesselName': j.vessel,
      'pkg': '${j.quantity}/${j.weight}',
      'EmployeeName': j.pic,
      'truckSize': j.size,
      'SPickupDate': _sql120(j.pickup),
      'PickupDate': _iso(j.pickup),
      'DeliveryDate': _iso(j.delivery),
      'PickupDateD': _dmy(j.pickup),
      'DeliveryDateD': _dmy(j.delivery),
      'LETA': _sql120(j.pickup.subtract(const Duration(days: 2))),
      'OETA': '',
      'SDeliveryDate': _sql120(j.delivery),
      'WareHouseEnterDate': null,
      'WareHouseExitDate': null,
      'SWareHouseEnterDate': '',
      'SWareHouseExitDate': '',
      'WareHouseAddress': '',
      'PickupAddress': j.pickupAddress,
      'DeliveryAddress': j.deliveryAddress,
      'SPort': j.origin,
      'OPort': '',
      'SortBy': edit && truck != null ? '${j.n}' : '',
      'TruckNameD': truck?.name ?? '',
      'DriverNameD': j.driver,
      'pickuptimelist': _sql120(j.pickup),
      'pickupQuantitylist': j.quantity,
      'DeliveryQuantitylist': j.quantity,
      'Delivertimelist': _sql120(j.delivery),
      'Package': j.quantity,
      'Weight': j.weight,
      'RTINo': j.rtiId > 0 ? rtiNo(j.rtiId) : '',
    };
  }

  /// `PlanningEditResponseDto` (bare).
  Map<String, dynamic> planEdit() => {
        'Id': planId,
        'CompanyRefId': companyId,
        'UserRefId': 12,
        'EmployeeRefId': 12,
        'LastEmployeeRefId': 12,
        'FDate': _iso(planDate),
        'TDate': _iso(planDate),
        'SFDate': _dmy(planDate),
        'STDate': _dmy(planDate),
        'SaleDate': _iso(planDate),
        'SSaleDate': _dmy(planDate),
        'CNumberDisplay': planNo,
        'CNumber': planId,
        'Remarks': 'Morning port run',
        'Search': 'WESTPORT,NORTHPORT,PTP,PKFZ',
        'Active': 1,
        'Created_Date': '${_dmy(planDate)} 07:10',
        'Created_By': 'Siti A.',
        'Modified_Date': '${_dmy(planDate)} 08:25',
        'Modified_By': 'Siti A.',
        'SaleDetails': [for (final j in planJobs) planRow(j, edit: true)],
      };

  Map<String, dynamic> olderPlanEdit(int id) {
    final date = DateTime(2026, 10, 5 - (planId - id));
    final jobs = [for (final n in id == 781 ? [17, 18, 19] : [20, 21, 22, 23]) _jobs[n]!];
    return {
      ...planEdit(),
      'Id': id,
      'CNumber': id,
      'CNumberDisplay': 'PL000000$id',
      'FDate': _iso(date),
      'TDate': _iso(date),
      'SaleDate': _iso(date),
      'SSaleDate': _dmy(date),
      'Remarks': '',
      'SaleDetails': [for (final j in jobs) {...planRow(j, edit: true), 'PLANINGMasterRefId': id}],
    };
  }

  /// `PlanningF5View`: the masters (`PlanningMasterViewModel`) and every row.
  Map<String, dynamic> selectPlanning() {
    Map<String, dynamic> master(int id, DateTime date, int orders, String remarks, String by) => {
          'Id': id,
          'SDId': 0,
          'PLANINGNo': id,
          'PLANINGNoDisplay': 'PL000000$id',
          'FDate': _iso(date),
          'TDate': _iso(date),
          'SFDate': _dmy(date),
          'STDate': _dmy(date),
          'SaleDate': _iso(date),
          'SSaleDate': _dmy(date),
          'PLANINGDate': _dmy(date),
          'CNumberDisplay': 'PL000000$id',
          'Remarks': remarks,
          'EmployeeName': by,
          'TotalOrders': orders,
          'Active': 1,
          'Created_Date': _dmy(date),
          'Created_By': by,
          'Modified_Date': _dmy(date),
          'Modified_By': by,
        };
    return {
      'salemaster': [
        master(planId, planDate, 12, 'Morning port run', 'Siti A.'),
        master(781, DateTime(2026, 10, 4), 3, '', 'Farid H.'),
        master(780, DateTime(2026, 10, 3), 4, 'Night delivery', 'Siti A.'),
      ],
      'saledetails': [
        for (final j in planJobs) planRow(j, edit: true),
        for (final n in [17, 18, 19]) {...planRow(_jobs[n]!, edit: true), 'PLANINGMasterRefId': 781},
        for (final n in [20, 21, 22, 23]) {...planRow(_jobs[n]!, edit: true), 'PLANINGMasterRefId': 780},
      ],
    };
  }

  /// `PlanningSaleOrderUpdateResponse`: the saved values echoed back.
  Map<String, dynamic> updateDates(Map<String, dynamic> b) {
    final job = jobBySo(_int(b['saleOrderId']));
    String text(String k) => '${b[k] ?? ''}'.replaceFirst('T', ' ');
    final pickups = b['pickups'] is List ? b['pickups'] as List : const [];
    final deliveries = b['deliveries'] is List ? b['deliveries'] as List : const [];
    return {
      'ok': true,
      'message': 'Job ${job?.jobNo ?? b['saleOrderId']} updated',
      'saleOrderId': _int(b['saleOrderId']),
      'pickupDate': text('pickupDate'),
      'deliveryDate': text('deliveryDate'),
      'origin': b['origin'] ?? job?.origin,
      'destination': b['destination'] ?? job?.destination,
      'quantity': '${b['quantity'] ?? job?.quantity ?? ''}',
      'totalWeight': '${b['totalWeight'] ?? job?.weight ?? ''}',
      'packageType': '${b['quantity'] ?? ''}/${b['totalWeight'] ?? ''}',
      'wareHouseEnterDate': text('wareHouseEnterDate'),
      'wareHouseExitDate': text('wareHouseExitDate'),
      'wareHouseAddress': '${b['wareHouseAddress'] ?? ''}',
      'pickupAddress': [for (final p in pickups) _map(p)['address']].join('{@}'),
      'deliveryAddress': [for (final d in deliveries) _map(d)['address']].join('{@}'),
      'pickupQuantityList': [for (final p in pickups) _map(p)['quantity']].join('{@}'),
      'deliveryQuantityList': [for (final d in deliveries) _map(d)['quantity']].join('{@}'),
      'pickupCount': pickups.length,
      'deliveryCount': deliveries.length,
    };
  }

  Map<String, dynamic> _batchJob(_Job j) => {
        'planningDetailId': 9000 + j.n,
        'saleOrderMasterRefId': j.soId,
        'jobNo': j.jobNo,
        'customerName': j.customer,
        'origin': j.origin,
        'destination': j.destination,
        'pickupDate': _iso(j.pickup),
        'deliveryDate': _iso(j.delivery),
        'sortBy': j.n,
        'remarks': '',
        'existingRtiId': j.rtiId > 0 ? j.rtiId : null,
        'existingRtiNo': j.rtiId > 0 ? rtiNo(j.rtiId) : null,
        'existingRtiDate': j.rtiId > 0 ? _ymd(planDate) : null,
      };

  /// `PlanningRtiBatchPreview`: jobs 7-8 (WYA 9012, driver from the plan) and 9 (outside driver)
  /// make two groups; jobs on an RTI, without a truck, on NONE or cancelled are skipped.
  Map<String, dynamic> batchPreview() {
    final j7 = _jobs[7]!, j8 = _jobs[8]!, j9 = _jobs[9]!;
    final skipped = [
      for (final j in planJobs)
        if (j.rtiId > 0)
          {
            'planningDetailId': 9000 + j.n,
            'saleOrderMasterRefId': j.soId,
            'jobNo': j.jobNo,
            'customerName': j.customer,
            'truckName': j.truck?.name,
            'reason': 'HAS_RTI',
            'message': 'Already on ${rtiNo(j.rtiId)}',
            'existingRtiId': j.rtiId,
            'existingRtiNo': rtiNo(j.rtiId),
          }
        else if (j.truck == null || j.truck!.id == 43)
          {
            'planningDetailId': 9000 + j.n,
            'saleOrderMasterRefId': j.soId,
            'jobNo': j.jobNo,
            'customerName': j.customer,
            'truckName': j.truck?.name,
            'reason': 'NO_TRUCK',
            'message': j.truck == null ? 'No truck on the plan row' : 'Truck NONE',
            'existingRtiId': null,
            'existingRtiNo': null,
          },
    ];
    return {
      'planningId': planId,
      'planningNo': planNo,
      'planningDate': _ymd(planDate),
      'plannedJobs': 12,
      'jobsToCreate': 3,
      'jobsSkipped': skipped.length,
      'groups': [
        {
          'groupKey': '103|${_ymd(planDate)}|1',
          'truckRefId': t3.id,
          'truckName': t3.name,
          'driverRefId': rajesh.id,
          'driverName': rajesh.name,
          'driverSource': 'PLAN',
          'outsideDriver': '',
          'pickupDate': _ymd(planDate),
          'tripLabel': 'Trip 1',
          'jobs': [_batchJob(j7), _batchJob(j8)],
          'warnings': ['Puspakom of ${t3.name} expires in 2 days', '${rajesh.name} has a pending leave'],
        },
        {
          'groupKey': '22|${_ymd(planDate)}|1',
          'truckRefId': tOutside.id,
          'truckName': tOutside.name,
          'driverRefId': outside.id,
          'driverName': outside.name,
          'driverSource': 'OUTSIDE',
          'outsideDriver': 'Tan B.',
          'pickupDate': _ymd(planDate),
          'tripLabel': 'Trip 1',
          'jobs': [_batchJob(j9)],
          'warnings': const [],
        },
      ],
      'skipped': skipped,
      'warnings': const ['3 jobs are not on a truck yet'],
    };
  }

  Map<String, dynamic> batchCreate(Map<String, dynamic> request) {
    final groups = request['groups'] is List ? (request['groups'] as List).map(_map).toList() : <Map<String, dynamic>>[];
    final created = <Map<String, dynamic>>[];
    for (final g in groups) {
      final id = _nextRtiId++;
      final truck = trucks.where((t) => t.id == _int(g['truckRefId'])).firstOrNull;
      final driver = drivers.where((d) => d.id == _int(g['driverRefId'])).firstOrNull;
      final jobs = g['saleOrderMasterRefIds'] is List ? (g['saleOrderMasterRefIds'] as List).map(_int).toList() : <int>[];
      _savedRtis[id] = {
        'id': id,
        'truckRefId': truck?.id,
        'driverRefId': driver?.id,
        'outsideDriver': g['outsideDriver'],
        'outsideTruck': g['outsideTruck'],
        'rtiDetails': [for (final so in jobs) if (jobBySo(so) != null) rtiLine(id, jobBySo(so)!, so)],
      };
      created.add({
        'rtiId': id,
        'rtiNo': rtiNo(id),
        'truckRefId': truck?.id,
        'truckName': truck?.name,
        'driverRefId': driver?.id,
        'driverName': driver?.name,
        'jobCount': jobs.length,
      });
    }
    final count = created.fold<int>(0, (n, c) => n + (c['jobCount'] as int));
    return {
      'planningId': planId,
      'planningNo': planNo,
      'plannedJobs': 12,
      'jobsCreated': count,
      'jobsSkipped': 12 - count,
      'created': created,
      'skipped': const [],
    };
  }

  /// `SaleOrderMasterDto` (Java names).
  Map<String, dynamic> saleOrderMaster(_Job j) => {
        'id': j.soId,
        'companyRefId': companyId,
        'cNumberDisplay': j.jobNo,
        'cNumber': j.soId,
        'customerName': j.customer,
        'saleDate': _iso(j.jobDate),
        'jStatus': j.status,
        'origin': j.origin,
        'destination': j.destination,
        'originRefId': null,
        'destinationRefId': null,
        'pickupDate': _iso(j.pickup),
        'deliveryDate': _iso(j.delivery),
        'pickupAddress': j.pickupAddress,
        'deliveryAddress': j.deliveryAddress,
        'pickuptimelist': _sql120(j.pickup),
        'pickupQuantitylist': j.quantity,
        'deliveryQuantitylist': j.quantity,
        'delivertimelist': _sql120(j.delivery),
        'quantity': j.quantity,
        'totalWeight': j.weight,
        'offvesselname': j.vessel,
        'sPort': j.origin,
        'wareHouseAddress': '',
        'wareHouseEnterDate': null,
        'wareHouseExitDate': null,
      };

  // ------------------------------------------------------------------------------------ RTI

  Iterable<int> get rtiIds => [..._rtis.keys, ..._savedRtis.keys.where((k) => !_rtis.containsKey(k))];

  bool _known(int id) => _rtis.containsKey(id) || _savedRtis.containsKey(id);

  String rtiNo(int id) => 'RTI0000${12340 + id}';

  /// `RTIDetailsDto` of a job on the RTI.
  Map<String, dynamic> rtiLine(int rtiId, _Job j, int lineId) => {
        'id': lineId,
        'rtiMasterRefId': rtiId,
        'saleOrderMasterRefId': j.soId,
        'salary': j.size == '40FT' ? 150.0 : 120.0,
        'ppic': j.pic,
        'dpic': 'Mei Ling T.',
        'pwdType': 0,
        'pickupDateD': _iso(j.pickup),
        'deliveryDateD': _iso(j.delivery),
        'jobNo': j.jobNo,
        'jobDate': _iso(j.jobDate),
        'customerName': j.customer,
        'originD': j.origin,
        'destinationD': j.destination,
        'pickupAddressD': j.pickupAddress,
        'deliveryAddressD': j.deliveryAddress,
        'pickupAddressTimelistD': _sql120(j.pickup),
        'pickupAddressQuantityD': j.quantity,
        'deliveryAddressQuantityD': j.quantity,
        'deliveryAddressdatelistD': _sql120(j.delivery),
        'createdDate': _iso(planDate),
        'modifiedDate': _iso(planDate),
      };

  List<Map<String, dynamic>> rtiLines(int id) {
    final saved = _savedRtis[id];
    if (saved != null) return [for (final l in (saved['rtiDetails'] as List? ?? const [])) _map(l)];
    final rti = _rtis[id];
    if (rti == null) return const [];
    return [for (final n in rti.jobs) rtiLine(id, _jobs[n]!, id * 100 + n)];
  }

  List<Map<String, dynamic>> routeActivities(int id) {
    if (id != 5) return const [];
    Map<String, dynamic> stop(int seq, String place, String type, int status, int hour, int employee, String agent) => {
          'id': 500 + seq,
          'companyRefId': companyId,
          'rtiMasterRefId': id,
          'sequenceNo': seq,
          'locationName': place,
          'activityType': type,
          'employeeRefId': employee,
          'agentName': agent,
          'agentMobileNo': '01000000${_two(employee)}',
          'status': status,
          'plannedDateTime': _iso(DateTime(2026, 10, 5, hour)),
          'eta': _iso(DateTime(2026, 10, 5, hour, 15)),
          'remarks': seq == 2 ? 'K1 form with the agent' : '',
          'rtiId': id,
          'cNumber': 12340 + id,
          'fullRoute': 'WESTPORT > PKFZ > SHAH ALAM',
          'driverNumber': ahmad.mobile,
          'marqisStatus': seq == 1 ? 1 : 0,
          'active': true,
          'createdDate': _iso(DateTime(2026, 10, 5, 6, 40)),
        };
    return [
      stop(1, 'WESTPORT', 'SEAL', 1, 7, 15, 'Farid H.'),
      stop(2, 'PKFZ', 'K1 Clearance', 0, 10, 21, 'Arjun K.'),
      stop(3, 'SHAH ALAM', 'BREAK_SEAL', 0, 13, 15, 'Farid H.'),
    ];
  }

  /// `RTIMasterDto` (Jackson writes `CNumberDisplay` / `eLink` as `cnumberDisplay` / `elink`).
  Map<String, dynamic> rtiMaster(int id) {
    final saved = _savedRtis[id];
    final rti = _rtis[id];
    final lines = rtiLines(id);
    final salaries = lines.fold<double>(0, (a, l) => a + ((l['salary'] as num?) ?? 0).toDouble());
    final sleeping = id == 5 ? 1 : 0;
    final base = <String, dynamic>{
      'id': id,
      'companyRefId': companyId,
      'userRefId': 12,
      'employeeRefId': 12,
      'agentCompanyRefId': null,
      'agentMasterRefId': null,
      'saleDate': _iso(id >= 7 && id <= 8 ? DateTime(2026, 10, 4) : planDate),
      'cnumberDisplay': rtiNo(id),
      'cnumber': 12340 + id,
      'remarks': rti?.remarks ?? '',
      'elink': id == 5 ? 'IN' : '',
      'active': 1,
      'sleeping': sleeping,
      'sleepingAmount': sleeping * 50.0,
      'amount': salaries + sleeping * 50,
      'createdDate': _iso(DateTime(2026, 10, 5, 6, 30)),
      'createdBy': 'Siti A.',
      'modifiedDate': _iso(DateTime(2026, 10, 5, 8, 10)),
      'modifiedBy': 'Siti A.',
      'truckRefId': rti?.truck.id,
      'driverRefId': rti?.driver.id,
      'pickup': 0,
      'pickupCount': 0,
      'pickupAmount': 0.0,
      'dropCount': 0,
      'dropAmount': 0.0,
      'addDrop': 0,
      'exitYN': 0,
      'exitAmount': 0,
      'exLink': id == 5 ? '2ND LINK' : '',
      'destination': rti == null || rti.jobs.isEmpty ? '' : _jobs[rti.jobs.first]!.destination,
      'sealBy': id == 5 ? 'Farid H.' : '',
      'breakSealBy': id == 5 ? 'Farid H.' : '',
      'lastEmployeeRefId': 12,
      'emptyDeliveryYN': 0,
      'emptyDeliveryAmount': 0,
      'comments': id == 5 ? 'Customer asked for a call 30 minutes before arrival' : '',
      'manpw': 0,
      'manpwAmount': 0.0,
      'pckHandling': id == 5 ? 1 : 0,
      'punctuality': 1,
      'documentSub': id == 5 ? 1 : 0,
      'outsideDriver': rti?.outsideDriver ?? '',
      'outsideTruck': rti?.outsideDriver ?? '',
      'rtiDetails': null,
      'routeActivities': routeActivities(id),
    };
    if (saved == null) return base;
    final merged = {...base, ...saved, 'cnumberDisplay': rtiNo(id), 'cnumber': 12340 + id};
    merged.remove('CNumberDisplay');
    merged['rtiDetails'] = null;
    merged['routeActivities'] = saved['routeActivities'] ?? const [];
    return merged;
  }

  /// The revise of RTI 5: TR0026-0402 now goes to NILAI a day later, TR0026-0403's customer
  /// changed; the other RTIs come back as they are.
  Map<String, dynamic> revise(int id) {
    final lines = rtiLines(id);
    if (id == 5) {
      for (final l in lines) {
        if (l['jobNo'] == 'TR0026-0402') {
          l['destinationD'] = 'NILAI';
          l['deliveryAddressD'] = 'Lot 8, Jalan Contoh 2, NILAI';
          l['deliveryDateD'] = _iso(_jobs[2]!.delivery.add(const Duration(days: 1)));
        }
        if (l['jobNo'] == 'TR0026-0403') l['customerName'] = 'Example Foods Sdn Bhd (Klang)';
      }
    }
    return {...rtiMaster(id), 'rtiDetails': lines};
  }

  Map<String, dynamic> saveRti(int pathId, Map<String, dynamic> body) {
    final id = pathId > 0 ? pathId : _nextRtiId++;
    final lines = body['rtiDetails'] is List ? (body['rtiDetails'] as List).map(_map).toList() : <Map<String, dynamic>>[];
    _savedRtis[id] = {
      ...body,
      'id': id,
      'rtiDetails': [
        for (final (i, l) in lines.indexed)
          {
            ...l,
            'id': _int(l['id']) > 0 ? l['id'] : id * 100 + i + 1,
            'rtiMasterRefId': id,
            'jobNo': l['jobNo'] ?? jobBySo(_int(l['saleOrderMasterRefId']))?.jobNo,
            'customerName': l['customerName'] ?? jobBySo(_int(l['saleOrderMasterRefId']))?.customer,
          },
      ],
    };
    final saved = rtiMaster(id);
    return saved;
  }

  /// `RtiWithJobs` with its `RtiJob`s.
  Map<String, dynamic> rtiWithJobs(int id) {
    final rti = _rtis[id];
    final master = rtiMaster(id);
    final lines = rtiLines(id);
    final driverId = _int(master['driverRefId']);
    final truckId = _int(master['truckRefId']);
    return {
      'id': id,
      'rtiNo': 12340 + id,
      'rtiNoDisplay': rtiNo(id),
      'rtiDate': '${master['saleDate']}'.substring(0, 10),
      'driverRefId': driverId,
      'driverName': rti?.outsideDriver.isNotEmpty == true
          ? 'OUTSIDE DRIVER (${rti!.outsideDriver})'
          : drivers.where((d) => d.id == driverId).firstOrNull?.name ?? '',
      'truckRefId': truckId,
      'truckName': trucks.where((t) => t.id == truckId).firstOrNull?.name ?? '',
      'employeeRefId': 12,
      'remarks': master['remarks'],
      'amount': master['amount'],
      'jobs': [
        for (final l in lines)
          {
            'id': l['id'],
            'rtiMasterRefId': id,
            'saleOrderMasterRefId': l['saleOrderMasterRefId'],
            'salary': l['salary'],
            'ppic': l['ppic'],
            'dpic': l['dpic'],
            'jobNo': l['jobNo'],
            'jobDate': '${l['jobDate'] ?? ''}'.length >= 10 ? '${l['jobDate']}'.substring(0, 10) : null,
            'customerMasterRefId': 300 + _int(l['saleOrderMasterRefId']) % 3,
            'customerName': l['customerName'],
            'statusId': 0,
            'active': 1,
            'verify': 0,
            'imagePath': null,
          },
      ],
    };
  }

  /// `RtiEmployeeAssignmentResponse` rows: the route stops of RTI 5 and 9 by employee.
  List<Map<String, dynamic>> assignments() {
    Map<String, dynamic> row(int id, int rtiId, _Job j, String employee, String remarks, int pickups, int drops) {
      final rti = _rtis[rtiId]!;
      return {
        'id': id,
        'rtiMasterRefId': rtiId,
        'saleOrderMasterRefId': j.soId,
        'pickupDateD': _iso(j.pickup),
        'deliveryDateD': _iso(j.delivery),
        'originD': j.origin,
        'destinationD': j.destination,
        'rtiNumber': rti.no,
        'remarks': remarks,
        'pickupCount': pickups,
        'dropCount': drops,
        'saleOrderNumber': j.jobNo,
        'vesselNameRaw': j.vessel,
        'customerName': j.customer,
        'commodity': j.n.isEven ? 'FROZEN FOOD' : 'GENERAL CARGO',
        'quantity': j.quantity,
        'truckSize': j.size,
        'employeeName': employee,
        'driverName': rti.driver.name,
        'truckNumber': rti.truck.name,
        'truckType': rti.truck.type,
      };
    }

    return [
      row(1, 5, _jobs[1]!, 'Farid H.', 'Seal at Westport gate 2', 1, 0),
      row(2, 5, _jobs[2]!, 'Arjun K.', 'K1 clearance at PKFZ', 0, 0),
      row(3, 5, _jobs[3]!, 'Siti A.', 'Break seal at customer', 0, 1),
      row(4, 9, _jobs[20]!, 'Mei Ling T.', 'Night delivery, collect POD', 1, 2),
    ];
  }

  // ----------------------------------------------------------------------------------- Levi

  List<Map<String, dynamic>> leviOf(int rtiId) => _levi.putIfAbsent(rtiId, () {
        if (rtiId != 5) return [];
        return [
          {
            'id': 3236,
            'cNumberDisplay': 'LE000003236',
            'saleDate': _iso(DateTime(2026, 10, 5, 9, 30)),
            'truckRefId': t1.id,
            'truckName': t1.name,
            'driverRefId': ahmad.id,
            'driverName': ahmad.name,
            'enterLink': 'IN',
            'exitLink': '2ND LINK',
            'amount': 50,
            'remarks': 'Paid at the 2nd Link toll',
          },
        ];
      });

  Map<String, dynamic> saveLevi(Map<String, dynamic> b) {
    final rtiId = _int(b['rtiRefId']);
    final list = leviOf(rtiId);
    final id = _int(b['id']) > 0 ? _int(b['id']) : _nextLevi++;
    final truck = trucks.where((t) => t.id == _int(b['truckRefId'])).firstOrNull;
    final driver = drivers.where((d) => d.id == _int(b['driverRefId'])).firstOrNull;
    final entry = {
      'id': id,
      'cNumberDisplay': 'LE00000$id',
      'saleDate': b['saleDate'],
      'truckRefId': truck?.id,
      'truckName': truck?.name,
      'driverRefId': driver?.id,
      'driverName': driver?.name,
      'enterLink': b['enterLink'] ?? '',
      'exitLink': b['exitLink'] ?? '',
      'amount': b['amount'],
      'remarks': b['remarks'] ?? '',
    };
    list.removeWhere((i) => i['id'] == id);
    list.add(entry);
    return entry;
  }
}
