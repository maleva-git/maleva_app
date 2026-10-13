import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// Jobs whose dates differ from PTP (backend change vessel-master-and-ptp-schedule), on the shared
/// Java API React uses. Applying PTP's times goes through the existing Vessel Planning bulk update.
/// A refusal is an `ApiFailure` with the server's message.
class VesselChangesApi {
  VesselChangesApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  /// `GET /api/vessel-changes`: [scope] `me` (my jobs) or `team`; [employeeId] defaults to the caller.
  Future<VesselChanges> list({String scope = 'me', int? employeeId}) async =>
      VesselChanges.fromJava(JsonRead.map(await _send(() => _dio.get<dynamic>('/api/vessel-changes',
          queryParameters: {'scope': scope, if (employeeId != null) 'employeeId': employeeId}))));

  /// `GET /api/vessel-changes/alerts`: the caller's open vessel alerts (ETA and LINK), then the escalated ones of the
  /// people they lead (`mine` false), as the server orders them.
  Future<List<VesselAlert>> alerts() async =>
      JsonRead.listOfMaps(await _send(() => _dio.get<dynamic>('/api/vessel-changes/alerts')))
          .map(VesselAlert.fromJava)
          .toList();

  /// `POST /api/vessel-changes/alerts/{id}/close` ("Not this vessel"): closes a LINK alert of the caller or
  /// of a person they lead; answers true. The server refuses (404 unknown, 403 someone else's or an ETA
  /// alert) with its message.
  Future<bool> closeAlert(int id) async =>
      JsonRead.boolean(await _send(() => _dio.post<dynamic>('/api/vessel-changes/alerts/$id/close')));

  /// `POST /api/ptp/vessel-schedules/read` ("Read PTP now"): reads PTP's schedule, or answers with a read
  /// from the last few minutes (`recent`) so many people pressing it ask PTP once.
  Future<PtpReadResult> readPtpNow() async =>
      PtpReadResult.fromJava(JsonRead.map(await _send(() => _dio.post<dynamic>('/api/ptp/vessel-schedules/read'))));

  /// `POST /api/vessel-changes/dismiss`: the job's leg is no longer listed for this call.
  Future<bool> dismiss({required int saleOrderId, required String leg, required int ptpVesselCallId}) async =>
      JsonRead.boolean(JsonRead.map(await _send(() => _dio.post<dynamic>('/api/vessel-changes/dismiss',
          data: {'saleOrderId': saleOrderId, 'leg': leg, 'ptpVesselCallId': ptpVesselCallId})))['dismissed']);

  /// Writes PTP's [eta] / [etd] on the jobs of one [leg] through the existing
  /// `POST /api/vessel-plannings/sale-order-update-many` (not wrapped in ApiResponse). Only that leg's
  /// two dates are sent (loading `eta`/`etd`, off `oeta`/`oetd`); a null date is left out, which keeps
  /// the job's own.
  Future<BulkUpdateResult> applyTimes(
      {required String leg, required List<int> saleOrderIds, String? eta, String? etd}) async {
    try {
      final response = await _dio.post<dynamic>('/api/vessel-plannings/sale-order-update-many',
          data: applyBody(companyId: _companyId(), leg: leg, saleOrderIds: saleOrderIds, eta: eta, etd: etd));
      return BulkUpdateResult.fromJava(JsonRead.map(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The bulk update body for one leg: `companyId`, `saleOrderIds` and that leg's two dates, nothing else.
  static Map<String, dynamic> applyBody(
      {required int companyId, required String leg, required List<int> saleOrderIds, String? eta, String? etd}) {
    final off = leg == VesselLeg.off;
    return {
      'companyId': companyId,
      'saleOrderIds': saleOrderIds,
      if (eta != null) (off ? 'oeta' : 'eta'): eta,
      if (etd != null) (off ? 'oetd' : 'etd'): etd,
    };
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return JavaResponse.data((await call()).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
