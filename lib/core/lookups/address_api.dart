import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Address pickers, from the shared Java address master (change
/// `address-lookups-on-shared-java-api`); both endpoints answer
/// `{ok, message, data, count}`:
/// - the address names, `GET /api/addresses/company/{companyId}/active` (the
///   port of .NET AddressApp/SelectDistinctAddress), distinct and sorted here
///   as before;
/// - the addresses whose name contains a keyword,
///   `GET /api/addresses/company/{companyId}/search?keyword` (the port of .NET
///   AddressApp/SelectAddress): `{id, name, address, phone, active}`, by name.
class AddressApi {
  AddressApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// The distinct address names, sorted without case.
  Future<List<String>> names() async {
    final rows = await _rows(() => _dio.get<dynamic>('/api/addresses/company/${_companyId()}/active'));
    return <String>{for (final r in rows) if (r['name'] != null) JsonRead.string(r['name'])}.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// The addresses whose name contains [keyword] ('' = all).
  Future<List<Map<String, dynamic>>> search([String keyword = '']) =>
      _rows(() => _dio.get<dynamic>('/api/addresses/company/${_companyId()}/search',
          queryParameters: {'keyword': keyword.trim()}));

  Future<List<Map<String, dynamic>>> _rows(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> response;
    try {
      response = await call();
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(body['ok'])) {
      throw ApiFailure(body is Map ? JsonRead.string(body['message']) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(body['data']);
  }
}
