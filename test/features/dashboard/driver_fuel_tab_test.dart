import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/models/fuelentry_model.dart';
import 'package:maleva/features/dashboard/common_tabs/fuelentry/view/driver_fuel_tab.dart';

void main() {
  test('the driver must type litres and amount, within sane limits', () {
    expect(driverFuelProblem(litres: '', amount: '500'), 'Type the litres');
    expect(driverFuelProblem(litres: '0', amount: '500'), 'Type the litres');
    expect(driverFuelProblem(litres: '1200', amount: '500'), 'Litres look too high (max 1000)');
    expect(driverFuelProblem(litres: '250', amount: ''), 'Type the amount (RM)');
    expect(driverFuelProblem(litres: '250', amount: '9000'), 'Amount looks too high (max RM 5000)');
    expect(driverFuelProblem(litres: '250', amount: '537.50'), isNull);
  });

  test('shows the price per litre', () {
    expect(driverFuelRate(litres: '250', amount: '537.50'), 'RM 2.15 per litre');
    expect(driverFuelRate(litres: '', amount: '537.50'), '');
  });

  test('adds up the month', () {
    final a = FuelEntryModel()
      ..aLiter = 250
      ..aAmount = 537.5;
    final b = FuelEntryModel()
      ..aLiter = 100.5
      ..aAmount = 216;
    final t = driverFuelTotals([a, b]);
    expect(t.fills, 2);
    expect(t.litres, 350.5);
    expect(t.amount, 753.5);
  });

  test('card and engine are sent only when chosen (else kept on the server)', () async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    final m = FuelEntryModel()
      ..aLiter = 50
      ..aAmount = 110;
    expect(m.toJava().containsKey('cardCode'), isFalse);
    expect(m.toJava().containsKey('engineOn'), isFalse);
    m
      ..cardCode = 'PETRA'
      ..engineOn = false;
    expect(m.toJava()['cardCode'], 'PETRA');
    expect(m.toJava()['engineOn'], false);
    expect((FuelEntryModel()..cardCode = '').toJava()['cardCode'], '');   // "No card / cash" clears
  });
}
