import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/finance/bills_order_api.dart';
import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/core/models/shared/bill_view_model.dart';
import 'package:maleva/core/models/shared/pattycash_master_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Bills orders and petty cash off .NET BIllorderApp (billorder-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
  });

  test('pending bills orders read the Java rows', () async {
    adapter.replies.add((200, jsonEncode({'ok': true, 'data': {
      'billsOrderMaster': [{'id': 5, 'pstatus': 0, 'billNoDisplay': 'BO00005', 'billNoDisplay1': 'MY123',
        'supplierName': 'ACME', 'employeeName': 'ANNA', 'invoiceNo': 'INV-1', 'netAmt': 120.5}],
      'billsOrderDetails': [],
    }})));

    final rows = await BillsOrderApi(dio, companyId: () => 6).pending(fromDate: '2026-10-01', toDate: '2026-10-05');

    expect(adapter.requests.single.uri.path, '/api/bills-order/select-bills-order');
    expect(adapter.requests.single.queryParameters,
        {'comid': 6, 'fromdate': '2026-10-01', 'todate': '2026-10-05', 'status': 'Pending'});
    final bill = BillViewModel.fromJava(rows.single);
    expect([bill.Id, bill.PStatus, bill.BillNoDisplay, bill.BillNoDisplay1, bill.SupplierName, bill.NetAmt],
        [5, 0, 'BO00005', 'MY123', 'ACME', 120.5]);
  });

  test('a refused bills order list is the server message', () async {
    adapter.replies.add((400, jsonEncode({'ok': false, 'message': 'Company ID (comid) is required'})));

    expect(() => BillsOrderApi(dio, companyId: () => 0).pending(fromDate: '2026-10-01', toDate: '2026-10-05'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Company ID (comid) is required')));
  });

  test('petty cash searches the period and reads the Java rows', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': {
      'pettyCashMaster': [{'id': 2, 'cnumber': 2, 'cnumberDisplay': 'PC00002', 'spettyCashDate': '03/10/2026',
        'employeeName': 'ANNA', 'paymentStatus': 'PAID', 'amount': 40}],
      'pettyCashDetails': [{'id': 7, 'pettyCashMasterRefId': 2, 'items': 'FUEL', 'amount': 40}],
    }})));

    final data = await PettyCashApi(dio, companyId: () => 6).search(fromDate: '2026-10-01', toDate: '2026-10-05');

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/petty-cash-masters/search?companyId=6');
    expect(adapter.requests.single.data, {'fromDate': '2026-10-01', 'toDate': '2026-10-05'});
    final master = PattycashMasterModel.fromJava((data['pettyCashMaster'] as List).single, companyId: 6);
    expect([master.Id, master.cNumberDisplay, master.paymentStatus, master.amount, master.pettyCashDate],
        [2, 'PC00002', 'PAID', '40', DateTime(2026, 10, 3)]);
  });
}
