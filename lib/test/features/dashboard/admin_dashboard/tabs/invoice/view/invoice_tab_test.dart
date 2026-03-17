import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_state.dart';
import '../../../../../../../features/dashboard/admin_dashboard/tabs/invoice/view/invoice_tab.dart';

// ✅ Proper Mock Bloc
class MockInvoiceBloc extends Mock implements InvoiceBloc {}

void main() {
  late MockInvoiceBloc bloc;

  setUp(() {
    bloc = MockInvoiceBloc();
  });

  // ✅ Loading UI Test
  testWidgets('should show loading indicator', (tester) async {
    when(() => bloc.state).thenReturn(InvoiceLoading());
    whenListen(
      bloc,
      Stream<InvoiceState>.fromIterable([InvoiceLoading()]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<InvoiceBloc>.value(
          value: bloc,
          child: InvoiceTab(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ✅ Loaded UI Test
  testWidgets('should display sales data when loaded', (tester) async {
    final loadedState = InvoiceLoaded(
      saleDataAll: [
        {
          "TodaySales": 10,
          "TodayAmount": 100,
          "YesterdaySales": 5,
          "YesterdayAmount": 50,
          "WeekSales": 20,
          "WeekAmount": 200,
          "MonthSales": 50,
          "MonthAmount": 500,
        }
      ],
      saleMonthData: [],
      waitingBilling: [],
      monthList: ["Jan", "Feb"],
      monthData: [
        {"SalesAmount": 100},
        {"SalesAmount": 200}
      ],
      is6Months: true,
      currentMonthName: "March",
      showWaitingSheet: false,
    );

    when(() => bloc.state).thenReturn(loadedState);
    whenListen(
      bloc,
      Stream<InvoiceState>.fromIterable([loadedState]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<InvoiceBloc>.value(
          value: bloc,
          child: InvoiceTab(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('March Sales'), findsOneWidget);
  });

  // ✅ Error UI Test
  testWidgets('should show error message', (tester) async {
    when(() => bloc.state).thenReturn(InvoiceError('Something went wrong'));
    whenListen(
      bloc,
      Stream<InvoiceState>.fromIterable(
        [InvoiceError('Something went wrong')],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<InvoiceBloc>.value(
          value: bloc,
          child: InvoiceTab(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
  });
}