import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The truck entry lists and the spare parts save on the shared Java API (truck-entries-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late TruckEntriesApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = TruckEntriesApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the three lists send the company and the days and answer the Java rows', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 41, 'truckName': 'VBC 5521', 'spareParts': 'PAD', 'amount': 80.5, 'entryDate': '2026-10-05'}]))))
      ..add((200, jsonEncode(ok([{'id': 7, 'truckName': 'VBC 5521', 'summon': 'SPEED', 'country': 'MY'}]))))
      ..add((200, jsonEncode(ok([{'id': 3, 'vehicleName': 'WXY 1', 'statusName': 'DONE'}]))));

    expect((await api.spareParts(fromDate: '2026-10-01', toDate: '2026-10-05')).single['spareParts'], 'PAD');
    expect(last().uri.toString(), 'https://java.test/api/truck-spare-parts/entries?companyId=6&fromDate=2026-10-01&toDate=2026-10-05');
    expect((await api.summons(fromDate: '2026-10-01', toDate: '2026-10-05T00:00:00')).single['summon'], 'SPEED');
    expect(last().uri.toString(), 'https://java.test/api/summons/entries?companyId=6&fromDate=2026-10-01&toDate=2026-10-05');
    expect((await api.spotSales(fromDate: '2026-10-01', toDate: '2026-10-05')).single['statusName'], 'DONE');
    expect(last().uri.toString(), 'https://java.test/api/sport-sale-orders/entries?companyId=6&fromDate=2026-10-01&toDate=2026-10-05');
  });

  test('a spare parts save is multipart: the entry as JSON and the documents', () async {
    final dir = await Directory.systemTemp.createTemp('spare');
    final photo = File('${dir.path}/a.jpg')..writeAsBytesSync([1, 2, 3]);
    adapter.replies.add((200, jsonEncode(ok(41))));

    expect(await api.saveSpareParts(truckId: 3, spareParts: 'PAD', amount: 80.5, entryDate: '2026-10-05', files: [photo]), 41);

    expect(last().method, 'POST');
    expect(last().uri.toString(), 'https://java.test/api/truck-spare-parts/entries?companyId=6');
    final form = last().data as FormData;
    expect(form.files.map((f) => f.key), ['entry', 'files']);
    final entry = form.files.first.value;
    expect(entry.contentType.toString(), startsWith('application/json'));
    expect(form.files.last.value.filename, 'a.jpg');
    await dir.delete(recursive: true);
  });

  test('a refused save is the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'Select a truck'})));

    expect(() => api.saveSpareParts(truckId: 0, spareParts: 'PAD', amount: 1, entryDate: '2026-10-05'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Select a truck')));
  });

  test('summon and spot sale saves send their Java entries', () async {
    adapter.replies
      ..add((200, jsonEncode(ok(51))))
      ..add((200, jsonEncode(ok(71))));

    expect(await api.saveSummon(truckId: 3, summon: 'SPEEDING', country: 'Malaysia', portPass: '', truckLcnMnt: '',
        levy: '', fuel: '', amount: 300, entryDate: '2026-10-05'), 51);
    expect(last().uri.toString(), 'https://java.test/api/summons/entries?companyId=6');
    var form = last().data as FormData;
    expect(form.files.single.key, 'entry');

    expect(await api.saveSpotSale(jobTypeId: 2, jobStatusId: 4, employeeId: 15, vehicleName: 'WXY 1', awbNo: 'AWB1',
        quantity: '3', totalWeight: '120', port: 'WESTPORT'), 71);
    expect(last().uri.toString(), 'https://java.test/api/sport-sale-orders/entries?companyId=6');
    form = last().data as FormData;
    final entry = jsonDecode(await utf8.decodeStream(form.files.single.value.clone().finalize()));
    expect(entry, {'id': 0, 'customerRefId': 0, 'jobMasterRefId': 2, 'employeeRefId': 15, 'jStatus': 4,
      'awbNo': 'AWB1', 'quantity': '3', 'totalWeight': '120', 'vehicleName': 'WXY 1', 'port': 'WESTPORT'});
  });
}
