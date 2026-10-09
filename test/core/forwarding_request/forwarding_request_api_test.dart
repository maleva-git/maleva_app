import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// One row as `/api/forwarding-requests` answers it (ForwardingRequestDto, Data1 unwrapped).
Map<String, dynamic> javaRow({int id = 7, String status = 'REQUESTED', Map<String, dynamic> more = const {}}) => {
      'id': id, 'saleOrderId': 910, 'jobNo': 'MY002605939', 'customerName': 'PAC DISTRIC', 'jobType': 'LAND TRANSPORT ONBOARD',
      'vesselName': 'BRIGHT', 'formType': 'K8', 'estimatedDate': '2026-10-12 09:00:00', 'remarks': null,
      'requestedById': 17, 'requestedBy': 'NAGA', 'requestedDate': '2026-10-08 10:00:00',
      'documentReceived': false, 'documentReceivedDate': null, 'documentReceivedBy': null,
      'draftCreated': false, 'draftCreatedDate': null, 'draftCreatedBy': null, 'draftCNumber': null,
      'submitted': false, 'submittedDate': null, 'submittedBy': null, 'submittedRef': null,
      'approved': false, 'approvedDate': null, 'approvedBy': null, 'approvedRecordedDate': null,
      'released': false, 'releasedDate': null, 'releasedBy': null, 'releaseNo': null,
      'sealById': null, 'sealBy': null, 'breakSealById': null, 'breakSealBy': null,
      'cancelledDate': null, 'cancelledBy': null, 'status': status, ...more,
    };

void main() {
  group('ForwardingRequest model', () {
    test('reads the Java fields as sent', () {
      final r = ForwardingRequest.fromJava(javaRow(status: 'DRAFT_CREATED', more: {
        'documentReceived': true, 'draftCreated': true, 'draftCNumber': 'J33D10003057', 'draftCreatedBy': 'VASUNTRA',
        'draftCreatedDate': '2026-10-09 11:20:00', 'approvedDate': '2026-10-09', 'sealById': 31, 'sealBy': 'RAVI-OPERATION',
      }));
      expect(r.id, 7);
      expect(r.jobNo, 'MY002605939');
      expect(r.formType, 'K8');
      expect(r.estimatedDate, DateTime(2026, 10, 12, 9));
      expect(r.remarks, '');
      expect(r.draftCNumber, 'J33D10003057');
      expect(r.draftCreatedDate, DateTime(2026, 10, 9, 11, 20));
      expect(r.approvedDate, DateTime(2026, 10, 9));
      expect(r.sealById, 31);
      expect(r.status, 'DRAFT_CREATED');
      expect(r.cancelled, isFalse);
    });

    test('is overdue once the estimate has passed without a draft', () {
      final now = DateTime(2026, 10, 13, 8);
      expect(ForwardingRequest.fromJava(javaRow()).isOverdue(now), isTrue);
      expect(ForwardingRequest.fromJava(javaRow(status: 'DRAFT_CREATED', more: {'draftCreated': true})).isOverdue(now), isFalse);
      expect(ForwardingRequest.fromJava(javaRow(status: 'CANCELLED')).isOverdue(now), isFalse);
      expect(ForwardingRequest.fromJava(javaRow(more: {'estimatedDate': '2026-10-20 09:00:00'})).isOverdue(now), isFalse);
    });

    test('ladder and labels', () {
      expect(forwardingStepIndex('REQUESTED'), 0);
      expect(forwardingStepIndex('RELEASED'), 5);
      expect(forwardingStepIndex('CANCELLED'), -1);
      expect(forwardingStatusLabel('DOCUMENTS_RECEIVED'), 'Documents received');
    });
  });

  group('ForwardingRequestTicks', () {
    const blank = ForwardingRequestTicks();
    final today = DateTime(2026, 10, 9);

    test('ticking released ticks every step below and dates the approval today', () {
      final t = blank.step(ForwardingStep.released, true, today: today);
      expect(t.documentReceived, isTrue);
      expect(t.draftCreated, isTrue);
      expect(t.submitted, isTrue);
      expect(t.approved, isTrue);
      expect(t.released, isTrue);
      expect(t.approvedDate, '2026-10-09');
    });

    test('unticking documents clears every step above and its references, keeps the seal people', () {
      final full = blank.copyWith(documentReceived: true, draftCreated: true, cNumber: 'C1', submitted: true, submittedRef: 'R1',
          approved: true, approvedDate: '2026-10-09', released: true, releaseNo: 'K8-1', sealById: 31);
      final t = full.step(ForwardingStep.documentReceived, false);
      expect(t.documentReceived, isFalse);
      expect(t.cNumber, '');
      expect(t.submittedRef, '');
      expect(t.approvedDate, '');
      expect(t.releaseNo, '');
      expect(t.sealById, 31);
    });

    test('blockers and the Java body', () {
      expect(blank.step(ForwardingStep.draftCreated, true).blocker, contains('C Number'));
      expect(blank.step(ForwardingStep.released, true).copyWith(cNumber: 'C1').blocker, contains('release number'));
      final t = blank.step(ForwardingStep.submitted, true).copyWith(cNumber: ' C1 ', submittedRef: '', breakSealById: 9);
      expect(t.blocker, isNull);
      expect(t.toJava(), {
        'documentReceived': true, 'draftCreated': true, 'cNumber': 'C1', 'submitted': true, 'submittedRef': null,
        'approved': false, 'approvedDate': null, 'released': false, 'releaseNo': null, 'sealByRefId': null, 'breakSealByRefId': 9,
      });
    });
  });

  group('ForwardingRequestFilter', () {
    test('defaults: the coming week for the team, a month each way for mine', () {
      final now = DateTime(2026, 10, 8, 15, 30);
      final team = ForwardingRequestFilter.defaults(now: now);
      expect(team.fromDate, '2026-10-08');
      expect(team.toDate, '2026-10-15');
      expect(team.mine, isFalse);
      final mine = ForwardingRequestFilter.defaults(now: now, mine: true);
      expect(mine.fromDate, '2026-09-08');
      expect(mine.toDate, '2026-11-07');
      expect(mine.toJava()['mine'], isTrue);
      expect(mine.toJava()['jobNo'], isNull);
    });
  });

  group('ForwardingRequestApi', () {
    late QueueAdapter adapter;
    late ForwardingRequestApi api;

    setUp(() {
      adapter = QueueAdapter();
      api = ForwardingRequestApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
    });

    test('create posts the form types and the estimate in the Java shape', () async {
      adapter.replies.add((201, jsonEncode(ok([javaRow(id: 101), javaRow(id: 102, more: {'formType': 'K1'})]))));
      final rows = await api.create(saleOrderId: 910, formTypes: ['K8', 'K1'], estimatedDate: DateTime(2026, 10, 12, 9), remarks: ' 2 pallets ');
      expect(rows.map((r) => r.id), [101, 102]);
      final req = adapter.requests.single;
      expect(req.uri.toString(), 'https://java.test/api/forwarding-requests');
      expect(req.method, 'POST');
      expect(req.data, {'saleOrderId': 910, 'formTypes': ['K8', 'K1'], 'estimatedDate': '2026-10-12 09:00:00', 'remarks': '2 pallets'});
    });

    test('search and saveTicks hit the shared endpoints', () async {
      adapter.replies.add((200, jsonEncode(ok([javaRow()]))));
      final rows = await api.search(ForwardingRequestFilter.defaults(now: DateTime(2026, 10, 8)));
      expect(rows.single.jobNo, 'MY002605939');
      expect(adapter.requests.last.uri.toString(), 'https://java.test/api/forwarding-requests/search');

      adapter.replies.add((200, jsonEncode(ok(javaRow(status: 'DRAFT_CREATED', more: {'draftCreated': true, 'draftCNumber': 'C1'})))));
      final saved = await api.saveTicks(7, const ForwardingRequestTicks(documentReceived: true, draftCreated: true, cNumber: 'C1'));
      expect(saved.status, 'DRAFT_CREATED');
      expect(adapter.requests.last.uri.toString(), 'https://java.test/api/forwarding-requests/7/ticks');
      expect(adapter.requests.last.method, 'PUT');
    });

    test('a refusal arrives as the server message', () async {
      adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400, 'Message': 'Enter the C Number to save Draft created'})));
      await expectLater(
        api.saveTicks(7, const ForwardingRequestTicks(draftCreated: true)),
        throwsA(isA<ApiFailure>().having((e) => e.toString(), 'message', contains('C Number'))),
      );
    });
  });
}
