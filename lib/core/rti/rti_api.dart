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

/// One job on an agent's stop (Java `StopReleaseService.StopJob`, read as it is).
class StopJob {
  const StopJob({required this.jobId, this.jobNo, this.customer, required this.leg, this.formType, this.releaseNo});

  final int jobId;
  final String? jobNo;
  final String? customer;
  final int leg;
  final String? formType;
  final String? releaseNo;

  factory StopJob.fromJava(Map<String, dynamic> json) => StopJob(
        jobId: (json['jobId'] as num?)?.toInt() ?? 0,
        jobNo: json['jobNo'] as String?,
        customer: json['customer'] as String?,
        leg: (json['leg'] as num?)?.toInt() ?? 1,
        formType: json['formType'] as String?,
        releaseNo: json['releaseNo'] as String?,
      );
}

/// One RTI stop with its time on site and waiting (Java `SiteVisitRepository.Row`, fleet W5). Times are local ISO text.
class SiteVisit {
  const SiteVisit({
    required this.kind,
    required this.stopId,
    this.jobNo,
    this.place,
    this.arrived,
    this.left,
    this.minutes,
    required this.status,
    this.checkIn,
    this.checkInVerified,
    this.workStart,
    this.done,
    this.waitingMinutes,
  });

  /// PICKUP or DELIVERY.
  final String kind;
  final int stopId;
  final String? jobNo;
  final String? place;
  final String? arrived;
  final String? left;
  final int? minutes;

  /// MATCHED, NO_PIN, NO_GPS, NOT_SEEN or PENDING.
  final String status;
  final String? checkIn;
  final bool? checkInVerified;
  final String? workStart;
  final String? done;
  final int? waitingMinutes;

  factory SiteVisit.fromJava(Map<String, dynamic> json) => SiteVisit(
        kind: json['kind'] as String? ?? '',
        stopId: (json['stopId'] as num?)?.toInt() ?? 0,
        jobNo: json['jobNo'] as String?,
        place: json['place'] as String?,
        arrived: json['arrived'] as String?,
        left: json['left'] as String?,
        minutes: (json['minutes'] as num?)?.toInt(),
        status: json['status'] as String? ?? '',
        checkIn: json['checkIn'] as String?,
        checkInVerified: json['checkInVerified'] as bool?,
        workStart: json['workStart'] as String?,
        done: json['done'] as String?,
        waitingMinutes: (json['waitingMinutes'] as num?)?.toInt(),
      );
}

/// A tap's answer (Java `SiteVisitDtos.TapResult`): saved or not, and what to tell the driver.
class SiteVisitTap {
  const SiteVisitTap({required this.saved, required this.message});

  final bool saved;
  final String message;

  factory SiteVisitTap.fromJava(Map<String, dynamic> json) =>
      SiteVisitTap(saved: json['saved'] as bool? ?? false, message: json['message'] as String? ?? '');
}

/// True for the stops that are forwarding work (seal, break seal, both, K-form clearance): those get "Release no".
bool isForwardingStop(String activityType) {
  final t = activityType.trim().toUpperCase();
  return t.contains('SEAL') || RegExp(r'^K\d').hasMatch(t);
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
  /// The driver's trips by their real day (`GET /api/rti-masters/trips`, Java `DriverTrip` maps as they are): the first
  /// stop's date decides the day, not the RTI date. A driver token gets only its own trips.
  Future<List<Map<String, dynamic>>> trips(String fromDay, String toDay) async => JsonRead.listOfMaps(await _send(() =>
      _dio.get<dynamic>('/api/rti-masters/trips', queryParameters: {'companyId': companyId, 'from': fromDay, 'to': toDay})));

  /// The driver taps "Got it" on his trip (`PUT /api/rti-masters/trips/{rtiId}/seen`).
  Future<void> tripSeen(int rtiId) async {
    await _send(() => _dio.put<dynamic>('/api/rti-masters/trips/$rtiId/seen', queryParameters: {'companyId': companyId}));
  }

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

  /// Sends the RTI to its truck's WhatsApp group (`POST /api/rti-masters/{id}/share-whatsapp`
  /// body `{companyId}`, employee tokens only): `{sent, rtiNo, truck, group, messages, detail,
  /// documentSkipped}` from `Data1` (`R/api/rtiShareApi.ts:37-40`).
  Future<Map<String, dynamic>> shareWhatsApp(int rtiId) async =>
      JsonRead.map(await _send(() => _dio.post<dynamic>('/api/rti-masters/$rtiId/share-whatsapp', data: {'companyId': companyId})));

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

  /// The signed-in agent's 06:00 alarm of today (`/api/rti-morning-briefing/today`): `sent`, `stopCount`,
  /// `ackAt` (null until "Got it"). `sent` is false when no alarm went out (or the follow-up is switched off).
  Future<Map<String, dynamic>> morningAlarmToday() async =>
      JsonRead.map(await _send(() => _dio.get<dynamic>('/api/rti-morning-briefing/today')));

  /// "Got it" for today's alarm; answers the same shape as [morningAlarmToday].
  Future<Map<String, dynamic>> morningAlarmGotIt() async =>
      JsonRead.map(await _send(() => _dio.post<dynamic>('/api/rti-morning-briefing/today/ack')));

  /// One route stop pending (0) or completed (1).
  /// C3 (forwarding clean-up, owner 2026-10-26): the jobs on the stop's RTI with the leg the release no goes to and the
  /// release no saved there (shared Java `/api/forwarding-flow/stops/{id}/jobs`). Only the agent's own stops.
  Future<List<StopJob>> stopJobs(int stopId) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/forwarding-flow/stops/$stopId/jobs')))
          .map(StopJob.fromJava)
          .toList();

  /// C3: saves one job's release no from the stop card; answers the stop's jobs again.
  Future<List<StopJob>> saveStopRelease(int stopId, int jobId, String releaseNo) async =>
      JsonRead.listOfMaps(await _send(() => _dio.put<dynamic>('/api/forwarding-flow/stops/$stopId/release',
              data: {'jobId': jobId, 'releaseNo': releaseNo.trim()})))
          .map(StopJob.fromJava)
          .toList();

  /// Fleet W5 "Time on site": each pickup / delivery of the RTI with when the truck arrived and left (GPS) and the
  /// driver's start time (`GET /api/site-visits`, Java `SiteVisitRepository.Row`, read as it is). A driver token gets
  /// its own RTIs only (the server checks).
  Future<List<SiteVisit>> siteVisits(int rtiId) async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/site-visits', queryParameters: {'companyId': companyId, 'rtiId': rtiId})))
          .map(SiteVisit.fromJava)
          .toList();

  /// Are the driver's taps switched on? (`GET /api/site-visits/settings`, `driverTaps`). False = GPS only: the app shows
  /// the times but no buttons. A failure reads as off.
  Future<bool> siteVisitTapsOn() async {
    try {
      return JsonRead.map(await _send(() => _dio.get<dynamic>('/api/site-visits/settings')))['driverTaps'] == true;
    } catch (_) {
      return false;
    }
  }

  /// The driver's taps at a stop (fleet W5): `check-in` at the gate (the server checks it against the truck's GPS and
  /// refuses it when the truck is clearly elsewhere), `work-start` ("Start loading / unloading") and `done`. The first
  /// tap counts. A refusal is an [ApiFailure] with the server's message.
  Future<SiteVisitTap> siteVisitTap(String action, String stopKind, int stopId) async => SiteVisitTap.fromJava(JsonRead.map(
      await _send(() => _dio.put<dynamic>('/api/site-visits/$action',
          queryParameters: {'companyId': companyId}, data: {'stopKind': stopKind, 'stopId': stopId}))));

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
