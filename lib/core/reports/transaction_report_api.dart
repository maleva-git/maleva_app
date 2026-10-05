import 'package:dio/dio.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The reports the app took from .NET `TransactionReportApp`, now on the shared
/// Java API (change `transaction-reports-on-shared-java-api`). Answers the Java
/// rows as they are; a refusal is an [ApiFailure] with the server's message.
/// Dates are `yyyy-MM-dd`.
class TransactionReportApi {
  TransactionReportApi(this._dio, {required int Function() companyId, String javaBaseUrl = AppConfig.javaBaseUrl})
      : _companyId = companyId,
        _javaBaseUrl = javaBaseUrl;

  final Dio _dio;
  final int Function() _companyId;
  final String _javaBaseUrl;

  int get companyId => _companyId();

  /// The Driver RTI detailed report's job lines
  /// (`/api/rti-masters/driver-report/detailed/rows`): `rtiNo`, `rtiDate`,
  /// `jobNo`, `driverName`, `truckName`, `truckType`, `customerName`, `origin`,
  /// `destination`, `place`, `quantity`, `pickupDate`, `deliveryDate`
  /// (`dd/MM/yyyy HH:mm:ss`, '' for none), `enterLink`, `exitLink`, `remarks`,
  /// `comments`, `salary` and the RTI's allowances and `amount` (on its first
  /// line only). For a driver token the server keeps the driver's own.
  Future<List<Map<String, dynamic>>> driverJobs({required String fromDate, required String toDate}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/rti-masters/driver-report/detailed/rows',
          queryParameters: {'companyId': companyId, 'fromDate': fromDate, 'toDate': toDate})));

  /// Customers owing for the period (`/api/customer-reports/period-balance/rows`):
  /// `id`, `customerName`, `mobileNo`, ..., `balance` and `billAmount` (the
  /// balance in the customer's currency), by name.
  Future<List<Map<String, dynamic>>> customerBalances({required String fromDate, required String toDate}) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/customer-reports/period-balance/rows',
          queryParameters: {'companyId': companyId, 'fromDate': fromDate, 'toDate': toDate})));

  /// The Pre Alert report PDF's link (`/api/transaction/pre-alert-report/ticket`).
  /// [etaType] with [eta]: 1 the off vessel's ETA, 2 the loading vessel's, other
  /// either; [discussion]: the pickup date; neither: the job date. [port] and
  /// [vessel] are matched as text. No jobs is an [ApiFailure] "No Record Found !!!".
  Future<String> preAlertUrl({
    required String fromDate,
    required String toDate,
    int customerId = 0,
    int jobTypeId = 0,
    String? port,
    String? vessel,
    bool discussion = false,
    bool eta = false,
    int etaType = 0,
    bool deliveryDone = false,
    bool consolidated = false,
  }) async {
    final data = JsonRead.map(await _send(() => _dio.get<dynamic>('/api/transaction/pre-alert-report/ticket',
        queryParameters: {
          'companyId': companyId,
          'fromDate': fromDate,
          'toDate': toDate,
          if (customerId > 0) 'customerId': customerId,
          if (jobTypeId > 0) 'jobTypeId': jobTypeId,
          if (port != null && port.isNotEmpty) 'port': port,
          if (vessel != null && vessel.isNotEmpty) 'vessel': vessel,
          'discussion': discussion,
          'eta': eta,
          if (eta) 'etaType': etaType,
          'deliveryDone': deliveryDone,
          'consolidated': consolidated,
        })));
    final url = JsonRead.string(JsonRead.field(data, 'Url'));
    if (url.isEmpty) throw const ApiFailure('The Pre Alert report could not be prepared');
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
