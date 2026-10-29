import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/features/today_trips/driver_trip.dart';
import 'package:maleva/features/today_trips/today_trips_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRtiApi extends RtiApi {
  _FakeRtiApi() : super(Dio(), companyId: () => 6);

  @override
  Future<List<Map<String, dynamic>>> trips(String fromDay, String toDay) async {
    final today = isoDay(DateTime.now());
    return [
      {
        'rtiId': 1, 'rtiNo': 'RTI000010565', 'tripDay': today, 'truckName': 'VIPS 7151', 'tripOfDay': 1, 'tripsThatDay': 2,
        'stops': [
          {'kind': 'PICKUP', 'time': '${today}T23:00:00', 'place': 'INFINITY WESTPORT', 'jobId': 1, 'jobNo': 'MY002606308',
            'customer': 'A VERY LONG CUSTOMER NAME SDN BHD (MALAYSIA BRANCH OFFICE)', 'quantity': '12 PLTS', 'pic': 'Ms. Lew 017-4152233 / Koko 011-26264962'},
          {'kind': 'STOP', 'time': '${today}T23:30:00', 'place': 'WESTPORT', 'activity': 'SEAL,BREAK_SEAL', 'agentName': 'AHMAD FAUZAN_FOWARDING', 'agentMobile': '012-3456789'},
          {'kind': 'DELIVERY', 'time': '${today}T23:50:00', 'place': 'SINGAPORE', 'jobId': 1, 'jobNo': 'MY002606308'},
        ],
        'jobs': [{'lineId': 1, 'jobId': 1, 'jobNo': 'MY002606308'}],
        'seenAt': null,
        'changes': [
          {'at': '${today}T21:40:00', 'kind': 'CHANGED', 'lines': ['Pickup MY002606308 INFINITY WESTPORT: 29/10 07:00 → 29/10 08:30']},
        ],
      },
    ];
  }
}

void main() {
  testWidgets('the Today tab shows the day, the next stop and the trip at phone width', (tester) async {
    SharedPreferences.setMockInitialValues({});
    if (sl.isRegistered<RtiApi>()) sl.unregister<RtiApi>();
    sl.registerSingleton<RtiApi>(_FakeRtiApi());
    tester.view.physicalSize = const Size(360 * 3, 780 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TodayTripsTab())));
    await tester.pumpAndSettle();

    expect(find.text('Today (1)'), findsOneWidget);
    expect(find.textContaining('NEXT · 23:00 · Pick up'), findsOneWidget);
    expect(find.text('Changed by the office'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.textContaining('PICK UP (1 place)'), findsOneWidget);
    expect(tester.takeException(), isNull);   // no layout overflow

    await tester.tap(find.text('BM'));
    await tester.pumpAndSettle();
    expect(find.text('Hari ini (1)'), findsOneWidget);
    expect(find.text('Diubah oleh pejabat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
