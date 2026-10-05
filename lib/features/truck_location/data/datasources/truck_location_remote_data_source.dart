import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The HTTP calls behind the Truck Location Board: the Java
/// `/api/truck-locations` API the web board uses, through `JavaApiClient`'s
/// Dio (session token, refresh on 401).
///
/// Returns raw JSON; turning it into entities is the repository's job. Every
/// failure leaves here as an `ApiFailure` with the server's message.
class TruckLocationRemoteDataSource {
  TruckLocationRemoteDataSource(this._dio);
  final Dio _dio;

  /// The week containing `date`.
  Future<Map<String, dynamic>> week(Map<String, dynamic> query) async => JsonRead.map(
      await _data(() => _dio.get<dynamic>('/api/truck-locations/week', queryParameters: query)));

  /// Save All; answers the saved week.
  Future<Map<String, dynamic>> saveWeek(Map<String, dynamic> body) async =>
      JsonRead.map(await _data(() => _dio.post<dynamic>('/api/truck-locations/week', data: body)));

  Future<void> saveOrder(Map<String, dynamic> body) =>
      _data(() => _dio.post<dynamic>('/api/truck-locations/order', data: body));

  Future<dynamic> _data(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (error) {
      throw JavaResponse.fromDio(error);
    }
  }
}
