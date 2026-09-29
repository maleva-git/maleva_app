import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The HTTP calls behind the IR screens: IRApp on the .NET API, plus the three
/// master lists the form's dropdowns need.
///
/// Returns raw JSON; turning it into entities is the repository's job. Every
/// failure leaves here as a [LegacyApiException].
class IrRemoteDataSource {
  IrRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> select(Map<String, dynamic> body) =>
      _envelope(ApiConstants.apiSelectIR, body: body);

  Future<Map<String, dynamic>> edit(int id, int companyId) =>
      _envelope(ApiConstants.apiEditIR, query: {'Id': id, 'Comid': companyId});

  Future<Map<String, dynamic>> insert(Map<String, dynamic> body) =>
      _envelope(ApiConstants.apiInsertIR, body: body);

  Future<void> delete(int id, int companyId, int userRefId) => _envelope(
        ApiConstants.apiDeleteIR,
        query: {'Id': id, 'Comid': companyId, 'UserRefId': userRefId},
      );

  Future<List<Map<String, dynamic>>> statuses(int companyId) async {
    final envelope = await _envelope(ApiConstants.apiSelectIRStatus, query: {'Comid': companyId});
    return JsonRead.listOfMaps(envelope['Data1']);
  }

  Future<List<Map<String, dynamic>>> departments() async {
    final envelope = await _envelope(ApiConstants.apiSelectIRDepartments);
    return JsonRead.listOfMaps(envelope['Data1']);
  }

  // The master list endpoints answer with the bare row list, not an envelope.

  Future<List<Map<String, dynamic>>> trucks(int companyId) =>
      _rows('${ApiConstants.apiGetTruckList}$companyId&type=');

  Future<List<Map<String, dynamic>>> drivers(int companyId) =>
      _rows('${ApiConstants.apiGetDriverList}$companyId&type=');

  Future<List<Map<String, dynamic>>> employees(int companyId) =>
      _rows('${ApiConstants.apiSelectEmployee}$companyId&type=&type1=');

  Future<Map<String, dynamic>> _envelope(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: body ?? const <String, dynamic>{},
        queryParameters: query,
      );
      return LegacyResponse.envelope(response.data);
    } on DioException catch (error) {
      throw LegacyResponse.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> _rows(String url) async {
    try {
      final response = await _dio.post<dynamic>(url, data: const <String, dynamic>{});
      final data = response.data;
      return JsonRead.listOfMaps(data is Map ? data['Data1'] : data);
    } on DioException catch (error) {
      throw LegacyResponse.fromDio(error);
    }
  }
}
