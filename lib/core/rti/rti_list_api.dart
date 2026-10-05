import 'package:dio/dio.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The RTI list as the Java `/api/rti-masters/with-jobs` answers it (decision Q-RTI-LIST,
/// change `planning-rti-phone-tablet`), without the old .NET view models: each row is the Java
/// `RtiWithJobs` (`id`, `rtiNo`, `rtiNoDisplay`, `rtiDate`, `driverRefId`, `driverName`,
/// `truckRefId`, `truckName`, `employeeRefId`, `remarks`, `amount`, `jobs`) and each job the Java
/// `RtiJob` (`id`, `saleOrderMasterRefId`, `jobNo`, `jobDate`, `customerName`, ...).
/// A refusal is an [ApiFailure] with the server's message. A driver token sees its own RTIs only.
class RtiListApi {
  RtiListApi(this._dio, {required int Function() companyId, String javaBaseUrl = AppConfig.javaBaseUrl})
      : _companyId = companyId,
        _javaBaseUrl = javaBaseUrl;

  final Dio _dio;
  final int Function() _companyId;
  final String _javaBaseUrl;

  int get companyId => _companyId();

  /// The RTIs of the filters. A [search] RTI number (exact `CNumberDisplay`) replaces the other
  /// filters on the server; 0 means any. Dates are `yyyy-MM-dd`.
  Future<List<Map<String, dynamic>>> withJobs({
    required String fromDate,
    required String toDate,
    int driverId = 0,
    int truckId = 0,
    int employeeId = 0,
    String search = '',
  }) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/rti-masters/with-jobs', queryParameters: {
            'companyId': companyId,
            'fromDate': fromDate,
            'toDate': toDate,
            if (driverId != 0) 'driverId': driverId,
            if (truckId != 0) 'truckId': truckId,
            if (employeeId != 0) 'employeeId': employeeId,
            if (search.trim().isNotEmpty) 'search': search.trim(),
          })));

  /// The RTI report's full URL (`GET /api/rti-masters/{id}/report-ticket?companyId` → `Data1.Url`,
  /// `R/api/rtiReportApi.ts:20-29`), or '' when the server sent none.
  Future<String> reportUrl(int rtiId) async {
    final data = JsonRead.map(await _send(() =>
        _dio.get<dynamic>('/api/rti-masters/$rtiId/report-ticket', queryParameters: {'companyId': companyId})));
    final url = JsonRead.string(JsonRead.field(data, 'Url')).trim();
    if (url.isEmpty) return '';
    return url.startsWith('http') ? url : '$_javaBaseUrl$url';
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
