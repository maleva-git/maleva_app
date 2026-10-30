import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/models/fuelentry_model.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/view/driver_fuel_receipt.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/view/driver_fuel_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Receipt photo required in the driver app (fuel data plan part B, owner 2026-10-29).
class _FakeFuelApi extends FuelEntryApi {
  _FakeFuelApi() : super(Dio(), companyId: () => 6);

  int saves = 0;

  @override
  Future<List<String>> cards() async => const ['PETRA'];

  @override
  Future<Map<String, dynamic>> save(Map<String, dynamic> body) async {
    saves++;
    return {'id': 1};
  }
}

FuelEntryModel _fill(int id, String day, double litres, {String file = ''}) => FuelEntryModel()
  ..id = id
  ..entryNo = 'FE$id'
  ..entryDate = day
  ..aLiter = litres
  ..filePath = file;

void main() {
  test('a photo is needed for a new fill and an old fill without one', () {
    expect(needsReceiptPhoto(null), isTrue);
    expect(needsReceiptPhoto(_fill(1, '21/10/2026', 250)), isTrue);
    expect(needsReceiptPhoto(_fill(1, '21/10/2026', 250, file: '/Upload/6/FuelEntry/1/a.jpg')), isFalse);
  });

  test('the second fill of a day is found, the edited one is not counted', () {
    final mine = [_fill(1, '21/10/2026', 250), _fill(2, '22/10/2026', 100), _fill(3, '21/10/2026', 80)];
    expect(sameDayFills(mine, '21/10/2026').map((e) => e.id), [1, 3]);
    expect(sameDayFills(mine, '21/10/2026', excludeId: 3).map((e) => e.id), [1]);
    expect(sameDayFills(mine, '23/10/2026'), isEmpty);
    expect(const FuelText(false).sameDayBody([_fill(1, '21/10/2026', 250)]),
        'You already saved fuel on this day: FE1 250 L. Save only if this is another fill (another receipt).');
  });

  test('the receipt path is never sent (the server keeps it)', () async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    expect(_fill(1, '21/10/2026', 50, file: '/Upload/x.jpg').toJava().containsKey('filePath'), isFalse);
  });

  for (final malay in [false, true]) {
    testWidgets('the form guides the driver and will not save without a photo (${malay ? 'BM' : 'EN'}, 360 px)',
        (tester) async {
      SharedPreferences.setMockInitialValues({'today_trips_malay_v1': malay});
      await AppPreferences.init();
      if (sl.isRegistered<FuelEntryApi>()) sl.unregister<FuelEntryApi>();
      sl.registerSingleton<FuelEntryApi>(_FakeFuelApi());
      // a small phone and the sheet as the app shows it: no outer scroll view (the overflow the owner saw)
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DriverFuelForm())));
      await tester.pumpAndSettle();
      final t = FuelText(malay);
      expect(find.text(t.photoTitle), findsOneWidget);
      expect(find.text('1. ${t.photoSteps.first}'), findsOneWidget);
      expect(find.text(t.takePhoto), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '250');
      await tester.enterText(find.byType(TextField).at(1), '537.50');
      await tester.ensureVisible(find.text('SAVE'));
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.text(t.photoMissing), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('only a new fill or a driver-app fill is the driver\'s to change (entry 6666, 2026-10-30)', () {
    expect(driverCanChange(null), isTrue);
    expect(driverCanChange(_fill(1, '21/10/2026', 50)..fStatus = 1), isTrue);
    expect(driverCanChange(_fill(1, '21/10/2026', 50)..fStatus = 0), isFalse);
    expect(FuelEntryModel.fromJava({'id': 6666, 'fStatus': 1}).fStatus, 1);
    expect(FuelEntryModel.fromJava({'id': 6666}).fStatus, 0);
  });

  testWidgets('an office entry is read only and SEND PHOTO never saves the fill', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    if (sl.isRegistered<FuelEntryApi>()) sl.unregister<FuelEntryApi>();
    final api = _FakeFuelApi();
    sl.registerSingleton<FuelEntryApi>(api);
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final office = _fill(6666, '29/10/2026', 120)..fStatus = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: DriverFuelForm(entry: office))));
    await tester.pumpAndSettle();
    const t = FuelText(false);
    expect(find.text(t.officeEntry), findsOneWidget);
    expect(find.text('SAVE'), findsNothing);

    await tester.ensureVisible(find.text(t.sendPhoto));
    await tester.tap(find.text(t.sendPhoto));
    await tester.pumpAndSettle();
    expect(find.text(t.photoMissing), findsOneWidget);
    expect(api.saves, 0);
    expect(tester.takeException(), isNull);
  });
}
