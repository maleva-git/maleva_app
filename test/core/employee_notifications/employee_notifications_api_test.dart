import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_api.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;
import '../vessel_master/vessel_master_api_test.dart' show ok;

/// A notice as `GET /api/employee-notifications/mine` answers it (EmployeeNotificationDto).
Map<String, dynamic> noticeJson({
  int id = 11,
  String kind = 'VESSEL_ETA_CHANGED',
  String title = 'MSC COLETTE III 641R: ETA moved',
  String? body = 'ETA moved from 17 Oct 05:00 to 17 Oct 11:00. 1 of your jobs is affected.',
  String? linkPath = '/vessel-changes',
  String createdDate = '2026-10-13 08:42:34',
  bool read = false,
  String? refType = 'PTP_CALL',
  int? refId = 74,
}) =>
    {
      'id': id,
      'kind': kind,
      'title': title,
      'body': body,
      'linkPath': linkPath,
      'refType': refType,
      'refId': refId,
      'createdDate': createdDate,
      'read': read,
    };

void main() {
  late QueueAdapter adapter;
  late EmployeeNotificationsApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = EmployeeNotificationsApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test('mine reads the unread count and the notices with their Java fields', () async {
    adapter.replies.add((
      200,
      jsonEncode(ok({
        'unreadCount': 3,
        'items': [
          noticeJson(),
          noticeJson(id: 9, kind: 'FORWARDING_APPROVED', linkPath: '/forwarding-requests/9', read: true)
        ],
      }))
    ));

    final inbox = await api.mine();

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/employee-notifications/mine');
    expect(inbox.unreadCount, 3);
    final first = inbox.items.first;
    expect(first.id, 11);
    expect(first.kind, 'VESSEL_ETA_CHANGED');
    expect(first.title, 'MSC COLETTE III 641R: ETA moved');
    expect(first.linkPath, '/vessel-changes');
    expect(first.refType, 'PTP_CALL');
    expect(first.refId, 74);
    expect(first.read, isFalse);
    expect(first.createdAt, DateTime(2026, 10, 13, 8, 42, 34));
    expect(inbox.items.last.read, isTrue);
    expect(inbox.items.last.asRead().read, isTrue);
  });

  test('an empty inbox reads as zero and no items', () async {
    adapter.replies.add((200, jsonEncode(ok({'unreadCount': 0, 'items': []}))));
    final inbox = await api.mine();
    expect(inbox.unreadCount, 0);
    expect(inbox.items, isEmpty);
  });

  test('markRead puts to /{id}/read and reads the notice back', () async {
    adapter.replies.add((200, jsonEncode(ok(noticeJson(read: true)))));

    final n = await api.markRead(11);

    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.uri.path, '/api/employee-notifications/11/read');
    expect(n.id, 11);
    expect(n.read, isTrue);
  });

  test('markAllRead puts to /mine/read-all and reads the count', () async {
    adapter.replies.add((200, jsonEncode(ok(4))));

    expect(await api.markAllRead(), 4);
    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.uri.path, '/api/employee-notifications/mine/read-all');
  });

  test('mine with a group asks for only that group and reads its own unread count', () async {
    adapter.replies.add((
      200,
      jsonEncode(ok({
        'unreadCount': 2,
        'items': [noticeJson(), noticeJson(id: 12)]
      }))
    ));
    adapter.replies.add((
      200,
      jsonEncode(ok({
        'unreadCount': 1,
        'items': [noticeJson(id: 9, kind: 'FORWARDING_APPROVED', linkPath: '/forwarding-requests/9')],
      }))
    ));

    final vessel = await api.mine(group: NoticeGroup.vessel);
    final other = await api.mine(group: NoticeGroup.other);

    expect(adapter.requests[0].method, 'GET');
    expect(adapter.requests[0].uri.toString(), 'https://java.test/api/employee-notifications/mine?group=vessel');
    expect(adapter.requests[1].uri.toString(), 'https://java.test/api/employee-notifications/mine?group=other');
    expect(vessel.unreadCount, 2);
    expect(vessel.items.map((n) => n.id), [11, 12]);
    expect(other.unreadCount, 1);
    expect(other.items.single.kind, 'FORWARDING_APPROVED');
  });

  test('markAllRead with a group marks only that group', () async {
    adapter.replies.add((200, jsonEncode(ok(3))));
    adapter.replies.add((200, jsonEncode(ok(1))));

    expect(await api.markAllRead(group: NoticeGroup.vessel), 3);
    expect(await api.markAllRead(group: NoticeGroup.other), 1);

    expect(adapter.requests[0].method, 'PUT');
    expect(adapter.requests[0].uri.path, '/api/employee-notifications/mine/read-all');
    expect(adapter.requests[0].uri.queryParameters, {'group': 'vessel'});
    expect(adapter.requests[1].uri.queryParameters, {'group': 'other'});
  });

  test('NoticeGroup: wire values, the group of a kind, and the safety-net filter', () {
    expect(NoticeGroup.vessel.wire, 'vessel');
    expect(NoticeGroup.other.wire, 'other');
    expect(NoticeGroup.fromWire('vessel'), NoticeGroup.vessel);
    expect(NoticeGroup.fromWire('other'), NoticeGroup.other);
    expect(NoticeGroup.fromWire(null), isNull);
    expect(NoticeGroup.fromWire('mail'), isNull);
    final vesselNotice = EmployeeNotification.fromJava(noticeJson());
    final leave = EmployeeNotification.fromJava(noticeJson(id: 12, kind: 'LEAVE_APPROVED'));
    expect(NoticeGroup.of(vesselNotice), NoticeGroup.vessel);
    expect(NoticeGroup.of(leave), NoticeGroup.other);

    // a vessel notice answered in the other group is dropped, and its unread no longer counted
    final mixed = NotificationInbox(unreadCount: 5, items: [vesselNotice, leave]);
    final other = mixed.only(NoticeGroup.other);
    expect(other.items.single.id, 12);
    expect(other.unreadCount, 4);
    expect(mixed.only(NoticeGroup.vessel).items.single.id, 11);
    // nothing to drop: the same inbox
    expect(other.only(NoticeGroup.other), same(other));
  });

  test('the three vessel kinds are vessel notices: Vessel tab only, never Other', () {
    final eta = EmployeeNotification.fromJava(noticeJson());
    final link = EmployeeNotification.fromJava(noticeJson(
        id: 12,
        kind: 'VESSEL_LINK_NEEDED',
        title: 'Pick the PTP voyage: job MY002605357',
        linkPath: '/sale-order/edit/51234',
        refType: 'SALE_ORDER',
        refId: 51234));
    final stale = EmployeeNotification.fromJava(noticeJson(
        id: 13,
        kind: 'PTP_SCHEDULE_STALE',
        title: 'PTP schedule not updating since 13 Oct 10:05',
        linkPath: '/ptp-schedule',
        refType: 'PTP_SCHEDULE',
        refId: null));
    final leave = EmployeeNotification.fromJava(noticeJson(id: 14, kind: 'LEAVE_APPROVED'));

    expect(NoticeKind.vesselKinds, {'VESSEL_ETA_CHANGED', 'VESSEL_LINK_NEEDED', 'PTP_SCHEDULE_STALE', 'PHONE_PUSH_DOWN'});
    for (final n in [eta, link, stale]) {
      expect(NoticeKind.isVessel(n.kind), isTrue, reason: n.kind);
      expect(NoticeGroup.of(n), NoticeGroup.vessel, reason: n.kind);
    }
    expect(NoticeKind.isVessel('LEAVE_APPROVED'), isFalse);
    expect(NoticeKind.isVessel(null), isFalse);
    expect(link.saleOrderId, 51234);
    expect(eta.saleOrderId, isNull, reason: 'a PTP_CALL ref is not a job');

    final mixed = NotificationInbox(unreadCount: 4, items: [eta, link, stale, leave]);
    final vessel = mixed.only(NoticeGroup.vessel);
    expect(vessel.items.map((n) => n.id), [11, 12, 13]);
    expect(vessel.unreadCount, 3);
    final other = mixed.only(NoticeGroup.other);
    expect(other.items.map((n) => n.id), [14]);
    expect(other.unreadCount, 1);
  });

  test('a refusal keeps the server message', () async {
    adapter.replies
        .add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'Notification not found'})));
    expect(() => api.markRead(99),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Notification not found')));
  });
}
