import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';

/// The lookups and fuel entries the app reads, from the Java APIs the web
/// app uses (one API per feature, shared by React and the app - change
/// `use-shared-lookup-apis`).
///
/// Each method answers in the row shape the app's models already read (the
/// old .NET property names, for example `{Id, AccountName}`), so screens and
/// models stay as they are. The Java answers differ per endpoint (five
/// wrappers, 404 or 204 for an empty list); that is all handled here.
class SharedLookups {
  SharedLookups(this._dio);

  final Dio _dio;

  static final DateFormat _dmy = DateFormat('dd/MM/yyyy');
  static final DateFormat _invariant = DateFormat('MM/dd/yyyy HH:mm:ss');
  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');

  // ------------------------------------------------------------------ lists

  /// `[{Id, AccountName}]`: active trucks, by name.
  Future<List<Map<String, dynamic>>> trucks(int comid, {String? type}) async => _rows(await _get(
      '/api/truck-combo', {'companyId': comid, if (type != null && type.isNotEmpty) 'type': type}));

  /// `[{Id, AccountName = "name-mobile"}]`: active drivers, by name.
  Future<List<Map<String, dynamic>>> drivers(int comid, {String? type}) async => _rows(await _get(
      '/api/driver-combo', {'companyId': comid, if (type != null && type.isNotEmpty) 'type': type}));

  /// `[{Id, AccountName = "name-code"}]`: active customers, by name.
  Future<List<Map<String, dynamic>>> customers(int comid) async {
    final rows = _rows(await _get('/api/customers/options', {'companyId': comid}));
    return [for (final r in rows) {'Id': r['id'], 'AccountName': r['label'] ?? r['customerName']}];
  }

  /// The distinct address names, sorted.
  Future<List<String>> addressNames(int comid) async {
    final rows = _rows(await _get('/api/addresses/company/$comid/active'));
    final names = <String>{for (final r in rows) if (r['name'] != null) r['name'].toString()}.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  /// `[{Id, Name, Address, Phone, Active}]` whose name contains [keyword], by name.
  Future<List<Map<String, dynamic>>> addresses(int comid, {String keyword = ''}) async {
    final rows = _rows(await _get('/api/addresses/company/$comid/search', {'keyword': keyword.trim()}));
    return [
      for (final r in rows)
        {'Id': r['id'], 'Name': r['name'], 'Address': r['address'], 'Phone': r['phone'], 'Active': r['active']}
    ];
  }

  /// `[{Id, Name, DFlag, Active}]`.
  Future<List<Map<String, dynamic>>> jobTypes(int comid) async {
    final rows = _rows(await _getOr('/api/job-type-master/jobtypes/$comid', null, emptyOn404: true));
    return [for (final r in rows) {'Id': r['id'], 'Name': r['name'], 'DFlag': _pick(r, 'dFlag'), 'Active': r['active']}];
  }

  /// One element: the job type's steps and status order, as
  /// `[{JobTypeDetails: [...], JobStatusDetails: [...]}]`.
  Future<List<Map<String, dynamic>>> jobSteps(int comid, int jobId) async {
    final body = await _send(() => _dio.post<dynamic>('/api/job-type-master/select-all-data',
        queryParameters: {'companyId': comid, 'jobId': jobId}), emptyOn404: true);
    final data = body is Map ? body['Data1'] : null;
    final first = data is List && data.isNotEmpty && data.first is Map ? data.first as Map : const {};
    final details = _list(first['jobTypeDetails']);
    final statuses = _list(first['jobStatusDetails']);
    return [
      {
        'JobTypeDetails': [
          for (final d in details)
            {
              'ID': d['id'], 'JobMasterRefId': d['jobMasterRefId'], 'Description': d['description'],
              'JobName': d['jobName'], 'StatusName': d['statusName'], 'Active': d['active'],
              'Mandatory': d['mandatory'], 'Status': d['status'],
            }
        ],
        'JobStatusDetails': [
          for (final s in statuses)
            {
              'ID': s['id'], 'JobMasterRefId': s['jobMasterRefId'], 'Status': s['status'],
              'StatusName': s['statusName'], 'MinStatus': s['minStatus'], 'MinStatusName': s['minStatusName'],
              'Sort': s['sort'],
            }
        ],
      }
    ];
  }

  /// `[{Id, Name, DFlag, Svalue, Active}]`.
  Future<List<Map<String, dynamic>>> jobStatuses(int comid) async {
    // the trailing slash is part of the web API's path
    final rows = _rows(await _getOr('/api/job-status-master/select/$comid/', null, emptyOn404: true));
    return [
      for (final r in rows)
        {'Id': r['id'], 'Name': r['name'], 'DFlag': _pick(r, 'dFlag'), 'Svalue': _pick(r, 'svalue'), 'Active': r['active']}
    ];
  }

  /// Agents of an agent company (0 = every company), by name, in the AgentModel shape.
  Future<List<Map<String, dynamic>>> agents(int comid, {int agentCompanyId = 0}) async {
    final body = await _send(() => _dio.post<dynamic>('/api/agents/select-all',
        queryParameters: {'companyRefId': comid, 'jobId': agentCompanyId}));
    return [
      for (final r in _rows(body))
        {
          'Id': r['id'], 'CompanyRefId': r['companyRefId'], 'CNumberDisplay': _pick(r, 'cNumberDisplay'),
          'CNumber': _pick(r, 'cNumber'), 'AgentName': _pick(r, 'Name'), 'Address1': r['address1'],
          'AgentCompanyRefId': r['agentCompanyRefId'], 'Email': r['email'], 'MobileNo': r['mobileNo'],
          'UserName': r['userName'], 'Active': r['active'], 'Created_Date': r['createdDate'],
          'Modified_Date': r['modifiedDate'], 'Modified_By': r['modifiedBy'],
        }
    ];
  }

  /// `[{Id, Name, DFlag, Active}]`, by name.
  Future<List<Map<String, dynamic>>> agentCompanies(int comid) async {
    final rows = _rows(await _get('/api/agent-companies/company/$comid'));
    final out = [for (final r in rows) {'Id': r['id'], 'Name': r['name'], 'DFlag': _pick(r, 'dFlag'), 'Active': r['active']}]
      ..sort((a, b) => (a['Name'] ?? '').toString().toLowerCase().compareTo((b['Name'] ?? '').toString().toLowerCase()));
    return out;
  }

  /// Active products, by name, in the ProductModel shape (every price a number).
  Future<List<Map<String, dynamic>>> products(int comid) async {
    final rows = _rows(await _get('/api/item-masters/company/$comid/products'));
    return [
      for (final r in rows)
        {
          'Id': r['id'], 'ProductName': r['productName'], 'Productcode': r['productCode'], 'PrintName': null,
          'SaleRate': _num(r['saleRate']), 'WholeSaleRate': 0.0, 'PurRate': _num(r['purRate']),
          'MRP': _num(r['mrp']), 'GST': 0.0, 'CategoryId': 0, 'Imagepath': null,
        }
    ];
  }

  // ------------------------------------------------------------------ trucks

  static const _expiryFields = {
    'RotexMyExp': 'rotexMyExp', 'RotexSGExp': 'rotexSGExp', 'PuspacomExp': 'puspacomExp',
    'RotexMyExp1': 'rotexMyExp1', 'RotexSGExp1': 'rotexSGExp1', 'PuspacomExp1': 'puspacomExp1',
    'InsuratnceExp': 'insuranceExp', 'BonamExp': 'bonamExp', 'ApadExp': 'apadExp',
    'ServiceExp': 'serviceExp', 'AlignmentExp': 'alignmentExp', 'GreeceExp': 'greeceExp',
  };

  static const _otherDates = {
    'AlignmentLast': 'alignmentLast', 'GreeceLast': 'greeceLast', 'GearOilLast': 'gearOilLast',
    'ServiceLast': 'serviceLast', 'GearOilExp': 'gearOilExp', 'PTPStickerExp': 'ptpStickerExp',
  };

  /// The truck in the TruckDetailsModel shape; dates as `MM/dd/yyyy HH:mm:ss`.
  Future<List<Map<String, dynamic>>> truckDetails(int comid, int truckId) async {
    final truck = await _truck(comid, truckId);
    if (truck == null) return [];
    return [
      {
        'Id': truck['id'], 'CompanyRefId': truck['companyRefId'], 'CNumberDisplay': _pick(truck, 'cNumberDisplay'),
        'CNumber': _pick(truck, 'cNumber'), 'TruckName': truck['truckName'], 'TruckNumber': truck['truckNumber'],
        'TruckNumber1': truck['truckNumber1'], 'TruckType': truck['truckType'], 'Latitude': truck['latitude'],
        'longitude': truck['longitude'], 'Active': truck['active'], 'Created_Date': truck['createdDate'],
        'Modified_Date': truck['modifiedDate'], 'Modified_By': truck['modifiedBy'],
        'SIDExp': _pick(truck, 'sidExp'),
        for (final e in _expiryFields.entries) e.key: _invariantDate(_pick(truck, e.value)),
        for (final e in _otherDates.entries) e.key: _invariantDate(_pick(truck, e.value)),
      }
    ];
  }

  /// License Update's save: the truck as stored, with the screen's fields
  /// over it (the web API saves a whole truck). Answers `{IsSuccess, Message}`.
  Future<Map<String, dynamic>> saveTruck(int comid, Map<String, dynamic> row) async {
    final id = int.tryParse('${row['Id']}') ?? 0;
    final truck = await _truck(comid, id);
    if (truck == null) {
      throw ApiFailure('Truck $id was not found');
    }
    final body = Map<String, dynamic>.from(truck)
      ..['truckName'] = row['TruckName'] ?? truck['truckName']
      ..['truckNumber'] = row['TruckNumber'] ?? truck['truckNumber']
      ..['truckNumber1'] = row['TruckNumber1']
      ..['truckType'] = row['TruckType'] ?? truck['truckType']
      ..['latitude'] = row['Latitude']
      ..['longitude'] = row['longitude']
      ..['active'] = row['Active'] ?? truck['active'];
    for (final e in _expiryFields.entries) {
      body[_keyOf(truck, e.value)] = _isoDate(row[e.key]);
    }
    await _send(() => _dio.post<dynamic>('/api/truck-masters/process',
        queryParameters: {'companyId': comid}, data: body));
    return {'IsSuccess': true, 'StatusCode': 1, 'Message': 'Truck Update Successfully..', 'Data2': id};
  }

  Future<Map<String, dynamic>?> _truck(int comid, int truckId) async {
    final body = await _get('/api/truck-masters/search',
        {'companyId': comid, 'startIndex': 0, 'pageCount': 0, 'keyword': '$truckId', 'column': 'Id'});
    final data = body is Map ? body['Data1'] : null;
    final items = data is Map ? _list(data['items']) : const <Map<String, dynamic>>[];
    return items.isEmpty ? null : items.first;
  }

  // ------------------------------------------------------------- fuel entry

  /// The fuel list for the .NET filter body (`Comid, Fromdate, Todate, DId =
  /// truck, TId = driver, Employeeid, Search`), as the old rows.
  Future<List<Map<String, dynamic>>> fuelEntries(Map<String, dynamic> filter) async {
    int id(String k) => int.tryParse('${_pick(filter, k) ?? 0}') ?? 0;
    final search = (_pick(filter, 'Search') ?? '').toString().trim();
    final query = <String, dynamic>{
      'companyRefId': id('Comid'),
      if (search.isNotEmpty) 'search': search,
      if (search.isEmpty && _pick(filter, 'Fromdate') != null) 'fromDate': _dateOnly(_pick(filter, 'Fromdate')),
      if (search.isEmpty && _pick(filter, 'Todate') != null) 'toDate': _dateOnly(_pick(filter, 'Todate')),
      if (id('DId') != 0) 'truckRefId': id('DId'),
      if (id('TId') != 0) 'driverRefId': id('TId'),
      if (id('Employeeid') != 0) 'employeeRefId': id('Employeeid'),
    };
    final body = await _get('/api/fuel-entries', query);
    final data = body is Map ? body['Data1'] : null;
    final items = data is Map ? _list(data['items']) : const <Map<String, dynamic>>[];
    return [for (final r in items) _fuelRow(r, id('Comid'))];
  }

  /// Next fuel number, `FE` + nine digits.
  Future<String> nextFuelNumber(int comid) async {
    final body = await _get('/api/fuel-entries/next-no', {'companyRefId': comid});
    return body is Map ? '${body['Data1'] ?? ''}' : '';
  }

  /// Saves each posted row through the web's fuel save (it recomputes the
  /// amounts and re-matches GPS; a driver's row is stamped by the server).
  /// Answers the .NET envelope with the saved Id in Data2.
  Future<Map<String, dynamic>> saveFuelEntries(List<dynamic> rows, int comid) async {
    int? savedId;
    for (final raw in rows) {
      final r = Map<String, dynamic>.from(raw as Map);
      double n(String k) => _num(_pick(r, k));
      int? optInt(String k) {
        final v = int.tryParse('${_pick(r, k) ?? ''}');
        return v == null || v == 0 ? null : v;
      }

      final body = await _send(() => _dio.post<dynamic>('/api/fuel-entries', data: {
            'id': optInt('Id') ?? 0,
            'companyRefId': optInt('CompanyRefId') ?? comid,
            'truckRefId': optInt('TruckRefid'),
            'driverRefId': optInt('DriverRefId'),
            'employeeRefId': optInt('EmployeeRefId'),
            'saleDate': _dateOnly(_pick(r, 'SaleDate')),
            'aliter': n('Aliter'),
            'aAmount': n('AAmount'),
            'pliter': n('Pliter'),
            'gliter': n('Gliter'),
            'pRate': n('PRate'),
            'remarks': _pick(r, 'Remarks'),
            'filePath': _pick(r, 'FilePath'),
            'fStatus': optInt('FStatus') ?? 0,
          }));
      final data = body is Map ? body['Data1'] : null;
      savedId = data is Map ? int.tryParse('${data['id']}') : savedId;
    }
    return {'IsSuccess': true, 'StatusCode': 1, 'Message': 'FuelEntry Update Successfully..', 'Data1': '', 'Data2': savedId};
  }

  /// Soft delete; `mobile` keeps it to driver-app rows.
  Future<Map<String, dynamic>> deleteFuelEntry(int id, int comid, {required bool mobile}) async {
    await _send(() => _dio.delete<dynamic>('/api/fuel-entries/$id',
        queryParameters: {'companyRefId': comid, 'mobile': mobile}));
    return {'IsSuccess': true, 'StatusCode': 1, 'Message': 'FuelEntry Deleted Successfully..'};
  }

  Map<String, dynamic> _fuelRow(Map<String, dynamic> r, int comid) {
    final aliter = _num(_pick(r, 'aliter'));
    final pliter = _num(_pick(r, 'pliter'));
    final rate = _num(_pick(r, 'pRate'));
    final saleDate = _pick(r, 'saleDate')?.toString();
    final parsed = saleDate == null ? null : DateTime.tryParse(saleDate);
    double round2(double v) => (v * 100).roundToDouble() / 100;
    return {
      'Id': r['id'], 'CompanyRefId': comid, 'CNumberDisplay': _pick(r, 'cNumberDisplay'), 'CNumber': _pick(r, 'cNumber'),
      'SaleDate': parsed == null ? null : "${_ymd.format(parsed)}T00:00:00",
      'SSaleDate': parsed == null ? '' : _dmy.format(parsed),
      'TruckRefid': _pick(r, 'truckRefId'), 'TruckName': r['truckName'], 'DriverRefId': _pick(r, 'driverRefId'),
      'DriverName': r['driverName'], 'Remarks': r['remarks'], 'FilePath': r['filePath'], 'Active': 1,
      'FStatus': _pick(r, 'fStatus'), 'PRate': rate, 'Aliter': aliter, 'AAmount': _num(_pick(r, 'aAmount')),
      'Pliter': pliter, 'PAmount': _num(_pick(r, 'pAmount')), 'Gliter': _num(_pick(r, 'gliter')),
      'GAmount': _num(_pick(r, 'gAmount')),
      // patron minus actual, as the web computes it; patron minus GPS is the list's diff
      'DPliter': round2(pliter - aliter), 'DPAmount': round2(_num(_pick(r, 'pAmount')) - aliter * rate),
      'DGliter': _num(_pick(r, 'diffLiter')), 'DGAmount': _num(_pick(r, 'diffAmount')),
    };
  }

  // ---------------------------------------------------------------- helpers

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) => _getOr(path, query);

  Future<dynamic> _getOr(String path, Map<String, dynamic>? query, {bool emptyOn404 = false}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query), emptyOn404: emptyOn404);

  /// The decoded body; 204 (and 404 where the web API means "none") is an
  /// empty list; any other failure an [ApiFailure] with the server's message.
  Future<dynamic> _send(Future<Response<dynamic>> Function() call, {bool emptyOn404 = false}) async {
    try {
      final response = await call();
      if (response.statusCode == 204 || response.data == null || response.data == '') return const [];
      return response.data;
    } on DioException catch (e) {
      if (emptyOn404 && e.response?.statusCode == 404) return const [];
      throw JavaResponse.fromDio(e);
    }
  }

  /// The row list of any of the web API wrappers (`Data1`, `data1`, `data`, `items`) or a bare list.
  static List<Map<String, dynamic>> _rows(dynamic body) {
    if (body is List) return _list(body);
    if (body is Map) {
      for (final key in const ['Data1', 'data1', 'data']) {
        final v = body[key];
        if (v is List) return _list(v);
        if (v is Map && v['items'] is List) return _list(v['items']);
      }
    }
    return const [];
  }

  static List<Map<String, dynamic>> _list(dynamic v) =>
      v is List ? [for (final e in v) if (e is Map) Map<String, dynamic>.from(e)] : const [];

  /// A value by key, matched without case (Jackson's casing of names like cNumber varies).
  static dynamic _pick(Map<dynamic, dynamic> m, String key) {
    if (m.containsKey(key)) return m[key];
    final lower = key.toLowerCase();
    for (final e in m.entries) {
      if (e.key.toString().toLowerCase() == lower) return e.value;
    }
    return null;
  }

  static String _keyOf(Map<dynamic, dynamic> m, String key) {
    final lower = key.toLowerCase();
    for (final k in m.keys) {
      if (k.toString().toLowerCase() == lower) return k.toString();
    }
    return key;
  }

  static double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  static String? _dateOnly(dynamic v) {
    final text = v?.toString() ?? '';
    return text.length >= 10 ? text.substring(0, 10) : (text.isEmpty ? null : text);
  }

  /// A Java date (`2026-05-01` or a date-time) as .NET wrote it into a string property.
  static String? _invariantDate(dynamic v) {
    final d = v == null ? null : DateTime.tryParse(v.toString());
    return d == null ? null : _invariant.format(d);
  }

  /// The screen's ISO value (or null) as a Java LocalDate.
  static String? _isoDate(dynamic v) {
    final d = v == null ? null : DateTime.tryParse(v.toString());
    return d == null ? null : _ymd.format(d);
  }
}
