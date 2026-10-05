import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/change_status_page.dart';
import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/features/dashboard/common_tabs/pettycash/data/change_status_loader.dart';
import '../../core/network/java_api_client_test.dart' show QueueAdapter;
import '../../support/local_fonts.dart';

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The Change Status page loads its one petty cash from the shared Java API
/// (billorder-on-shared-java-api).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);
  late QueueAdapter adapter;
  late ChangeStatusLoader loader;

  setUp(() {
    adapter = QueueAdapter();
    loader = ChangeStatusLoader(
        api: PettyCashApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
            companyId: () => 17));
  });

  for (final id in [0, 9]) {
    testWidgets('ID $id preserves load trigger and screen', (tester) async {
      adapter.replies.add((200, jsonEncode(ok({
        'id': 9, 'cnumberDisplay': 'PC00009', 'spettyCashDate': '01/10/2026', 'employeeName': 'ANNA',
        'amount': '25.50', 'pettyCashDetails': [{'id': 3, 'items': 'TAXI', 'amount': 25.5, 'notes': ''}],
      }))));
      await tester.pumpWidget(MaterialApp(home: ChangeStatusPage(masterId: id, loader: loader)));
      await tester.pumpAndSettle();
      expect(find.text('Change Status'), findsOneWidget);
      expect(find.text('Selected ID: $id'), findsOneWidget);
      if (id == 0) {
        expect(adapter.requests, isEmpty);
      } else {
        expect(adapter.requests.single.uri.toString(),
            'https://java.test/api/petty-cash-masters/edit?companyId=17&id=9');
        final state = tester.state<ChangeStatusPageState>(find.byType(ChangeStatusPage));
        expect(state.pettycashMaster.single.cNumberDisplay, 'PC00009');
        expect(state.pettycashMaster.single.pettyCashDate, DateTime(2026, 10, 1));
        expect(state.pettycashMaster.single.companyRefId, 17);
        expect(state.pettycashDetails.single.items, 'TAXI');
        expect(state.pettycashDetails.single.pettyCashMasterRefId, 9);
      }
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  }
}
