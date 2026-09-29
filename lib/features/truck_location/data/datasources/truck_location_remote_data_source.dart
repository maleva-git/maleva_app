import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The HTTP calls behind the Truck Location Board: TruckLocationApp on the
/// .NET API, all POST with the model in the JSON body.
///
/// Returns raw JSON; turning it into entities is the repository's job. Every
/// failure leaves here as a [LegacyApiException] carrying the server's own
/// message (the endpoints answer 400 with the envelope in the body).
class TruckLocationRemoteDataSource {
  TruckLocationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> selectWeek(Map<String, dynamic> body) async {
    final envelope = await _envelope(ApiConstants.apiTruckLocationSelectWeek, body);
    return JsonRead.map(envelope['Data1']);
  }

  Future<Map<String, dynamic>> saveWeek(Map<String, dynamic> body) async {
    final envelope = await _envelope(ApiConstants.apiTruckLocationSaveWeek, body);
    return JsonRead.map(envelope['Data1']);
  }

  Future<void> saveOrder(Map<String, dynamic> body) =>
      _envelope(ApiConstants.apiTruckLocationSaveOrder, body);

  Future<Map<String, dynamic>> _envelope(String url, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<dynamic>(url, data: body);
      return LegacyResponse.envelope(response.data);
    } on DioException catch (error) {
      throw LegacyResponse.fromDio(error);
    }
  }
}
