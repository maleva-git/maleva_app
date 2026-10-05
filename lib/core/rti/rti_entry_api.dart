import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The RTI entry form (Add / Edit RTI) on the shared Java RTI API that React's
/// RTI page uses (was the .NET web routes `/RTI/InsertRTI`, `EditRTI`,
/// `ReviseRTI`, `DeleteRTI`, `MaxRTINo`, `SearchJobNo`; change
/// `rti-entry-on-shared-java-api`). The server numbers a new RTI. Each call
/// sends the session company, so another company's RTI reads as not found. A
/// refusal is an [ApiFailure] with the server's message.
///
/// Java field names: the master has `id`, `cnumberDisplay`, `saleDate`,
/// `driverRefId`, `truckRefId`, `elink` / `exLink`, `sleeping`, `exitYN`,
/// `emptyDeliveryYN`, `pickup`, `addDrop`, `manpw`, `pckHandling`,
/// `punctuality`, `documentSub`, `destination`, `sealBy`, `breakSealBy`,
/// `remarks`, `comments`, `amount`, ...; a line has `id`,
/// `saleOrderMasterRefId`, `jobNo`, `jobDate`, `customerName`, `salary`,
/// `ppic`, `dpic`, `pwdType`, `originD`, `destinationD`, `pickupDateD`,
/// `deliveryDateD`, `pickupAddressD`, `deliveryAddressD`, ...
class RtiEntryApi {
  RtiEntryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  static final DateFormat _apiTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// A date for the API (`yyyy-MM-ddTHH:mm:ss`), or null.
  static String? apiTime(DateTime? at) => at == null ? null : _apiTime.format(at);

  /// The number the next RTI will most likely get (`RTI000008652`), shown
  /// before saving as React does; the server assigns the real one on save.
  Future<String> nextNumberPreview() async {
    final rows = JsonRead.listOfMaps(await _bare(() => _dio.get<dynamic>('/api/sequence-masters/company/$companyId')));
    final row = rows.where((r) => JsonRead.string(r['sequenceName']).toLowerCase() == 'rtimaster').toList();
    final next = (row.isEmpty ? 0 : JsonRead.integer(row.first['sequenceNo'])) + 1;
    return 'RTI${next.toString().padLeft(9, '0')}';
  }

  /// One RTI with its job lines (each with its job number, date and customer).
  Future<({Map<String, dynamic> master, List<Map<String, dynamic>> lines})> load(int id) async {
    final master = JsonRead.map(await _bare(() => _dio.get<dynamic>('/api/rti-masters/$id',
        queryParameters: {'companyId': companyId})));
    final lines = JsonRead.listOfMaps(await _bare(() => _dio.get<dynamic>('/api/rti-details/rti-master/$id')));
    return (master: master, lines: lines);
  }

  /// The RTI refreshed from its sales orders (dates, origin and destination of
  /// each job), as .NET ReviseRTI; nothing is saved until [save].
  Future<({Map<String, dynamic> master, List<Map<String, dynamic>> lines})> revise(int id) async {
    final master = JsonRead.map(await _send(() => _dio.get<dynamic>('/api/rti-masters/$id/revise',
        queryParameters: {'companyRefId': companyId})));
    return (master: master, lines: JsonRead.listOfMaps(master['rtiDetails']));
  }

  /// The company's jobs with exactly this number: `id`, `jobNo`, `jobDate`, `customerName`.
  Future<List<Map<String, dynamic>>> searchJob(String jobNo) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/rti-masters/company/$companyId/job-search',
          queryParameters: {'jobNo': jobNo})));

  /// Adds (no `id`) or updates the RTI with its [master] fields and job
  /// [lines]. Answers the saved RTI (`id`, `cnumberDisplay`, ...).
  Future<Map<String, dynamic>> save(Map<String, dynamic> master, List<Map<String, dynamic>> lines) async {
    final id = JsonRead.integer(master['id']);
    final body = {...master, 'companyRefId': companyId, 'rtiDetails': lines};
    if (id > 0) {
      return JsonRead.map(await _bare(() => _dio.put<dynamic>('/api/rti-masters/$id',
          queryParameters: {'companyId': companyId}, data: body)));
    }
    body.remove('id');
    return JsonRead.map(await _bare(() => _dio.post<dynamic>('/api/rti-masters', data: body)));
  }

  /// Deletes the RTI (the server marks it inactive).
  Future<void> delete(int id) async {
    await _bare(() => _dio.delete<dynamic>('/api/rti-masters/$id', queryParameters: {'companyId': companyId}));
  }

  /// The allowance amounts and the total, by React's rule (RTICalculationService):
  /// the jobs' salaries, sleeping 50, an empty pickup / empty delivery 80 or 50
  /// (code 1 = EMPTY 80, 2 = EMPTY 50), manpower 50 (1) or 100 (2), pickups and
  /// drops 30 each.
  static Map<String, num> amounts({
    required Iterable<num> salaries,
    required bool sleeping,
    required int exitYN,
    required int emptyDeliveryYN,
    required int manpower,
    bool pickup = false,
    int pickupCount = 0,
    bool drop = false,
    int dropCount = 0,
  }) {
    num empty(int code) => code == 1 ? 80 : (code == 2 ? 50 : 0);
    final result = <String, num>{
      'sleepingAmount': sleeping ? 50 : 0,
      'exitAmount': empty(exitYN),
      'emptyDeliveryAmount': empty(emptyDeliveryYN),
      'manpwAmount': manpower == 1 ? 50 : (manpower == 2 ? 100 : 0),
      'pickupAmount': pickup ? pickupCount * 30 : 0,
      'dropAmount': drop ? dropCount * 30 : 0,
    };
    final total = salaries.fold<num>(0, (a, b) => a + b) + result.values.fold<num>(0, (a, b) => a + b);
    result['amount'] = double.parse(total.toStringAsFixed(2));
    return result;
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  /// These RTI endpoints answer the DTO itself (or a plain-text error), not an ApiResponse.
  Future<dynamic> _bare(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  static ApiFailure _failure(DioException e) {
    final body = e.response?.data;
    if (body is String && body.trim().isNotEmpty) {
      return ApiFailure(body.trim(), statusCode: e.response?.statusCode);
    }
    return JavaResponse.fromDio(e);
  }
}
