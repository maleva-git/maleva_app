import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// RTIs as the screens list them: the masters and, flattened, their jobs.
class RtiList {
  const RtiList(this.masters, this.details);

  static const empty = RtiList([], []);

  final List<RTIMasterViewModel> masters;
  final List<RTIDetailsViewModel> details;
}

/// RTIs, from the shared Java RTI APIs (the .NET RTIApp is no longer called for
/// these, change `rti-on-shared-java-api`). Answers the Java data as it is;
/// a refusal is an [ApiFailure] with the server's message. For a driver token
/// the server keeps the list, the print and the job status to the driver's
/// own RTIs.
class RtiApi {
  RtiApi(this._dio, {required int Function() companyId, String javaBaseUrl = AppConfig.javaBaseUrl})
      : _companyId = companyId,
        _javaBaseUrl = javaBaseUrl;

  final Dio _dio;
  final int Function() _companyId;
  final String _javaBaseUrl;

  int get companyId => _companyId();

  /// RTIs with their driver and truck names and their jobs
  /// (`/api/rti-masters/with-jobs`). A [search] RTI number replaces the other
  /// filters; 0 means any. Dates are `yyyy-MM-dd`.
  Future<RtiList> withJobs({
    String fromDate = '',
    String toDate = '',
    int driverId = 0,
    int truckId = 0,
    int employeeId = 0,
    String search = '',
  }) async {
    final rows = JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/rti-masters/with-jobs', queryParameters: {
          'companyId': companyId,
          if (_dateOnly(fromDate) != null) 'fromDate': _dateOnly(fromDate),
          if (_dateOnly(toDate) != null) 'toDate': _dateOnly(toDate),
          if (driverId != 0) 'driverId': driverId,
          if (truckId != 0) 'truckId': truckId,
          if (employeeId != 0) 'employeeId': employeeId,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        })));
    return RtiList(
      [for (final r in rows) RTIMasterViewModel.fromJava(r)],
      [for (final r in rows) for (final j in JsonRead.listOfMaps(r['jobs'])) RTIDetailsViewModel.fromJava(j)],
    );
  }

  /// The RTI report PDF's full URL: `/api/rti-masters/{id}/report-ticket`
  /// prepares it; the answered link needs no token and expires in minutes.
  Future<String> reportUrl(int rtiId) async {
    final data = JsonRead.map(await _send(() =>
        _dio.get<dynamic>('/api/rti-masters/$rtiId/report-ticket', queryParameters: {'companyId': companyId})));
    final url = JsonRead.string(JsonRead.field(data, 'Url'));
    if (url.isEmpty) throw const ApiFailure('The RTI report could not be prepared');
    return url.startsWith('http') ? url : '$_javaBaseUrl$url';
  }

  /// Every RTI number of the company (`/api/rti-masters/company/{id}`, a bare
  /// list): `{Id, CNumber}` pairs, as the job number pickers keep them.
  Future<List<Map<String, dynamic>>> numbers() async {
    try {
      final response = await _dio.get<dynamic>('/api/rti-masters/company/$companyId');
      return [
        for (final r in JsonRead.listOfMaps(response.data))
          {'CNumber': JsonRead.string(JsonRead.field(r, 'cNumberDisplay')), 'Id': JsonRead.integer(r['id'])},
      ];
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// A job's RTI status from the driver's screen: the server sets it, then
  /// emails and WhatsApps the transport staff with the photos.
  Future<void> updateJobStatus(int saleOrderId, String statusName, List<String> imageUrls) async {
    await _send(() => _dio.post<dynamic>('/api/rti-masters/jobs/$saleOrderId/status',
        queryParameters: {'companyId': companyId}, data: {'statusName': statusName, 'imageUrls': imageUrls}));
  }

  /// PDO / TransportDB: the RTI status of job lines (`id` 0 adds, else the
  /// line's `statusId`; `rtiMasterRefId`, `rtiDetailsRefId`, ... `active` /
  /// `verify`, null = leave as it is) with a photo per line, keyed by the
  /// line's RTIDetails id. Answers the last saved status id. For a driver the
  /// server keeps it to their own RTIs.
  Future<int> saveStatuses(List<Map<String, dynamic>> statuses, {Map<int, File> photos = const {}}) async {
    final form = FormData();
    form.files.add(MapEntry('statuses',
        MultipartFile.fromString(jsonEncode(statuses), contentType: DioMediaType('application', 'json'))));
    for (final p in photos.entries) {
      form.files.add(MapEntry('photo_${p.key}', await MultipartFile.fromFile(p.value.path, filename: p.value.uri.pathSegments.last)));
    }
    return JsonRead.integer(await _send(() =>
        _dio.post<dynamic>('/api/rti-masters/job-statuses', queryParameters: {'companyId': companyId}, data: form)));
  }

  /// The route stops due in the days (`/api/rti-route-activities`), one
  /// employee's when [employeeId] is given; oldest ETA first.
  Future<List<Map<String, dynamic>>> routeActivities({
    required String fromDate,
    required String toDate,
    int employeeId = 0,
  }) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/rti-route-activities', queryParameters: {
            'companyRefId': companyId,
            'fromDate': _dateOnly(fromDate),
            'toDate': _dateOnly(toDate),
            if (employeeId != 0) 'employeeRefId': employeeId,
          })));

  /// One route stop pending (0) or completed (1).
  Future<void> setRouteActivityStatus(int id, int status) async {
    await _send(() => _dio.put<dynamic>('/api/rti-route-activities/$id/status',
        queryParameters: {'companyRefId': companyId, 'status': status}));
  }

  static String? _dateOnly(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
