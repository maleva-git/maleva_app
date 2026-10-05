import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/reports/transaction_report_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The reports moved off .NET TransactionReportApp (transaction-reports-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late TransactionReportApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = TransactionReportApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6, javaBaseUrl: 'https://java.test');
  });

  RequestOptions last() => adapter.requests.last;

  test('driver salary reads the detailed report rows', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'rtiNo': 'RTI000004501', 'jobNo': 'MY11', 'pickupDate': '01/09/2026 08:00:00', 'amount': 1234.56},
    ]))));

    final rows = await api.driverJobs(fromDate: '2026-09-01', toDate: '2026-09-30');

    expect(last().uri.toString(),
        'https://java.test/api/rti-masters/driver-report/detailed/rows?companyId=6&fromDate=2026-09-01&toDate=2026-09-30');
    expect(rows.single['rtiNo'], 'RTI000004501');
  });

  test('the receipt view reads the period balances', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'id': 9, 'customerName': 'ACME', 'balance': 120.5, 'billAmount': 120.5},
    ]))));

    final rows = await api.customerBalances(fromDate: '2024-01-01', toDate: '2026-10-05');

    expect(last().uri.path, '/api/customer-reports/period-balance/rows');
    expect(last().queryParameters, {'companyId': 6, 'fromDate': '2024-01-01', 'toDate': '2026-10-05'});
    expect(rows.single['customerName'], 'ACME');
  });

  test('the pre-alert PDF sends the filters and opens the ticket link on the Java host', () async {
    adapter.replies.add((200, jsonEncode(ok({'Ticket': 't1', 'FileName': 'Pre-Alert.pdf',
      'Url': '/api/transaction/pre-alert-report/pdf/t1/Pre-Alert.pdf'}))));

    final url = await api.preAlertUrl(fromDate: '2026-10-01', toDate: '2026-10-31', customerId: 9, port: 'PKG',
        eta: true, etaType: 2, deliveryDone: true);

    expect(url, 'https://java.test/api/transaction/pre-alert-report/pdf/t1/Pre-Alert.pdf');
    expect(last().uri.path, '/api/transaction/pre-alert-report/ticket');
    expect(last().queryParameters, {
      'companyId': 6, 'fromDate': '2026-10-01', 'toDate': '2026-10-31', 'customerId': 9, 'port': 'PKG',
      'discussion': false, 'eta': true, 'etaType': 2, 'deliveryDone': true, 'consolidated': false,
    });
  });

  test('no pre-alert jobs is the server message', () async {
    adapter.replies.add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'No Record Found !!!'})));

    expect(() => api.preAlertUrl(fromDate: '2026-10-01', toDate: '2026-10-31'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'No Record Found !!!')));
  });
}
