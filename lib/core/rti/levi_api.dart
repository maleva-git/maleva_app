import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Levi entries filed against an RTI, on the shared Java Levi API the web's RTI page
/// and Levi screen use (`FE/features/pass-entry/api/passEntryApi.ts:88-122`,
/// `FE/api/endpoints.ts` `LEVI_ENTRY`). Rows are the Java `PassEntryListItem`:
/// `id`, `cNumberDisplay`, `saleDate`, `truckRefId`, `truckName`, `driverRefId`,
/// `driverName`, `enterLink` (IN / OUT), `exitLink` (1ST / 2ND LINK), `amount`, `remarks`.
class LeviApi {
  LeviApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The RTI's entries: `GET /api/levi-entries/by-rti/{rtiId}?companyRefId` → `{items, entriesTotal}`.
  Future<({List<Map<String, dynamic>> items, double? entriesTotal})> byRti(int rtiId) async {
    final data = JsonRead.map(_unwrap(await _call(() =>
        _dio.get<dynamic>('/api/levi-entries/by-rti/$rtiId', queryParameters: {'companyRefId': companyId}))));
    final total = data['entriesTotal'];
    return (items: JsonRead.listOfMaps(data['items']), entriesTotal: total == null ? null : JsonRead.number(total));
  }

  /// The number the next new entry gets (`GET /api/levi-entries/next-no?companyRefId`).
  Future<String> nextNumber() async =>
      JsonRead.string(_unwrap(await _call(() => _dio.get<dynamic>('/api/levi-entries/next-no', queryParameters: {'companyRefId': companyId}))));

  /// Creates (no `id`) or updates an entry (`POST /api/levi-entries`); answers the saved entry.
  Future<Map<String, dynamic>> save(Map<String, dynamic> request) async =>
      JsonRead.map(_unwrap(await _call(() => _dio.post<dynamic>('/api/levi-entries', data: request))));

  /// `DELETE /api/levi-entries/{id}?companyRefId`.
  Future<void> delete(int id) async {
    await _call(() => _dio.delete<dynamic>('/api/levi-entries/$id', queryParameters: {'companyRefId': companyId}));
  }

  static dynamic _unwrap(dynamic payload) {
    if (payload is Map) {
      if (payload.containsKey('Data1')) return payload['Data1'];
      if (payload.containsKey('data1')) return payload['data1'];
      if (payload.containsKey('Data')) return payload['Data'];
    }
    return payload;
  }

  /// The web keeps the server's `Message` / `message`; otherwise the caller's fallback is shown.
  Future<dynamic> _call(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map ? JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']) : null;
      throw ApiFailure(message ?? '', statusCode: e.response?.statusCode);
    }
  }
}
