import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart';

import '../../core/network/java_api_client_test.dart' show QueueAdapter;

/// Payment Pending from the shared Java board (ported from .NET SelectPendingPayment).
void main() {
  final board = {
    'IsSuccess': true,
    'Message': 'Success',
    'Data1': {
      'month': '2026-10',
      'bills': [
        {'id': 1, 'expenseName': 'UTILITY', 'subExpenseName': 'TNB', 'amount': 120.5, 'dueDate': '2026-10-05',
          'paid': false, 'paidAmount': 0, 'paidDate': null, 'bankName': 'MBB', 'voucherAmount': 0},
        {'id': 2, 'expenseName': 'TENANCY', 'subExpenseName': 'OFFICE', 'amount': 3000, 'dueDate': '2026-10-01',
          'paid': true, 'paidAmount': 3000, 'paidDate': '01/10/2026', 'bankName': '', 'voucherAmount': 3000},
      ],
      'vendors': [
        {'supplierId': 9, 'supplierName': 'KWANG HENG', 'outstanding': 500,
          'bills': [{'billMasterId': 77, 'dueDate': '2026-09-30', 'outstanding': 500, 'paid': 0}]},
      ],
      'summary': {},
    },
  };

  late QueueAdapter adapter;
  late PaymentViewRepository repo;

  setUp(() {
    adapter = QueueAdapter();
    repo = PaymentViewRepository(dio: Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test('all: bills and the supplier line; details are the unpaid', () async {
    adapter.replies.add((200, jsonEncode(board)));

    final lists = await repo.fetchPaymentPending(comid: 6, expenseFilter: 0, paidFilter: 0, month: DateTime(2026, 10, 2));

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/pending-payments/board?companyId=6&month=2026-10');
    expect(lists.masters.map((m) => m.SubExpenseName), ['KWANG HENG', 'OFFICE', 'TNB']);
    final tnb = lists.masters.firstWhere((m) => m.id == 1);
    expect(tnb.Amount, 120.5);
    expect(tnb.ExpenceDueDate, 5);
    expect(tnb.Paidstatus, 0);
    expect(lists.details.map((d) => d.SubExpenseName), ['TNB', 'KWANG HENG']);
    expect(lists.details.last.DueDate, '30/09/2026');
  });

  test('expense and paid filters', () async {
    adapter.replies
      ..add((200, jsonEncode(board)))
      ..add((200, jsonEncode(board)));

    final utility = await repo.fetchPaymentPending(comid: 6, expenseFilter: 3, paidFilter: 0);
    expect(utility.masters.map((m) => m.ExpenseName), ['UTILITY']);

    final paid = await repo.fetchPaymentPending(comid: 6, expenseFilter: 0, paidFilter: 1);
    expect(paid.masters.map((m) => m.SubExpenseName), ['KWANG HENG', 'OFFICE']);
  });
}
