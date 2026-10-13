import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// A PTP call as the Java API answers it (api-contract.md of vessel-master-and-ptp-schedule).
const Map<String, dynamic> callJson = {
  'id': 412,
  'port': 'PTP',
  'vesselName': 'MAERSK RIO NEGRO',
  'vesselCode': 'I1X',
  'lineId': 'MAE',
  'voyage': '641S',
  'scn': '269EK6',
  'arriveAt': '2026-10-10T06:30',
  'arriveEstimated': true,
  'departAt': '2026-10-11T17:00',
  'departEstimated': false,
  'dryCutoff': '2026-10-09T20:00',
  'reeferCutoff': null,
  'cfsCutoff': '2026-10-10T06:30',
  'hazardCutoff': null,
  'listed': true,
  'lastSeenAt': '2026-10-12T09:15',
};

/// The vessel master on the shared Java API (vessel-master-and-ptp-schedule).
void main() {
  late QueueAdapter adapter;
  late VesselMasterApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = VesselMasterApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test('suggest sends q, leg and port and reads a vessel with calls and one without', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'vesselMasterId': 88, 'vesselName': 'MAERSK RIO NEGRO', 'vesselCode': 'I1X', 'lineId': 'MAE',
        'matchedAlias': null, 'calls': [callJson]},
      {'vesselMasterId': null, 'vesselName': 'RIO GRANDE', 'vesselCode': null, 'lineId': null,
        'matchedAlias': 'RIO GRAND', 'calls': []},
    ]))));

    final rows = await api.suggest('RIO NEG', leg: VesselLeg.off, port: 'PTP');

    expect(adapter.requests.single.uri.toString(),
        'https://java.test/api/vessel-masters/suggest?q=RIO+NEG&leg=OFF&port=PTP');
    expect(rows, hasLength(2));
    final call = rows.first.calls.single;
    expect(rows.first.vesselMasterId, 88);
    expect(call.id, 412);
    expect(call.voyage, '641S');
    expect(call.scn, '269EK6');
    expect(call.arriveAt, '2026-10-10T06:30', reason: 'kept as Java sent it, to send back unchanged');
    expect(call.arrive, DateTime(2026, 10, 10, 6, 30));
    expect(call.arriveEstimated, isTrue);
    expect(call.depart, DateTime(2026, 10, 11, 17, 0));
    expect(call.departEstimated, isFalse);
    expect(call.reeferCutoff, isNull);
    expect(rows.last.vesselMasterId, isNull, reason: 'a PTP vessel this company has not used yet');
    expect(rows.last.matchedAlias, 'RIO GRAND');
    expect(rows.last.calls, isEmpty);
  });

  test('a call with PTP saying None has no SCN', () {
    final call = PtpCall.fromJava({...callJson, 'scn': null, 'listed': false});
    expect(call.scn, isNull);
    expect(call.listed, isFalse);
  });

  test('similar reads SAME, CLOSE and NONE', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'match': 'CLOSE', 'vesselMasterId': 91, 'vesselName': 'CMA CGM PETRA'}))))
      ..add((200, jsonEncode(ok({'match': 'NONE', 'vesselMasterId': null, 'vesselName': null}))));

    final close = await api.similar('CMA CGM PETRON');
    final none = await api.similar('NEW ONE');

    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/vessel-masters/similar?name=CMA+CGM+PETRON');
    expect(close.match, SimilarVessel.close);
    expect(close.vesselMasterId, 91);
    expect(close.vesselName, 'CMA CGM PETRA');
    expect(none.match, SimilarVessel.none);
    expect(none.vesselName, isNull);
  });

  test('saveLinks sends both legs as the contract names them and reads the linked legs', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'leg': 'OFF', 'vesselMasterId': 88, 'vesselName': 'MAERSK RIO NEGRO', 'ptpVesselCallId': 412, 'linkedBy': 'PICKED'},
    ]))));

    final linked = await api.saveLinks(51234, const [
      VesselLinkRequest(leg: VesselLeg.loading, vesselName: 'CMA CGM PETRON'),
      VesselLinkRequest(leg: VesselLeg.off, vesselName: 'MAERSK RIO NEGRO', vesselMasterId: 88, ptpVesselCallId: 412),
    ]);

    final request = adapter.requests.single;
    expect(request.method, 'PUT');
    expect(request.uri.toString(), 'https://java.test/api/sale-orders/51234/vessel-links');
    expect(request.data, {
      'legs': [
        {'leg': 'LOADING', 'vesselName': 'CMA CGM PETRON', 'vesselMasterId': null, 'ptpVesselCallId': null},
        {'leg': 'OFF', 'vesselName': 'MAERSK RIO NEGRO', 'vesselMasterId': 88, 'ptpVesselCallId': 412},
      ]
    });
    expect(linked.single.linkedBy, 'PICKED');
    expect(linked.single.ptpVesselCallId, 412);
  });

  test('links reads a saved job\'s legs with the linked call\'s current times', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'leg': 'OFF', 'vesselMasterId': 88, 'vesselName': 'MAERSK RIO NEGRO', 'ptpVesselCallId': 412, 'linkedBy': 'PICKED',
        'call': callJson},
      {'leg': 'LOADING', 'vesselMasterId': 91, 'vesselName': 'CMA CGM PETRON', 'ptpVesselCallId': null, 'linkedBy': 'TYPED',
        'call': null},
    ]))));

    final links = await api.links(21732);

    final request = adapter.requests.single;
    expect(request.method, 'GET');
    expect(request.uri.toString(), 'https://java.test/api/sale-orders/21732/vessel-links');
    expect(links.first.call?.arrive, DateTime(2026, 10, 10, 6, 30));
    expect(links.last.call, isNull);
  });

  test('a refusal keeps the server message', () async {
    adapter.replies.add((403, jsonEncode({'status': 403, 'error': 'Forbidden', 'message': 'Employees only'})));

    expect(() => api.suggest('RI', leg: VesselLeg.loading),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Employees only')));
  });
}
