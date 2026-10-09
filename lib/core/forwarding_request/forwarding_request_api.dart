import 'package:dio/dio.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Forwarding requests on the shared Java API (`/api/forwarding-requests`, backend changes
/// `forwarding-requests` and `forwarding-request-followup`; the same endpoints React uses).
/// The company and the acting employee come from the token, so nothing is sent for them.
/// Each failure arrives as an [ApiFailure] with the server's own message.
class ForwardingRequestApi {
  ForwardingRequestApi(this._dio);

  final Dio _dio;

  static const _base = '/api/forwarding-requests';

  /// Customer Service's request: one row per form type, all with the same estimate.
  Future<List<ForwardingRequest>> create({
    required int saleOrderId,
    required List<String> formTypes,
    required DateTime estimatedDate,
    String remarks = '',
  }) =>
      _send(() => _dio.post<dynamic>(_base, data: {
            'saleOrderId': saleOrderId,
            'formTypes': formTypes,
            'estimatedDate': toJavaDateTime(estimatedDate),
            'remarks': remarks.trim().isEmpty ? null : remarks.trim(),
          })).then(_list);

  /// The job's requests, cancelled ones included, newest estimate first.
  Future<List<ForwardingRequest>> forSaleOrder(int saleOrderId) =>
      _send(() => _dio.get<dynamic>('$_base/sale-order/$saleOrderId')).then(_list);

  /// The planning list (or, with `mine`, the caller's own requests).
  Future<List<ForwardingRequest>> search(ForwardingRequestFilter filter) =>
      _send(() => _dio.post<dynamic>('$_base/search', data: filter.toJava())).then(_list);

  /// One row's Save: the five ticks, their references and the seal people together.
  Future<ForwardingRequest> saveTicks(int id, ForwardingRequestTicks ticks) =>
      _send(() => _dio.put<dynamic>('$_base/$id/ticks', data: ticks.toJava()))
          .then((d) => ForwardingRequest.fromJava(JsonRead.map(d)));

  /// Soft cancel; the row stays in history.
  Future<ForwardingRequest> cancel(int id) =>
      _send(() => _dio.put<dynamic>('$_base/$id/cancel')).then((d) => ForwardingRequest.fromJava(JsonRead.map(d)));

  static List<ForwardingRequest> _list(dynamic d) => JsonRead.listOfMaps(d).map(ForwardingRequest.fromJava).toList();

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
