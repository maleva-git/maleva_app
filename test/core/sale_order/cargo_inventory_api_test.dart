import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/inventory_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/sale_order/cargo_inventory_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The Inventory report off .NET CustomerApp/SelectAllInventoryt (inventory-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late CargoInventoryApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = CargoInventoryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6);
  });

  test('pending lines of a port read the Java rows', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'id': 40, 'sourceTable': 'SaleOrderMaster', 'cnumberDisplay': 'MY00040', 'jobStatus': 'IN WAREHOUSE',
        'jobType': 'IMPORT', 'customerName': 'ACME', 'offVesselName': 'MV OFF', 'eta': '2026-10-03T09:00:00',
        'cargoQty': '3 PLT', 'cargoWeight': '120', 'employeeName': 'ANNA', 'oiDateIn': '01/10/2026'},
    ]))));

    final rows = await api.lines(portType: 1, customerId: 9, pending: true, fromDate: '2026-10-01', toDate: '2026-10-05');

    expect(adapter.requests.single.uri.path, '/api/sale-orders/inventory');
    expect(adapter.requests.single.queryParameters,
        {'companyId': 6, 'portType': 1, 'customerId': 9, 'pending': true});
    final line = InventoryModel.fromJava(rows.single);
    expect([line.id, line.CNumberDisplay, line.jobStatus, line.cargoQTY, line.eta, line.oiDateIn],
        [40, 'MY00040', 'IN WAREHOUSE', '3 PLT', '2026-10-03T09:00:00', '01/10/2026']);
  });

  test('a period sends its dates', () async {
    adapter.replies.add((200, jsonEncode(ok([]))));

    await api.lines(portType: 2, fromDate: '2026-10-01', toDate: '2026-10-05');

    expect(adapter.requests.single.queryParameters, {'companyId': 6, 'portType': 2, 'customerId': 0,
      'pending': false, 'fromDate': '2026-10-01', 'toDate': '2026-10-05'});
  });

  test('a refusal is the server message', () async {
    adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400,
      'Message': 'From Date is greater than To Date!'})));

    expect(() => api.lines(portType: 1, fromDate: '2026-10-05', toDate: '2026-10-01'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'From Date is greater than To Date!')));
  });
}
