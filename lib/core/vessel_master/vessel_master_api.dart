import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// The vessel master on the shared Java API (backend change vessel-master-and-ptp-schedule, the
/// endpoints React uses): suggestions while typing, the close-spelling check and the sale order's
/// vessel links. Company and caller come from the token; answers are `ApiResponse` data, read as
/// Java sends them. A refusal is an `ApiFailure` with the server's message.
class VesselMasterApi {
  VesselMasterApi(this._dio);

  final Dio _dio;

  /// `GET /api/vessel-masters/suggest` for [q] (at least 2 characters), the [leg] (`LOADING` / `OFF`)
  /// and its [port] (may be empty).
  Future<List<VesselSuggestion>> suggest(String q, {required String leg, String port = ''}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/vessel-masters/suggest',
              queryParameters: {'q': q, 'leg': leg, 'port': port})))
          .map(VesselSuggestion.fromJava)
          .toList();

  /// `GET /api/vessel-masters/similar`: whether [name] is a known vessel (SAME), close to one (CLOSE) or new (NONE).
  Future<SimilarVessel> similar(String name) async => SimilarVessel.fromJava(JsonRead.map(
      await _send(() => _dio.get<dynamic>('/api/vessel-masters/similar', queryParameters: {'name': name}))));

  /// `PUT /api/sale-orders/{id}/vessel-links`: the legs sent are linked (an empty name removes that leg's
  /// link; a leg not sent stays as it is). Answers the legs now linked.
  Future<List<VesselLink>> saveLinks(int saleOrderId, List<VesselLinkRequest> legs) async =>
      JsonRead.listOfMaps(await _send(() => _dio.put<dynamic>('/api/sale-orders/$saleOrderId/vessel-links',
              data: {'legs': [for (final l in legs) l.toJava()]})))
          .map(VesselLink.fromJava)
          .toList();

  /// `GET /api/sale-orders/{id}/vessel-links`: the job's legs as linked now, each with its PTP call's
  /// current times (the form warns before saving when a typed ETA differs from them).
  Future<List<VesselLink>> links(int saleOrderId) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/sale-orders/$saleOrderId/vessel-links')))
          .map(VesselLink.fromJava)
          .toList();

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
