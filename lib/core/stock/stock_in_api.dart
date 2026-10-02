import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Stock-in entry, from the shared Java `/api/stock-ins` (ported from .NET
/// StockAppController; change `stock-in-on-shared-java-api`). Answers the Java
/// data as it is (camelCase fields); a refusal or an unknown stock-in is an
/// [ApiFailure] with the server's message.
class StockInApi {
  StockInApi(this._dio);

  final Dio _dio;

  /// The number the next new stock-in will take, e.g. `STI000000124`.
  Future<String> nextNumber(int comid) async =>
      JsonRead.string(await _send(() => _dio.get<dynamic>('/api/stock-ins/next-number', queryParameters: {'companyId': comid})));

  /// The ids of the jobs that already have a stock-in.
  Future<List<int>> stockJobs(int comid) async {
    final data = await _send(() => _dio.get<dynamic>('/api/stock-ins/jobs', queryParameters: {'companyId': comid}));
    return data is List ? [for (final v in data) JsonRead.integer(v)] : const [];
  }

  /// Active jobs (`id`, `cNumberDisplay`, `quantity`, `jobMasterRefId`,
  /// `jStatus`, `sSaleDate`, `customerName`, `loadingVesselName`,
  /// `offVesselName`); one job when [saleOrderId] is given.
  Future<List<Map<String, dynamic>>> saleOrders(int comid, {int saleOrderId = 0}) async => JsonRead.listOfMaps(
      await _send(() => _dio.get<dynamic>('/api/stock-ins/sale-orders',
          queryParameters: {'companyId': comid, 'id': saleOrderId})));

  /// The stock-in a label belongs to (`id`, `saleOrderMasterRefId`,
  /// `numberOfPackages`, `portMasterRefId`, `portName`, `barcodeLabelDisplay`,
  /// `status`, ...). A printed package label ("JOB-1/5") is found too.
  Future<Map<String, dynamic>> byLabel(int comid, String label) async => JsonRead.map(await _send(() =>
      _dio.get<dynamic>('/api/stock-ins/entries/by-label', queryParameters: {'companyId': comid, 'label': label})));

  /// Saves the stock-in rows (camelCase, see `StockInEntryDtos.SaveRow`);
  /// answers the saved stock-in's id.
  Future<int> save(int comid, List<Map<String, dynamic>> rows) async => JsonRead.integer(await _send(() =>
      _dio.post<dynamic>('/api/stock-ins/entries', queryParameters: {'companyId': comid}, data: rows)));

  /// The cargo reached warehouse [portId]; the job takes [statusId] (when > 0).
  Future<void> arrival(int comid, int stockId,
      {required int statusId, required int portId, List<String> imageUrls = const []}) async {
    await _send(() => _dio.put<dynamic>('/api/stock-ins/entries/$stockId/arrival',
        queryParameters: {'companyId': comid},
        data: {'statusId': statusId, 'portId': portId, 'imageUrls': imageUrls}));
  }

  /// The cargo moved to warehouse [portId].
  Future<void> transfer(int comid, int stockId, int portId) async {
    await _send(() => _dio.put<dynamic>('/api/stock-ins/entries/$stockId/transfer',
        queryParameters: {'companyId': comid}, data: {'portId': portId}));
  }

  /// What the labels carry: `numberOfPackages`, `jobNo`, `sSaleDate`, `vesselName`, ...
  Future<Map<String, dynamic>> label(int comid, int stockId) async => JsonRead.map(await _send(() =>
      _dio.get<dynamic>('/api/stock-ins/entries/$stockId/label', queryParameters: {'companyId': comid})));

  /// Active warehouses (`id`, `portName`).
  Future<List<Map<String, dynamic>>> warehouses(int comid) async => JsonRead.listOfMaps(
      await _send(() => _dio.get<dynamic>('/api/stock-ins/warehouses', queryParameters: {'companyId': comid})));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
