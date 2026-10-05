import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// Petty cash, from the shared Java `/api/petty-cash-masters` (was .NET
/// `BIllorderApp/SelectpetticashApp`, change `billorder-on-shared-java-api`).
/// Answers the Java data as it is; a refusal is an [ApiFailure].
class PettyCashApi {
  PettyCashApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// The petty cash of the period (dates `yyyy-MM-dd`, both whole days):
  /// `pettyCashMaster` (`id`, `cnumberDisplay`, `spettyCashDate` dd/MM/yyyy,
  /// `employeeName`, `paymentStatus`, `amount`, ...) and `pettyCashDetails`
  /// (`pettyCashMasterRefId`, `items`, `notes`, `amount`, ...).
  Future<Map<String, dynamic>> search({required String fromDate, required String toDate}) async =>
      JsonRead.map(await _send(() => _dio.post<dynamic>('/api/petty-cash-masters/search',
          queryParameters: {'companyId': companyId}, data: {'fromDate': fromDate, 'toDate': toDate})));

  /// One petty cash with its lines (`pettyCashDetails`).
  Future<Map<String, dynamic>> edit(int id) async =>
      JsonRead.map(await _send(() => _dio.get<dynamic>('/api/petty-cash-masters/edit',
          queryParameters: {'companyId': companyId, 'id': id})));

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
