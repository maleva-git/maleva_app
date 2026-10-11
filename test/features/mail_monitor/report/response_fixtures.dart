import 'package:maleva/core/mailmonitor/response_report_models.dart';

/// A report row as the Java API sends it, with the web fixture's defaults
/// (`maleva-front-end/src/features/mail-monitor/report/model/response.fixtures.ts`).
Map<String, dynamic> rowJson([Map<String, dynamic> over = const {}]) => {
      'mailboxId': 1,
      'address': 'cs1@maleva.com.my',
      'displayName': 'customerservice cs1',
      'kind': 'SHARED',
      'department': 'Customer service',
      'owners': ['Employee A'],
      'targetMinutes': 15,
      'reportFrom': '2026-10-01',
      'sentFolderFound': true,
      'scannedAt': '2026-10-07T04:00:00Z',
      'scanError': null,
      'received': 10,
      'replied': 9,
      'withinTarget': 8,
      'withinTargetPct': 80,
      'avgMinutes': 20,
      'medianMinutes': 9,
      'p90Minutes': 45,
      'maxMinutes': 370,
      'waiting': 1,
      'daily': [
        {'day': '2026-10-07', 'received': 10, 'withinTarget': 8, 'medianMinutes': 9},
      ],
      ...over,
    };

ResponseRow responseRow([Map<String, dynamic> over = const {}]) => ResponseRow.fromJava(rowJson(over));

Map<String, dynamic> reportJson(List<Map<String, dynamic>> rows, {String from = '2026-10-05', String to = '2026-10-11'}) =>
    {'from': from, 'to': to, 'company': rowJson(), 'mailboxes': rows};
