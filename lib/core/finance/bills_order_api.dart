import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Bills orders, from the shared Java `/api/bills-order` (was .NET
/// `BIllorderApp/SelectBillsOrderApp`, change `billorder-on-shared-java-api`).
/// This endpoint answers `{ok, data}` / `{ok: false, message}`, not the usual
/// `ApiResponse`; it is read as it is. A refusal is an [ApiFailure].
class BillsOrderApi {
  BillsOrderApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The pending bills orders (not locked, PStatus 0) with a sale date in the
  /// period, dates `yyyy-MM-dd`: `id`, `pstatus`, `billNoDisplay`,
  /// `billNoDisplay1` (the job), `supplierName`, `employeeName`, `invoiceNo`,
  /// `netAmt`, `truckName`, `driverName`, ...
  Future<List<Map<String, dynamic>>> pending({required String fromDate, required String toDate}) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>('/api/bills-order/select-bills-order', queryParameters: {
        'comid': companyId,
        'fromdate': fromDate,
        'todate': toDate,
        'status': 'Pending',
      });
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final body = response.data;
    if (body is! Map || !JsonRead.boolean(body['ok'])) {
      throw ApiFailure(body is Map ? JsonRead.string(body['message']) : 'Unexpected response from server');
    }
    return JsonRead.listOfMaps(JsonRead.map(body['data'])['billsOrderMaster']);
  }
}
