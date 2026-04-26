// test/features/dashboard/admin_dashboard/tabs/invoice/invoice_bloc_test.dart
//
// Run: flutter test test/features/dashboard/admin_dashboard/tabs/invoice/
//
// dev_dependencies needed:
//   bloc_test: ^9.1.0
//   mocktail: ^1.0.0

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_state.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/data/invoice_repository.dart';

// ─────────────────────────────────────────────────────────────
// MOCK
// ─────────────────────────────────────────────────────────────
class MockInvoiceRepository extends Mock implements InvoiceRepository {}

// ─────────────────────────────────────────────────────────────
// FIXTURES
// ─────────────────────────────────────────────────────────────
final _salesData = {
  'Data1': [
    {
      'MonthAmount':     '549839',
      'MonthSales':      '42',
      'WeekSales':       '8',
      'WeekAmount':      '83420',
      'TodaySales':      '3',
      'TodayAmount':     '12450',
      'YesterdaySales':  '5',
      'YesterdayAmount': '21800',
    }
  ],
  'Data2': List.generate(
    12,
        (i) => {'SalesAmount': 50000.0 + (i * 5000.0), 'SalesCount': 10 + i},
  ),
};

final _waitingBills = [
  {'BillNo': 'B001', 'CustomerName': 'ABC Corp', 'NetAmt': '12000'},
  {'BillNo': 'B002', 'CustomerName': 'XYZ Ltd',  'NetAmt': '8500'},
];

final _employeeData = [
  {'EmployeeName': 'Ahmad', 'Amount': '75000', 'SalesCount': '6'},
];

void main() {
  late MockInvoiceRepository mockRepo;
  late InvoiceBloc bloc;

  setUp(() {
    mockRepo = MockInvoiceRepository();
    bloc = InvoiceBloc(invoiceRepo: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────
  // LoadInvoiceByType
  // ──────────────────────────────────────────────────────────
  group('LoadInvoiceByType', () {
    blocTest<InvoiceBloc, InvoiceState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(() => mockRepo.loadDashboard(type: any(named: 'type')))
            .thenAnswer((_) async => (_salesData, _waitingBills));
      },
      build: () => bloc,
      act: (b) => b.add( LoadInvoiceByType(0)),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoiceLoaded>()
            .having((s) => s.saleDataAll.length,  'saleDataAll length',   1)
            .having((s) => s.saleMonthData.length,'saleMonthData length', 12)
            .having((s) => s.is6Months,           'default 6 months',     true)
            .having((s) => s.monthList.length,    'monthList length',      6)
            .having((s) => s.showWaitingSheet,    'sheet closed',          false),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [Loading, Error] when API throws',
      setUp: () {
        when(() => mockRepo.loadDashboard(type: any(named: 'type')))
            .thenThrow(Exception('Server unreachable'));
      },
      build: () => bloc,
      act: (b) => b.add( LoadInvoiceByType(0)),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoiceError>()
            .having((s) => s.message, 'message', contains('Server unreachable')),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'does NOT reload when already Loaded',
      setUp: () {
        when(() => mockRepo.loadDashboard(type: any(named: 'type')))
            .thenAnswer((_) async => (_salesData, []));
      },
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [_salesData['Data1']!.first],
        saleMonthData:    _salesData['Data2']!,
        waitingBilling:   [],
        monthList:        ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        monthData:        (_salesData['Data2']! as List).take(6).toList(),
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      ),
      act: (b) => b.add( LoadInvoiceByType(0)),
      expect: () => <InvoiceState>[], // no new states
      verify: (_) => verifyNever(
            () => mockRepo.loadDashboard(type: any(named: 'type')),
      ),
    );
  });

  // ──────────────────────────────────────────────────────────
  // RefreshInvoice
  // ──────────────────────────────────────────────────────────
  group('RefreshInvoice', () {
    blocTest<InvoiceBloc, InvoiceState>(
      'emits [Refreshing, Loaded] — keeps old data visible during refresh',
      setUp: () {
        when(() => mockRepo.loadDashboard(type: any(named: 'type')))
            .thenAnswer((_) async => (_salesData, []));
      },
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [_salesData['Data1']!.first],
        saleMonthData:    [],
        waitingBilling:   [],
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      ),
      act: (b) => b.add( RefreshInvoice()),
      expect: () => [
        isA<InvoiceRefreshing>(), // ← stale data still accessible via .previous
        isA<InvoiceLoaded>(),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [Loading, Loaded] when refreshed from initial state',
      setUp: () {
        when(() => mockRepo.loadDashboard(type: any(named: 'type')))
            .thenAnswer((_) async => (_salesData, []));
      },
      build: () => bloc,
      act: (b) => b.add( RefreshInvoice()),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoiceLoaded>(),
      ],
    );
  });

  // ──────────────────────────────────────────────────────────
  // LoadMonthRange — pure local, no API
  // ──────────────────────────────────────────────────────────
  group('LoadMonthRange', () {
    late InvoiceLoaded seedState;

    setUp(() {
      seedState = InvoiceLoaded(
        saleDataAll:      [_salesData['Data1']!.first],
        saleMonthData:    _salesData['Data2']! as List<dynamic>,
        waitingBilling:   [],
        monthList:        ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        monthData:        (_salesData['Data2']! as List).take(6).toList(),
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      );
    });

    blocTest<InvoiceBloc, InvoiceState>(
      'LoadMonthRange(12) → monthList has 12 items, no API call',
      build: () => bloc,
      seed: () => seedState,
      act: (b) => b.add( LoadMonthRange(12)),
      expect: () => [
        isA<InvoiceLoaded>()
            .having((s) => s.is6Months,       'is6Months',  false)
            .having((s) => s.monthList.length, 'month count', 12),
      ],
      verify: (_) => verifyNever(
            () => mockRepo.loadDashboard(type: any(named: 'type')),
      ),
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'LoadMonthRange(6) when already 6 → no emit (no-op)',
      build: () => bloc,
      seed: () => seedState, // already is6Months = true
      act: (b) => b.add( LoadMonthRange(6)),
      expect: () => <InvoiceState>[],
    );
  });

  // ──────────────────────────────────────────────────────────
  // LoadWaitingBills
  // ──────────────────────────────────────────────────────────
  group('LoadWaitingBills', () {
    late InvoiceLoaded emptyBillsState;

    setUp(() {
      emptyBillsState = InvoiceLoaded(
        saleDataAll:      [],
        saleMonthData:    [],
        waitingBilling:   [], // empty — will trigger API
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      );
    });

    blocTest<InvoiceBloc, InvoiceState>(
      'fetches bills from API and sets showWaitingSheet = true',
      setUp: () {
        when(() => mockRepo.getWaitingBills())
            .thenAnswer((_) async => _waitingBills);
      },
      build: () => bloc,
      seed: () => emptyBillsState,
      act: (b) => b.add( LoadWaitingBills()),
      expect: () => [
        isA<InvoiceLoaded>()
            .having((s) => s.waitingBilling.length, 'bills count',     2)
            .having((s) => s.showWaitingSheet,       'sheet open',     true),
      ],
      verify: (_) => verify(() => mockRepo.getWaitingBills()).called(1),
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'uses cached bills — does NOT call API again',
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [],
        saleMonthData:    [],
        waitingBilling:   _waitingBills, // already cached
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      ),
      act: (b) => b.add( LoadWaitingBills()),
      expect: () => [
        isA<InvoiceLoaded>().having(
                (s) => s.showWaitingSheet, 'sheet open', true),
      ],
      verify: (_) => verifyNever(() => mockRepo.getWaitingBills()),
    );
  });

  // ──────────────────────────────────────────────────────────
  // LoadEmployeeInvData
  // ──────────────────────────────────────────────────────────
  group('LoadEmployeeInvData', () {
    blocTest<InvoiceBloc, InvoiceState>(
      'emits Loaded with employeeData populated',
      setUp: () {
        when(() => mockRepo.getEmployeeInvData(type: any(named: 'type')))
            .thenAnswer((_) async => _employeeData);
      },
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [],
        saleMonthData:    [],
        waitingBilling:   [],
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      ),
      act: (b) => b.add( LoadEmployeeInvData(3)),
      expect: () => [
        isA<InvoiceLoaded>()
            .having((s) => s.employeeData,        'has employee data', isNotNull)
            .having((s) => s.employeeData!.length, 'emp count',        1)
            .having((s) => s.showWaitingSheet,    'sheet closed',     false),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'silently ignores API error — dashboard stays visible',
      setUp: () {
        when(() => mockRepo.getEmployeeInvData(type: any(named: 'type')))
            .thenThrow(Exception('timeout'));
      },
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [],
        saleMonthData:    [],
        waitingBilling:   [],
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: false,
      ),
      act: (b) => b.add( LoadEmployeeInvData(3)),
      expect: () => <InvoiceState>[], // no crash, no error state
    );
  });

  // ──────────────────────────────────────────────────────────
  // DismissWaitingSheet
  // ──────────────────────────────────────────────────────────
  group('DismissWaitingSheet', () {
    blocTest<InvoiceBloc, InvoiceState>(
      'sets showWaitingSheet = false',
      build: () => bloc,
      seed: () => InvoiceLoaded(
        saleDataAll:      [],
        saleMonthData:    [],
        waitingBilling:   _waitingBills,
        monthList:        [],
        monthData:        [],
        is6Months:        true,
        currentMonthName: 'April',
        showWaitingSheet: true, // currently open
      ),
      act: (b) => b.add( DismissWaitingSheet()),
      expect: () => [
        isA<InvoiceLoaded>().having(
                (s) => s.showWaitingSheet, 'sheet closed', false),
      ],
    );
  });
}