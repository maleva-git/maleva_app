import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Trucks, from the shared Java truck master (change
/// `truck-lookups-on-shared-java-api`):
/// - the picker list, `GET /api/truck-combo` (the port of .NET TruckApp/GetTruck):
///   `{Id, AccountName}` rows (the Java model names them so) in a
///   `{isSuccess, data1}` wrapper;
/// - one truck, `GET /api/truck-masters/search?column=Id` (was .NET
///   TruckApp/SelectTruck): the Java `TruckMasterDto` (`truckName`,
///   `truckNumber`, `truckType`, `rotexMyExp`, `insuranceExp`, ... dates
///   `yyyy-MM-dd`);
/// - its save, `POST /api/truck-masters/process` (was .NET TruckApp/InsertTruck),
///   which takes the whole truck.
/// A refusal is an [ApiFailure] with the server's message.
class TruckApi {
  TruckApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// The active trucks for a picker (optionally of a [type]).
  Future<List<Map<String, dynamic>>> combo({String? type}) async {
    final body = await _call(() => _dio.get<dynamic>('/api/truck-combo', queryParameters: {
          'companyId': _companyId(),
          if (type != null && type.isNotEmpty) 'type': type,
        }));
    if (body is! Map || !JsonRead.boolean(JsonRead.field(body, 'isSuccess'))) {
      throw ApiFailure(body is Map ? JsonRead.string(JsonRead.field(body, 'message')) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(JsonRead.field(body, 'data1'));
  }

  /// The truck [id] as the Java master stores it, or null.
  Future<Map<String, dynamic>?> byId(int id) async {
    final data = JsonRead.map(JavaResponse.data(await _call(() => _dio.get<dynamic>('/api/truck-masters/search',
        queryParameters: {'companyId': _companyId(), 'startIndex': 0, 'pageCount': 0, 'keyword': '$id', 'column': 'Id'}))));
    final items = JsonRead.listOfMaps(data['items']);
    return items.isEmpty ? null : items.first;
  }

  /// Saves [changes] (Java field names) over truck [id] as stored: the web
  /// API saves a whole truck, so the rest of it is kept.
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> changes) async {
    final truck = await byId(id);
    if (truck == null) throw ApiFailure('Truck $id was not found');
    final body = Map<String, dynamic>.from(truck);
    changes.forEach((key, value) => body[_keyOf(truck, key)] = value);
    return JsonRead.map(await _call(() => _dio.post<dynamic>('/api/truck-masters/process',
        queryParameters: {'companyId': _companyId()}, data: body)));
  }

  /// The key as the stored truck spells it (Jackson writes some Lombok names in lower case).
  static String _keyOf(Map<String, dynamic> truck, String key) {
    if (truck.containsKey(key)) return key;
    final lower = key.toLowerCase();
    return truck.keys.firstWhere((k) => k.toLowerCase() == lower, orElse: () => key);
  }

  Future<dynamic> _call(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is String && body.trim().isNotEmpty) {
        throw ApiFailure(body.trim().replaceFirst(RegExp(r'^Error:\s*'), ''), statusCode: e.response?.statusCode);
      }
      throw JavaResponse.fromDio(e);
    }
  }
}
