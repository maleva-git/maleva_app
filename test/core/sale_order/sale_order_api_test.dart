import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The shared Java sale order APIs, read as they answer (change sale-order-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late SaleOrderApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = SaleOrderApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;
  String uri() => last().uri.toString();

  test('search sends the filter with the company and slash dates; rows keep their names', () async {
    adapter.replies.add((200, jsonEncode(ok({
          'salemaster': [{'Id': 40, 'BillNoDisplay': 'MY00040', 'NetAmt': 12.5}],
          'saledetails': [{'SaleRefId': 40, 'ProductName': 'FORWARDING'}],
        }))));

    final list = await api.search({'Search': '40', 'ETA': false}, from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 2));

    expect(uri(), 'https://java.test/api/sale-orders/search');
    expect(last().data, {'Search': '40', 'ETA': false, 'Comid': 6, 'Fromdate': '2026/10/01', 'Todate': '2026/10/02'});
    expect(list.masters.single['BillNoDisplay'], 'MY00040');
    expect(list.details.single['SaleRefId'], 40);
  });

  test('the TV list asks for westport in the query', () async {
    adapter.replies.add((200, jsonEncode(ok({'salemaster': [], 'saledetails': []}))));
    await api.tvSearch({}, westport: true);
    expect(uri(), 'https://java.test/api/sale-orders/tv-search?westport=true');
  });

  test('job numbers and the edit read', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 40, 'cNumber': 40, 'forwardingSMKNo': 'SMK1'}]))))
      ..add((200, jsonEncode(ok({
            'saleOrderMaster': {'id': 40, 'cNumber': 40, 'jobMasterRefId': 3, 'jStatus': 5},
            'saleOrderDetails': [{'itemMasterRefId': 9}],
            'pickupDetails': [{'pickupAddress': 'PORT KLANG', 'pickupWeight': '10'}],
            'deliveryDetails': [],
            'forwardingDetails': null,
          }))));

    expect((await api.jobNumbers(1)).single['cNumber'], 40);
    expect(uri(), 'https://java.test/api/sale-orders/job-numbers?companyId=6&jobType=1');

    final order = await api.edit(saleOrderNo: 40);
    expect(uri(), 'https://java.test/api/sale-orders/edit?companyId=6&saleOrderNo=40');
    expect(order.id, 40);
    expect(order.jobMasterRefId, 3);
    expect(order.jStatus, 5);
    expect(order.details.single['itemMasterRefId'], 9);
    expect(order.pickups.single['pickupAddress'], 'PORT KLANG');
    expect(order.forwarding, isEmpty);
  });

  test('a new order is a POST to /save, an existing one a PUT to /{id}', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'id': 41}))))
      ..add((200, jsonEncode(ok({'id': 40}))));

    await api.save({'id': 0, 'cNumber': 0});
    expect(last().method, 'POST');
    expect(uri(), 'https://java.test/api/sale-orders/save');

    await api.save({'id': 40, 'cNumber': 40});
    expect(last().method, 'PUT');
    expect(uri(), 'https://java.test/api/sale-orders/40');
  });

  test('the field updates send only their fields', () async {
    for (var i = 0; i < 5; i++) {
      adapter.replies.add((200, jsonEncode(ok(40))));
    }

    await api.updateForwarding(40, {'forwardingExitRef': 'X1'});
    expect(uri(), 'https://java.test/api/sale-orders/40/forwarding?companyId=6');
    expect(last().data, {'forwardingExitRef': 'X1'});

    await api.updateBoarding(40, statusId: 7, start: DateTime(2026, 10, 2, 9, 5));
    expect(uri(), 'https://java.test/api/sale-orders/40/boarding?companyId=6');
    expect(last().data, {'statusId': 7, 'boardingStartTime': '2026-10-02T09:05:00'});

    await api.sendBoardingMail(40, statusName: 'BOARDED Done', imageUrls: ['a.jpg']);
    expect(last().method, 'POST');
    expect(last().data, {'statusName': 'BOARDED Done', 'imageUrls': ['a.jpg']});

    await api.updateAirFreight(40, statusId: 4, awbNo: 'AWB1');
    expect(uri(), 'https://java.test/api/sale-orders/40/air-freight?companyId=6');

    await api.updateTrip(40, remarks1: 'R', origin: 'A', destination: 'B');
    expect(last().data, {'remarks1': 'R', 'origin': 'A', 'destination': 'B'});
  });

  test('the vessel update always sends both officer sides, so none is cleared by omission', () async {
    adapter.replies.add((200, jsonEncode({'ok': true, 'message': 'Sale order updated successfully'})));

    await api.vesselUpdate(40, etb: '2026-10-02 08:00:00', loadingOfficers: [11, 12], offOfficers: SaleOrderApi.officers(
        {'oBoardingOfficerRefid': 21, 'oBoardingOfficer1Refid': null, 'oBoardingOfficer2Refid': 23}, 'O'));

    expect(uri(), 'https://java.test/api/vessel-plannings/sale-order-update');
    expect(last().data, {
      'saleOrderId': 40,
      'companyId': 6,
      'etb': '2026-10-02 08:00:00',
      'loadingOfficer1': 11,
      'loadingOfficer2': 12,
      'loadingOfficer3': 0,
      'offOfficer1': 21,
      'offOfficer2': 0,
      'offOfficer3': 23,
    });
  });

  test('a refused vessel update is the server message', () async {
    adapter.replies.add((200, jsonEncode({'ok': false, 'message': 'Invalid Job Status ID'})));
    expect(() => api.vesselUpdate(40, loadingOfficers: const [], offOfficers: const []),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Invalid Job Status ID')));
  });

  test('the ticked jobs update sends only the dates given', () async {
    adapter.replies.add((200, jsonEncode({'requested': 2, 'updated': 2, 'skipped': 0, 'results': []})));

    await api.vesselUpdateMany([40, 41], eta: '2026-10-02 08:00:00');

    expect(uri(), 'https://java.test/api/vessel-plannings/sale-order-update-many');
    expect(last().data, {'companyId': 6, 'saleOrderIds': [40, 41], 'eta': '2026-10-02 08:00:00'});
  });

  test('the planning update sends back the job origin, destination, quantity and weight', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({
            'saleOrderMaster': {'id': 40, 'origin': 'PKG', 'destination': 'JB', 'originRefId': 3, 'destinationRefId': 4,
              'quantity': '2', 'totalWeight': '100'},
          }))))
      ..add((200, jsonEncode({'ok': true, 'message': 'Saved'})));

    await api.planningUpdate(40, pickupDate: '2026-10-02T08:00:00', wareHouseAddress: 'WH 1', employeeId: 7,
        pickups: [{'id': 5, 'address': 'PKG'}], removedPickupIds: [6]);

    expect(uri(), 'https://java.test/api/planing/update-dates');
    final body = last().data as Map;
    expect(body['origin'], 'PKG');
    expect(body['destination'], 'JB');
    expect(body['quantity'], '2');
    expect(body['totalWeight'], '100');
    expect(body['pickupDate'], '2026-10-02T08:00:00');
    expect(body['deliveryDate'], isNull);
    expect(body['pickups'], [{'id': 5, 'address': 'PKG'}]);
    expect(body['removedPickupIds'], [6]);
    expect(body.containsKey('deliveries'), isFalse);
  });

  test('reports: the DO path, and an un-invoiced job has no invoice report', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'Url': '/api/v1/sale-invoices/print/t1/DO.pdf'}))))
      ..add((200, jsonEncode(ok({'saleOrderId': 40, 'invoiced': false}))));

    final path = await api.doPrintPath(40);
    expect(path, '/api/v1/sale-invoices/print/t1/DO.pdf');
    expect(SaleOrderApi.reportUrl(path), endsWith('/api/v1/sale-invoices/print/t1/DO.pdf'));
    expect(SaleOrderApi.reportUrl('https://x/r.pdf'), 'https://x/r.pdf');

    expect(() => api.invoicePrintPath(40), throwsA(isA<ApiFailure>()));
  });
}
