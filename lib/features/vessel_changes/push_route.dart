import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/features/notifications/notification_routes.dart' show notificationsVesselPath;

/// Where a vessel push opens (backend change vessel-master-and-ptp-schedule). The three vessel push types
/// ([NoticeKind.vesselKinds]) open by their React `link`:
/// - `/vessel-changes` or `/vessel-changes?scope=team` (the team leader's "Not handled" notice): the
///   "Vessel changes" screen, in team scope when the link says so;
/// - `/sale-order/edit/{id}` (`VESSEL_LINK_NEEDED`, or `VESSEL_ETA_CHANGED` for a job without employee
///   sent to a Super Admin): the app's sale order screen for that job ([saleOrderEditRoute]);
/// - `/ptp-schedule` (`PTP_SCHEDULE_STALE`): Vessel changes, which has "Read PTP now";
/// - `/vessel-changes` (`MMSW_SCHEDULE_STALE`): Vessel changes, where MMSW's last read is shown;
/// - `/westports-schedule` (`WESTPORTS_UPLOAD_DUE`): the upload is a web page, so the Vessel tab of the
///   notifications page, where the notice's text says what to do;
/// - anything else: `VESSEL_ETA_CHANGED` and `VESSEL_OMITTED` open Vessel changes, the others the Vessel
///   tab of the notifications page.
/// Chained ahead of the forwarding routes in mail_monitor/mine/push_route.dart.
const String vesselChangesPath = '/vessel_changes';
const String vesselEtaChangedPushType = NoticeKind.vesselEtaChanged;
const String vesselLinkNeededPushType = NoticeKind.vesselLinkNeeded;
const String ptpScheduleStalePushType = NoticeKind.ptpScheduleStale;
const String vesselOmittedPushType = NoticeKind.vesselOmitted;
const String westportsUploadDuePushType = NoticeKind.westportsUploadDue;
const String mmswScheduleStalePushType = NoticeKind.mmswScheduleStale;

/// The push types shown as vessel notices (the vessel phone channel with the long vibration).
bool isVesselPushType(String? type) => NoticeKind.isVessel(type);

/// Vessel changes opened on "My team".
const String vesselChangesTeamPath = '$vesselChangesPath?scope=team';

/// The local notification payload of a team vessel push (the payload is otherwise the push type).
const String vesselTeamPayload = '$vesselEtaChangedPushType?scope=team';

/// The sale order (job) edit screen, `SalesOrdersAdd(saleOrderId: id)`, as an app route.
const String saleOrderEditPath = '/sale_order_edit';

String saleOrderEditRoute(int saleOrderId) => '$saleOrderEditPath/$saleOrderId';

/// The job id of a React `/sale-order/edit/{id}` link; null for any other link or a bad id.
int? saleOrderIdFromLink(String? link) {
  if (link == null) return null;
  final segments = Uri.tryParse(link)?.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments == null || segments.length != 3 || segments[0] != 'sale-order' || segments[1] != 'edit') return null;
  final id = int.tryParse(segments[2]);
  return id != null && id > 0 ? id : null;
}

bool _isPtpScheduleLink(String? link) => link != null && Uri.tryParse(link)?.path == '/ptp-schedule';

bool _isVesselChangesLink(String? link) => link != null && Uri.tryParse(link)?.path == '/vessel-changes';

/// Where a vessel notice of [type] opens, by its React [link]; [saleOrderId] (the notice's `SALE_ORDER`
/// ref) stands in for a job link that is missing.
String vesselRouteFor({required String type, String? link, int? saleOrderId}) {
  final jobId = saleOrderIdFromLink(link) ?? (saleOrderId != null && saleOrderId > 0 ? saleOrderId : null);
  if (jobId != null) return saleOrderEditRoute(jobId);
  if (type == westportsUploadDuePushType) return notificationsVesselPath;
  if (type == ptpScheduleStalePushType || type == mmswScheduleStalePushType || _isPtpScheduleLink(link)) {
    return vesselChangesPath;
  }
  if (type == vesselEtaChangedPushType || type == vesselOmittedPushType || _isVesselChangesLink(link)) {
    return vesselChangesRouteForLink(link);
  }
  return notificationsVesselPath;
}

/// The route of a tapped vessel push; null for any other push type.
String? vesselChangesRouteForPush(Map<String, dynamic>? data) {
  final type = data?['type']?.toString();
  if (data == null || !isVesselPushType(type)) return null;
  return vesselRouteFor(type: type!, link: data['link']?.toString());
}

/// Vessel changes for a notice's React link: team scope when the link carries `scope=team`.
String vesselChangesRouteForLink(String? link) => vesselLinkIsTeam(link) ? vesselChangesTeamPath : vesselChangesPath;

bool vesselLinkIsTeam(String? link) {
  if (link == null) return false;
  final uri = Uri.tryParse(link);
  return uri?.queryParameters['scope'] == 'team';
}

/// Separates a vessel push type from the app route in a local notification payload (`TYPE@/route`).
const String _payloadRouteMark = '@';

/// What a shown local notification carries for [data]: the push type, so a tap opens the same screen as
/// the push itself. A vessel push opening Vessel changes keeps the plain type ([vesselTeamPayload] for
/// team scope); one opening another screen carries its route (`VESSEL_LINK_NEEDED@/sale_order_edit/51234`).
String localPayloadForPush(Map<String, dynamic> data) {
  final type = data['type']?.toString() ?? '';
  if (!isVesselPushType(type)) return type;
  final route = vesselRouteFor(type: type, link: data['link']?.toString());
  if (type == vesselEtaChangedPushType && route == vesselChangesPath) return type;
  if (type == vesselEtaChangedPushType && route == vesselChangesTeamPath) return vesselTeamPayload;
  return '$type$_payloadRouteMark$route';
}

/// The route of a local notification's payload ([localPayloadForPush]); null when it is not a vessel one.
String? vesselChangesRouteForType(String? payload) {
  if (payload == null) return null;
  if (payload == vesselEtaChangedPushType) return vesselChangesPath;
  if (payload == vesselTeamPayload) return vesselChangesTeamPath;
  final mark = payload.indexOf(_payloadRouteMark);
  if (mark > 0) {
    final type = payload.substring(0, mark);
    final route = payload.substring(mark + 1);
    if (isVesselPushType(type) && route.startsWith('/')) return route;
    return null;
  }
  if (isVesselPushType(payload)) return vesselRouteFor(type: payload);
  return null;
}

/// The scope Vessel changes opens with for a route's `scope` query value.
String vesselScopeFromQuery(String? scope) => scope == 'team' ? 'team' : 'me';
