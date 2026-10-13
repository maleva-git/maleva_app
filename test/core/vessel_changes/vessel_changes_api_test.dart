import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;
import '../vessel_master/vessel_master_api_test.dart' show callJson, ok;

/// A job as `GET /api/vessel-changes` answers it (api-contract.md).
Map<String, dynamic> jobJson({
  int id = 51234,
  String leg = 'LOADING',
  String? reason,
  String? suggestedPickup = '2026-10-14T09:00',
  String? boardingFrom,
  String? boardingTo,
}) =>
    {
      'saleOrderId': id,
      'jobNo': 'MY00$id',
      'customerName': 'ABC MARINE',
      'employeeId': 12,
      'employeeName': 'SHALINI',
      'leg': leg,
      'vesselName': 'MAERSK RIO NEGRO',
      'currentEta': '2026-10-13T08:00',
      'currentEtd': '2026-10-14T17:00',
      'currentScn': null,
      'ptpEta': '2026-10-15T08:00',
      'ptpEtd': '2026-10-16T17:00',
      'ptpScn': '269EK6',
      'etaDiffers': true,
      'etdDiffers': true,
      'scnDiffers': true,
      'pickupDate': '2026-10-12T09:00',
      'deliveryDate': '2026-10-12T15:00',
      'suggestedPickupDate': suggestedPickup,
      'suggestedDeliveryDate': suggestedPickup == null ? null : '2026-10-14T15:00',
      'pickupMoveReason': reason,
      'plannedDate': reason == 'PLANNED' ? '2026-10-12T09:00' : null,
      'boardingMonthFrom': boardingFrom,
      'boardingMonthTo': boardingTo,
    };

/// An alert as `GET /api/vessel-changes/alerts` answers it (VesselAlertDto).
Map<String, dynamic> alertJson({int id = 7, bool mine = true, String employeeName = 'SHALINI', int reminders = 1,
        bool escalated = false, int jobs = 2, bool unassigned = false, int? saleOrderId, String? jobNo}) =>
    {
      'id': id,
      'ptpVesselCallId': 412,
      'vesselName': 'MAERSK RIO NEGRO',
      'voyage': '641S',
      'arriveAt': '2026-10-15T08:00',
      'arriveEstimated': true,
      'departAt': '2026-10-16T17:00',
      'departEstimated': true,
      'jobs': jobs,
      'employeeId': 12,
      'employeeName': employeeName,
      'mine': mine,
      'sentAt': '2026-10-13T09:29',
      'reminders': reminders,
      'escalated': escalated,
      'kind': 'ETA',
      'saleOrderId': saleOrderId,
      'jobNo': jobNo,
      'unassigned': unassigned,
    };

/// A LINK alert (a job not linked to its PTP voyage); [suggested] false: PTP's voyage is not known.
Map<String, dynamic> linkAlertJson({int id = 21, bool mine = true, bool suggested = true, int? saleOrderId = 51234}) => {
      'id': id,
      'ptpVesselCallId': suggested ? 412 : null,
      'vesselName': 'Maersk Rio Negro',
      'voyage': suggested ? 'MAERSK RIO NEGRO 641S' : null,
      'arriveAt': suggested ? '2026-10-15T08:00' : null,
      'arriveEstimated': false,
      'departAt': null,
      'departEstimated': false,
      'jobs': 1,
      'employeeId': 12,
      'employeeName': 'SHALINI',
      'mine': mine,
      'sentAt': '2026-10-13T09:29',
      'reminders': 0,
      'escalated': false,
      'kind': 'LINK',
      'saleOrderId': saleOrderId,
      'jobNo': 'MY002605357',
      'unassigned': false,
    };

void main() {
  late QueueAdapter adapter;
  late VesselChangesApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = VesselChangesApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test('list sends the scope and reads groups, changes and jobs with the move suggestion and boarding flag', () async {
    adapter.replies.add((200, jsonEncode(ok({
      'lastGoodReadAt': '2026-10-12T09:15',
      'groups': [
        {
          'call': callJson,
          'lastChangedAt': '2026-10-12T09:15',
          'changes': [
            {'field': 'ARRIVE', 'oldValue': '2026-10-13T08:00', 'newValue': '2026-10-15T08:00', 'seenAt': '2026-10-12T09:15'}
          ],
          'jobs': [
            jobJson(),
            jobJson(id: 51240, reason: 'PLANNED', suggestedPickup: null, boardingFrom: '2026-10', boardingTo: '2026-11'),
          ],
        }
      ],
    }))));

    final list = await api.list(scope: 'team');

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/vessel-changes?scope=team');
    expect(list.lastGoodReadAt, '2026-10-12T09:15');
    final group = list.groups.single;
    expect(group.call.id, 412);
    expect(group.changes.single.field, 'ARRIVE');
    final movable = group.jobs.first;
    expect(movable.ptpEta, '2026-10-15T08:00');
    expect(movable.suggestedPickupDate, '2026-10-14T09:00');
    expect(movable.canMovePickup, isTrue);
    expect(movable.boardingMonthChanges, isFalse);
    final planned = group.jobs.last;
    expect(planned.pickupMoveReason, PickupMoveReason.planned);
    expect(planned.plannedDate, '2026-10-12T09:00');
    expect(planned.canMovePickup, isFalse);
    expect(planned.boardingMonthChanges, isTrue);
    expect(planned.boardingMonthTo, '2026-11');
  });

  test('the server decides which leg moves pickup: an off leg may move, NOT_THIS_LEG may not', () {
    final offMoves = VesselChangeJob.fromJava(jobJson(id: 51300, leg: 'OFF'));
    final offFollows = VesselChangeJob.fromJava(jobJson(id: 51301, leg: 'OFF', reason: 'NOT_THIS_LEG', suggestedPickup: null));

    expect(offMoves.canMovePickup, isTrue);
    expect(offFollows.canMovePickup, isFalse);
  });

  test('an off-leg apply body has companyId, saleOrderIds, oeta and oetd and nothing else', () {
    final body = VesselChangesApi.applyBody(
        companyId: 6, leg: VesselLeg.off, saleOrderIds: [51300, 51301], eta: '2026-10-15T08:00', etd: '2026-10-16T17:00');

    expect(body, {
      'companyId': 6,
      'saleOrderIds': [51300, 51301],
      'oeta': '2026-10-15T08:00',
      'oetd': '2026-10-16T17:00',
    });
  });

  test('a loading-leg apply posts eta and etd to the bulk update and reads its unwrapped answer', () async {
    adapter.replies.add((200, jsonEncode({
      'requested': 2,
      'updated': 1,
      'skipped': 1,
      'results': [
        {'saleOrderId': 51234, 'jobNo': 'MY002605932', 'ok': true, 'message': null, 'saved': {'eta': '2026-10-15T08:00'}},
        {'saleOrderId': 51240, 'jobNo': 'MY002605940', 'ok': false, 'message': 'Job is closed'},
      ],
    })));

    final result = await api.applyTimes(
        leg: VesselLeg.loading, saleOrderIds: [51234, 51240], eta: '2026-10-15T08:00', etd: '2026-10-16T17:00');

    final request = adapter.requests.single;
    expect(request.uri.toString(), 'https://java.test/api/vessel-plannings/sale-order-update-many');
    expect(request.data,
        {'companyId': 6, 'saleOrderIds': [51234, 51240], 'eta': '2026-10-15T08:00', 'etd': '2026-10-16T17:00'});
    expect(result.updated, 1);
    expect(result.results.last.ok, isFalse);
    expect(result.results.last.message, 'Job is closed');
  });

  test('a missing PTP departure is left out, so the job keeps its own', () {
    expect(VesselChangesApi.applyBody(companyId: 6, leg: VesselLeg.loading, saleOrderIds: [1], eta: '2026-10-15T08:00'),
        {'companyId': 6, 'saleOrderIds': [1], 'eta': '2026-10-15T08:00'});
  });

  test('dismiss and move send the contract bodies', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'dismissed': true}))))
      ..add((200, jsonEncode(ok({
        'results': [
          {'saleOrderId': 51234, 'jobNo': 'MY002605932', 'outcome': 'MOVED', 'pickupDate': '2026-10-14T09:00',
            'deliveryDate': '2026-10-14T15:00'},
          {'saleOrderId': 51240, 'jobNo': 'MY002605940', 'outcome': 'PLANNED', 'pickupDate': null, 'deliveryDate': null},
        ]
      }))));

    expect(await api.dismiss(saleOrderId: 51234, leg: VesselLeg.loading, ptpVesselCallId: 412), isTrue);
    final moves = await api.movePickupDelivery(ptpVesselCallId: 412, saleOrderIds: [51234, 51240]);

    expect(adapter.requests.first.uri.path, '/api/vessel-changes/dismiss');
    expect(adapter.requests.first.data, {'saleOrderId': 51234, 'leg': 'LOADING', 'ptpVesselCallId': 412});
    expect(adapter.requests.last.uri.path, '/api/vessel-changes/move-pickup-delivery');
    expect(adapter.requests.last.data, {'ptpVesselCallId': 412, 'saleOrderIds': [51234, 51240]});
    expect(moves.first.moved, isTrue);
    expect(moves.last.outcome, MoveOutcome.planned);
  });

  test('a server error keeps its message', () async {
    adapter.replies.add((500, jsonEncode({'status': 500, 'error': 'Internal', 'message': 'PTP read failed'})));
    expect(() => api.list(), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'PTP read failed')));
  });

  test('readPtpNow posts to the PTP read and reads a reused recent read', () async {
    adapter.replies.add((200, jsonEncode(ok({'ok': true, 'rows': 224, 'changes': 0, 'message': null,
        'startedAt': '2026-10-13T11:20', 'recent': true}))));

    final result = await api.readPtpNow();

    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/ptp/vessel-schedules/read');
    expect(result.ok, isTrue);
    expect(result.rows, 224);
    expect(result.recent, isTrue);
    expect(result.startedAt, '2026-10-13T11:20');
  });

  test('alerts gets /api/vessel-changes/alerts and reads every field, in the server order', () async {
    adapter.replies.add((200, jsonEncode(ok([alertJson(escalated: true), alertJson(id: 8, mine: false, employeeName: 'RAJ')]))));

    final alerts = await api.alerts();

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/vessel-changes/alerts');
    final a = alerts.first;
    expect(a.id, 7);
    expect(a.ptpVesselCallId, 412);
    expect(a.vesselText, 'MAERSK RIO NEGRO 641S');
    expect(a.arriveAt, '2026-10-15T08:00');
    expect(a.arriveEstimated, isTrue);
    expect(a.departAt, '2026-10-16T17:00');
    expect(a.jobs, 2);
    expect(a.employeeId, 12);
    expect(a.employeeName, 'SHALINI');
    expect(a.mine, isTrue);
    expect(a.sentAt, '2026-10-13T09:29');
    expect(a.reminders, 1);
    expect(a.escalated, isTrue);
    expect(alerts.last.mine, isFalse);
    expect(alerts.last.employeeName, 'RAJ');
  });

  test('alerts read kind, job and unassigned; an older answer without them reads as an ETA alert', () async {
    final older = alertJson()
      ..remove('kind')
      ..remove('saleOrderId')
      ..remove('jobNo')
      ..remove('unassigned');
    adapter.replies.add((200, jsonEncode(ok([
      linkAlertJson(),
      linkAlertJson(id: 22, suggested: false),
      alertJson(id: 9, unassigned: true, employeeName: 'No employee', saleOrderId: 51300, jobNo: 'MY002605400'),
      older,
    ]))));

    final alerts = await api.alerts();

    final link = alerts[0];
    expect(link.kind, VesselAlertKind.link);
    expect(link.isLink, isTrue);
    expect(link.saleOrderId, 51234);
    expect(link.jobNo, 'MY002605357');
    expect(link.vesselName, 'Maersk Rio Negro');
    expect(link.voyage, 'MAERSK RIO NEGRO 641S');
    expect(link.ptpVesselCallId, 412);
    final unsuggested = alerts[1];
    expect(unsuggested.ptpVesselCallId, isNull);
    expect(unsuggested.voyage, isNull);
    expect(unsuggested.arriveAt, isNull);
    final unassigned = alerts[2];
    expect(unassigned.isLink, isFalse);
    expect(unassigned.unassigned, isTrue);
    expect(unassigned.employeeName, 'No employee');
    expect(unassigned.saleOrderId, 51300);
    final old = alerts[3];
    expect(old.kind, VesselAlertKind.eta);
    expect(old.isLink, isFalse);
    expect(old.unassigned, isFalse);
    expect(old.saleOrderId, isNull);
    expect(old.jobNo, isNull);
  });

  test('closeAlert posts to /api/vessel-changes/alerts/{id}/close and reads Data1 true', () async {
    adapter.replies.add((200, jsonEncode(ok(true))));

    expect(await api.closeAlert(21), isTrue);

    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/vessel-changes/alerts/21/close');
  });

  test('closeAlert refused (403 ETA alert, 404 unknown) keeps the server message', () async {
    adapter.replies
      ..add((403, jsonEncode({'IsSuccess': false, 'StatusCode': 403, 'Message': 'Only a LINK alert can be closed'})))
      ..add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'Alert not found'})));

    await expectLater(api.closeAlert(7),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Only a LINK alert can be closed')));
    await expectLater(
        api.closeAlert(99), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Alert not found')));
  });

  test('no open alerts is an empty list', () async {
    adapter.replies.add((200, jsonEncode(ok([]))));
    expect(await api.alerts(), isEmpty);
  });
}
