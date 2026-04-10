import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_state.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late InvoiceBloc bloc;
  late BuildContext context;

  setUp(() {
    context = MockBuildContext();
    bloc = InvoiceBloc();
  });

  // ✅ Initial state test
  test('initial state should be InvoiceInitial', () {
    expect(bloc.state, isA<InvoiceInitial>());
  });

  // ✅ Month range test
  blocTest<InvoiceBloc, InvoiceState>(
    'LoadMonthRange should update is6Months = false when 12 months',


    build: () => bloc,
    seed: () => InvoiceLoaded(
      saleDataAll: [],
      saleMonthData: [],
      waitingBilling: [],
      monthList: [],
      monthData: [],
      is6Months: true,
      currentMonthName: 'March',
      showWaitingSheet: false,
    ),
    act: (bloc) => bloc.add(LoadMonthRange(12)),
    expect: () => [
      isA<InvoiceLoaded>()
          .having((s) => s.is6Months, 'is6Months', false),
    ],
  );

  // ✅ Month range 6 months test
  blocTest<InvoiceBloc, InvoiceState>(
    'LoadMonthRange should update is6Months = true when 6 months',
    build: () => bloc,
    seed: () => InvoiceLoaded(
      saleDataAll: [],
      saleMonthData: [],
      waitingBilling: [],
      monthList: [],
      monthData: [],
      is6Months: false,
      currentMonthName: 'March',
      showWaitingSheet: false,
    ),
    act: (bloc) => bloc.add(LoadMonthRange(6)),
    expect: () => [
      isA<InvoiceLoaded>()
          .having((s) => s.is6Months, 'is6Months', true),
    ],
  );
}