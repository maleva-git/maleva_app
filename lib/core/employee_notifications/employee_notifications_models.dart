import 'package:maleva/core/utils/json_read.dart';

/// Notice kinds the app knows (`kind` of `/api/employee-notifications/mine`); other kinds show as plain notices.
class NoticeKind {
  NoticeKind._();

  static const String vesselEtaChanged = 'VESSEL_ETA_CHANGED';

  /// A job at PTP is not linked to its PTP voyage ("Pick the PTP voyage: job MY002605357"); link
  /// `/sale-order/edit/{id}`, ref `SALE_ORDER` / the job id.
  static const String vesselLinkNeeded = 'VESSEL_LINK_NEEDED';

  /// PTP's schedule has not been read for an hour ("PTP schedule not updating since ..."); link `/ptp-schedule`.
  static const String ptpScheduleStale = 'PTP_SCHEDULE_STALE';

  /// Phone pushes stopped working for everyone (to Super Admins, "Phone alerts are not working"); no link.
  static const String phonePushDown = 'PHONE_PUSH_DOWN';

  /// A linked call is Omitted at Westports ("EVER LIFTING 066W omitted at Westports – 2 of your jobs");
  /// link `/vessel-changes` (one job without employee: `/sale-order/edit/{id}`), ref `PTP_CALL`.
  static const String vesselOmitted = 'VESSEL_OMITTED';

  /// Nobody uploaded the Westports vessel schedule for a while ("Please upload the Westports vessel
  /// schedule (last upload 10:05)"); link `/westports-schedule`, a web page (the app has no upload screen).
  static const String westportsUploadDue = 'WESTPORTS_UPLOAD_DUE';

  /// MMSW's schedule (Northport, Southport) has had no good read for 3 hours while reading and notices are
  /// on (backend change mmsw-vessel-schedule); link `/vessel-changes`. Looks like [ptpScheduleStale].
  static const String mmswScheduleStale = 'MMSW_SCHEDULE_STALE';

  /// The vessel notices: the Vessel tab and the ship button, the vessel phone channel; never the Other tab.
  static const Set<String> vesselKinds = {
    vesselEtaChanged,
    vesselLinkNeeded,
    ptpScheduleStale,
    phonePushDown,
    vesselOmitted,
    westportsUploadDue,
    mmswScheduleStale,
  };

  static bool isVessel(String? kind) => vesselKinds.contains(kind);

  static const String forwardingPrefix = 'FORWARDING_';

  /// `refType` of a notice about one job (its `refId` is the sale order id).
  static const String saleOrderRef = 'SALE_ORDER';
}

/// The two separate inboxes (owner, 2026-10-13: vessel ETA notices are never mixed with the others).
/// [wire] is the `group` query value of `/api/employee-notifications/mine` and `/mine/read-all`:
/// `vessel` = the [NoticeKind.vesselKinds] (`VESSEL_ETA_CHANGED`, `VESSEL_LINK_NEEDED`,
/// `PTP_SCHEDULE_STALE`, `PHONE_PUSH_DOWN`, `VESSEL_OMITTED`, `WESTPORTS_UPLOAD_DUE`, `MMSW_SCHEDULE_STALE`),
/// `other` = every other kind.
enum NoticeGroup {
  vessel,
  other;

  String get wire => name;

  /// The group a notice belongs to by its `kind`.
  static NoticeGroup of(EmployeeNotification n) => NoticeKind.isVessel(n.kind) ? vessel : other;

  /// The group for a `tab` query value (`vessel` / `other`); null for anything else.
  static NoticeGroup? fromWire(String? value) {
    for (final g in values) {
      if (g.wire == value) return g;
    }
    return null;
  }

  bool holds(EmployeeNotification n) => of(n) == this;
}

/// One notice of the signed-in employee's bell (`EmployeeNotificationDto`), read as Java answers it.
class EmployeeNotification {
  const EmployeeNotification({
    required this.id,
    required this.kind,
    required this.title,
    this.body,
    this.linkPath,
    this.refType,
    this.refId,
    this.createdDate,
    this.read = false,
  });

  factory EmployeeNotification.fromJava(Map<String, dynamic> m) => EmployeeNotification(
        id: JsonRead.integer(m['id']),
        kind: JsonRead.string(m['kind']),
        title: JsonRead.string(m['title']),
        body: JsonRead.stringOrNull(m['body']),
        linkPath: JsonRead.stringOrNull(m['linkPath']),
        refType: JsonRead.stringOrNull(m['refType']),
        refId: JsonRead.intOrNull(m['refId']),
        createdDate: JsonRead.stringOrNull(m['createdDate']),
        read: JsonRead.boolean(m['read']),
      );

  final int id;
  final String kind;
  final String title;
  final String? body;

  /// The React path the notice points at, e.g. `/vessel-changes?scope=team`.
  final String? linkPath;
  final String? refType;
  final int? refId;

  /// `yyyy-MM-dd HH:mm:ss` (server local time).
  final String? createdDate;
  final bool read;

  DateTime? get createdAt => createdDate == null ? null : DateTime.tryParse(createdDate!);

  /// The job the notice is about (`refType` `SALE_ORDER`); null otherwise.
  int? get saleOrderId => refType == NoticeKind.saleOrderRef ? refId : null;

  EmployeeNotification asRead() => EmployeeNotification(
      id: id,
      kind: kind,
      title: title,
      body: body,
      linkPath: linkPath,
      refType: refType,
      refId: refId,
      createdDate: createdDate,
      read: true);
}

/// `GET /api/employee-notifications/mine`: the unread count and the newest 50 notices (read ones included).
class NotificationInbox {
  const NotificationInbox({this.unreadCount = 0, this.items = const []});

  factory NotificationInbox.fromJava(Map<String, dynamic> m) => NotificationInbox(
        unreadCount: JsonRead.integer(m['unreadCount']),
        items: JsonRead.listOfMaps(m['items']).map(EmployeeNotification.fromJava).toList(),
      );

  final int unreadCount;
  final List<EmployeeNotification> items;

  /// Only [group]'s notices: a safety net so a notice of the other group is never shown in this one.
  /// The server's count is lowered by the unread notices dropped (never below zero).
  NotificationInbox only(NoticeGroup group) {
    final kept = [
      for (final n in items)
        if (group.holds(n)) n
    ];
    if (kept.length == items.length) return this;
    final droppedUnread = items.where((n) => !n.read && !group.holds(n)).length;
    final unread = unreadCount - droppedUnread;
    return NotificationInbox(unreadCount: unread < 0 ? 0 : unread, items: kept);
  }
}
