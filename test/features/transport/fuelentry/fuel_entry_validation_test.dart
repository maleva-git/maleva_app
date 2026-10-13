import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/transport/fuelentry/add/bloc/fuel_entry_validation.dart';
import 'package:maleva/features/transport/fuelentry/add/bloc/fuelentry_bloc.dart';
import 'package:maleva/features/transport/fuelentry/add/bloc/fuelentry_event.dart';
import 'package:maleva/features/transport/fuelentry/add/bloc/fuelentry_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements FuelEntryApi {}

void main() {
  group('FuelEntryValidation.check', () {
    test('accepts a number over 0, with a point or a comma', () {
      expect(FuelEntryValidation.check('Liter', '45'), isNull);
      expect(FuelEntryValidation.check('Liter', '45.5'), isNull);
      expect(FuelEntryValidation.check('Liter', '45,5'), isNull);
      expect(FuelEntryValidation.check('Liter', ' 0.01 '), isNull);
    });

    test('refuses empty, not a number, zero and negative', () {
      expect(FuelEntryValidation.check('Liter', ''), 'Enter Liter');
      expect(FuelEntryValidation.check('Liter', '   '), 'Enter Liter');
      expect(FuelEntryValidation.check('Amount', 'abc'), 'Amount must be a number');
      expect(FuelEntryValidation.check('Amount', '.'), 'Amount must be a number');
      expect(FuelEntryValidation.check('Liter', '0'), 'Liter must be more than 0');
      expect(FuelEntryValidation.check('Liter', '0.00'), 'Liter must be more than 0');
      expect(FuelEntryValidation.check('Amount', '-5'), 'Amount must be more than 0');
    });

    test('form reports Liter before Amount', () {
      expect(FuelEntryValidation.form(liter: '0', amount: ''), 'Liter must be more than 0');
      expect(FuelEntryValidation.form(liter: '40', amount: ''), 'Enter Amount');
      expect(FuelEntryValidation.form(liter: '40', amount: '120.50'), isNull);
    });
  });

  group('FuelEntryBloc save', () {
    late _MockApi api;

    setUp(() {
      api = _MockApi();
      registerFallbackValue(<String, dynamic>{});
      when(() => api.nextNumber()).thenAnswer((_) async => 'FE000000072');
      when(() => api.save(any())).thenAnswer((_) async => <String, dynamic>{});
      AppGlobals.DriverTruckRefId = 64;
    });

    blocTest<FuelEntryBloc, FuelEntryState>(
      'an invalid Liter is refused and nothing is sent',
      build: () => FuelEntryBloc(api: api),
      seed: () => FuelEntryLoaded.empty(fuelNo: 'FE000000072').copyWith(liter: '0', amount: '100'),
      act: (b) => b.add(FuelEntrySaveRequested()),
      expect: () => [
        isA<FuelEntryError>().having((e) => e.message, 'message', 'Liter must be more than 0'),
        isA<FuelEntryLoaded>(),
      ],
      verify: (_) => verifyNever(() => api.save(any())),
    );

    blocTest<FuelEntryBloc, FuelEntryState>(
      'valid values are sent as numbers',
      build: () => FuelEntryBloc(api: api),
      seed: () => FuelEntryLoaded.empty(fuelNo: 'FE000000072').copyWith(liter: '40,5', amount: '120.25'),
      act: (b) => b.add(FuelEntrySaveRequested()),
      verify: (_) {
        final sent = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
        expect(sent['aliter'], 40.5);
        expect(sent['aAmount'], 120.25);
      },
    );
  });
}
