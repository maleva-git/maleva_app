import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fleet/outside_carrier_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Outside truck numbers and drivers on the shared Java API (app change d2-carrier-by-id).
void main() {
  late QueueAdapter adapter;
  late OutsideCarrierApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = OutsideCarrierApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test("one subcontractor's truck numbers", () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': [{'id': 3, 'plateNo': 'WA1229R', 'sizeClass': '40FT'}]})));

    final rows = await api.vehicles(68);

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/outside-vehicles?companyId=6&truckRefId=68');
    expect([rows.single.id, rows.single.plateNo, rows.single.sizeClass], [3, 'WA1229R', '40FT']);
  });

  test('add a truck number under the subcontractor row', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': {'id': 7, 'plateNo': 'WB1', 'sizeClass': '20FT', 'existing': true}})));

    final v = await api.addVehicle(truckRefId: 68, plateNo: 'WB1', sizeClass: '20FT');

    final sent = adapter.requests.single;
    expect([sent.method, sent.uri.toString()], ['POST', 'https://java.test/api/outside-vehicles?companyId=6']);
    expect(sent.data, {'truckMasterRefId': 68, 'plateNo': 'WB1', 'sizeClass': '20FT'});
    expect([v.id, v.existing], [7, true]);
  });

  test('drivers list and add; the id number is sent only when typed', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': [{'id': 9, 'driverName': 'ALI', 'mobileNo': '012'}]})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'id': 10, 'driverName': 'RAJU', 'mobileNo': '013'}})));

    final list = await api.drivers();
    final added = await api.addDriver(name: 'RAJU', mobileNo: '013', idType: 'IC', idNo: '  ');

    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/outside-drivers?companyId=6');
    expect([list.single.id, list.single.name], [9, 'ALI']);
    expect(adapter.requests.last.data, {'driverName': 'RAJU', 'mobileNo': '013'});
    expect(added.id, 10);
    expect(added.toString(), 'OutsideDriver(10)', reason: 'no mobile in logs');
  });
}
