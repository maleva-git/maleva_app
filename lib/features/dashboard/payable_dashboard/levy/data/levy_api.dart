import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';

/// The levy form's calls (change `payable-levy-form`): the same Java endpoints as the web levi entry form
/// (`features/pass-entry/api/passEntryApi.ts`, `api/truckApi.ts` getTruckCombo, `api/driverApi.ts` getDriverCombo).
/// All answer `ApiResponse` `{IsSuccess, Data1}`.
class LevyApi {
  LevyApi(this._dio, {required this.companyId});

  final Dio _dio;
  final int companyId;

  static const _base = '/api/levi-entries';

  /// The number a new levy will get (e.g. `LE000000242`).
  Future<String> nextNumber() async => JsonRead.string(await _get('$_base/next-no', {'companyRefId': companyId}));

  /// RTI choices: `RtiOptionDto` `{id, rtiNumber}`.
  Future<List<Option>> rtiOptions() async => [
        for (final m in JsonRead.listOfMaps(await _get('$_base/rti-options', {'companyRefId': companyId})))
          if (JsonRead.integer(JsonRead.field(m, 'id')) > 0)
            Option(JsonRead.integer(JsonRead.field(m, 'id')), pick(m, const ['rtiNumber'])),
      ];

  /// The web's truck list (`TruckMasterDto`): name = account name or truck name.
  Future<List<Option>> trucks() async => [
        for (final m in JsonRead.listOfMaps(await _get(
            '/api/truck-masters/alltruckdetatilcombo', {'companyId': companyId, 'keyword': '', 'column': 'All'})))
          if (JsonRead.integer(JsonRead.field(m, 'id')) > 0 &&
              pick(m, const ['accountName', 'truckName', 'truckNumber']).isNotEmpty)
            Option(JsonRead.integer(JsonRead.field(m, 'id')), pick(m, const ['accountName', 'truckName', 'truckNumber'])),
      ];

  /// The web's driver list (`DriverMasterDto`): name = account name, else "driver-mobile", else driver name;
  /// active drivers of this company only, by name (web `filterDrivers`).
  Future<List<Option>> drivers() async {
    final out = <Option>[];
    for (final m in JsonRead.listOfMaps(
        await _get('/api/driver-masters/selectalldriverDetails', {'companyId': companyId}))) {
      final id = JsonRead.integer(JsonRead.field(m, 'id'));
      final driver = pick(m, const ['driverName']);
      final mobile = pick(m, const ['mobileNo']);
      final account = pick(m, const ['accountName']);
      final name = account.isNotEmpty ? account : (driver.isNotEmpty && mobile.isNotEmpty ? '$driver-$mobile' : driver);
      final company = JsonRead.integer(JsonRead.field(m, 'companyRefId'));
      final active = JsonRead.field(m, 'active');
      final isActive = active == null || active == true || '$active' == '1' || '$active'.toLowerCase() == 'true';
      if (id > 0 && name.isNotEmpty && isActive && (company == 0 || company == companyId)) out.add(Option(id, name));
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  /// One saved levy (`PassEntryDetailDto`).
  Future<Map<String, dynamic>> load(int id) async {
    final m = JsonRead.map(await _get('$_base/$id', {'companyRefId': companyId}));
    if (m.isEmpty) throw const ApiFailure('Levy not found');
    return m;
  }

  /// Saves (no `id` = new) and answers the saved levy's id and number.
  Future<({int id, String number})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>(_base, data: body, options: Options(headers: {'Comid': companyId}))).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final d = JsonRead.map(JavaResponse.data(res));
    final id = JsonRead.integer(JsonRead.field(d, 'id'));
    if (id <= 0) throw const ApiFailure('The levy was not saved');
    return (id: id, number: pick(d, const ['cNumberDisplay', 'cnumberDisplay']));
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return JavaResponse.data(
          (await _dio.get<dynamic>(path, queryParameters: query, options: Options(headers: {'Comid': companyId}))).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
