import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/models/fuelentry_model.dart';
import 'package:maleva/features/transport/models/fuelselect_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The shared Java /api/fuel-entries, read as it answers (change fuel-entry-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late FuelEntryApi api;

  final javaRow = {
    'id': 11, 'cNumberDisplay': 'FE000000011', 'saleDate': '2026-10-02', 'truckRefId': 3, 'truckName': 'VBC 5521',
    'driverRefId': 7, 'driverName': 'RAVI', 'aliter': 50.0, 'aAmount': 100.0, 'pliter': 55.0, 'pAmount': 110.0,
    'pRate': 2.0, 'gliter': 52.0, 'gAmount': 104.0, 'diffLiter': 3.0, 'diffAmount': 6.0, 'fStatus': 1,
  };

  setUp(() {
    adapter = QueueAdapter();
    api = FuelEntryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the list sends the company, dates, truck and driver and answers the items', () async {
    adapter.replies.add((200, jsonEncode(ok({'items': [javaRow], 'entriesTotal': 100.0}))));

    final rows = await api.list(fromDate: '2026-10-01', toDate: '2026-10-02T00:00:00', truckId: 3, driverId: 7);

    expect(rows.single['id'], 11);
    expect(last().uri.toString(),
        'https://java.test/api/fuel-entries?companyRefId=6&fromDate=2026-10-01&toDate=2026-10-02&truckRefId=3&driverRefId=7');
  });

  test('next number, save and delete', () async {
    adapter.replies
      ..add((200, jsonEncode(ok('FE000000072'))))
      ..add((200, jsonEncode(ok({'id': 72}))))
      ..add((200, jsonEncode(ok(null))));

    expect(await api.nextNumber(), 'FE000000072');
    expect(last().uri.toString(), 'https://java.test/api/fuel-entries/next-no?companyRefId=6');

    expect((await api.save({'id': 0, 'truckRefId': 3, 'aliter': 50.5}))['id'], 72);
    expect(last().method, 'POST');
    expect(last().data, {'id': 0, 'truckRefId': 3, 'aliter': 50.5, 'companyRefId': 6});

    await api.delete(11, mobile: true);
    expect(last().method, 'DELETE');
    expect(last().uri.toString(), 'https://java.test/api/fuel-entries/11?companyRefId=6&mobile=true');
  });

  test('a refusal is the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'No Truck Assigned! Please ask the office to assign a truck first.'})));

    expect(() => api.save({'id': 0}),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', startsWith('No Truck Assigned'))));
  });

  test('the models read the Java row, with the web difference columns', () {
    final m = FuelEntryModel.fromJava(javaRow);
    expect([m.id, m.entryNo, m.entryDate, m.truckId, m.aLiter, m.aAmount, m.pRate], [11, 'FE000000011', '02/10/2026', 3, 50.0, 100.0, 2.0]);
    expect([m.dpLiter, m.dpAmount, m.dgLiter, m.dgAmount], [5.0, 10.0, 3.0, 6.0]);

    final r = FuelselectModel.fromJava({...javaRow, 'aamount': 99.0}..remove('aAmount'));
    expect([r.sSaleDate, r.truckRefId, r.aAmount, r.dPliter, r.dGAmount], ['02/10/2026', 3, 99.0, 5.0, 6.0],
        reason: 'a field is read whatever case Jackson writes it in');
  });

  test('the maintenance form saves the Java request', () async {
    SharedPreferences.setMockInitialValues({'EmpRefId': 15});
    await AppPreferences.init();
    final m = FuelEntryModel(id: 11, entryDate: '02/10/2026', truckId: 3, driverId: 0, aLiter: 50, aAmount: 100, pRate: 2);
    final body = m.toJava();
    expect(body['saleDate'], '2026-10-02');
    expect(body['truckRefId'], 3);
    expect(body['driverRefId'], isNull);
    expect(body['employeeRefId'], 15);
    expect(body['fStatus'], 0);
    expect(body.containsKey('pAmount'), isFalse, reason: 'the server recomputes the amounts');
  });
}
