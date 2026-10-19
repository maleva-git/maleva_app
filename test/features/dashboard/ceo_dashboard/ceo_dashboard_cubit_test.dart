import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/bloc/ceo_dashboard_cubit.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_models.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_period.dart';
import 'package:mocktail/mocktail.dart';

import 'ceo_fixtures.dart';

class _Api extends Mock implements CeoAnalyticsApi {}

final _now = DateTime(2026, 10, 16, 9, 30);

void main() {
  late _Api api;
  late CeoDashboardCubit cubit;

  setUp(() {
    api = _Api();
    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoOverview.fromJava(overviewJson()));
    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async => CeoDetails.fromJava(fuelDetailsJson()));
    cubit = CeoDashboardCubit(api, clock: () => _now);
  });

  tearDown(() => cubit.close());

  test('loads this month by default', () async {
    await cubit.load();
    expect(cubit.state.overview!.revenue!.saleOrders.count, 412);
    expect((cubit.state.loading, cubit.state.error, cubit.state.updatedAt), (false, null, _now));
    verify(() => api.overview(fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
  });

  test('a period asks its own range', () async {
    await cubit.load(CeoPeriod.lastMonth);
    expect(cubit.state.period, CeoPeriod.lastMonth);
    verify(() => api.overview(fromDate: '2026-09-01', toDate: '2026-09-30')).called(1);
  });

  test('a failure shows its message; retry loads again', () async {
    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenThrow(const ApiFailure('Server error occurred. (500)', statusCode: 500));
    await cubit.load();
    expect((cubit.state.error, cubit.state.forbidden, cubit.state.overview), ('Server error occurred. (500)', false, null));

    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoOverview.fromJava(overviewJson()));
    await cubit.retry();
    expect(cubit.state.error, isNull);
    expect(cubit.state.overview, isNotNull);
  });

  test('a reload that fails keeps the numbers shown', () async {
    await cubit.load();
    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenThrow(const ApiFailure('offline'));
    await cubit.reload();
    expect(cubit.state.error, 'offline');
    expect(cubit.state.overview!.revenue!.saleOrders.count, 412);
  });

  test('403 marks the user as not the CEO', () async {
    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenThrow(const ApiFailure('Only the CEO can open this dashboard', statusCode: 403));
    await cubit.load();
    expect(cubit.state.forbidden, isTrue);
  });

  test('details load once per kind + key + period, and again for another period or a refresh', () async {
    await cubit.load();
    await cubit.loadDetails(CeoDetailKind.expenseCategory, 'FUEL');
    await cubit.loadDetails(CeoDetailKind.expenseCategory, 'FUEL');
    expect(cubit.detailsOf(CeoDetailKind.expenseCategory, 'FUEL').data!.rows, hasLength(5));
    verify(() => api.details(kind: 'EXPENSE_CATEGORY', key: 'FUEL', fromDate: '2026-10-01', toDate: '2026-10-16'))
        .called(1);

    // another key is its own list
    await cubit.loadDetails(CeoDetailKind.expenseCategory, 'REPAIR');
    verify(() => api.details(kind: 'EXPENSE_CATEGORY', key: 'REPAIR', fromDate: '2026-10-01', toDate: '2026-10-16'))
        .called(1);

    // another period
    await cubit.load(CeoPeriod.thisYear);
    expect(cubit.detailsOf(CeoDetailKind.expenseCategory, 'FUEL').loading, isTrue); // not loaded for this period
    await cubit.loadDetails(CeoDetailKind.expenseCategory, 'FUEL');
    verify(() => api.details(kind: 'EXPENSE_CATEGORY', key: 'FUEL', fromDate: '2026-01-01', toDate: '2026-10-16'))
        .called(1);

    // refresh asks again
    await cubit.reload();
    await cubit.loadDetails(CeoDetailKind.expenseCategory, 'FUEL');
    verify(() => api.details(kind: 'EXPENSE_CATEGORY', key: 'FUEL', fromDate: '2026-01-01', toDate: '2026-10-16'))
        .called(1);
  });

  test('a failed details list is not kept: opening it again asks again', () async {
    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenThrow(const ApiFailure('Unknown kind'));
    await cubit.loadDetails(CeoDetailKind.leaveToday, null);
    expect(cubit.detailsOf(CeoDetailKind.leaveToday, null).error, 'Unknown kind');

    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async => const CeoDetails(kind: 'LEAVE_TODAY', count: 0));
    await cubit.loadDetails(CeoDetailKind.leaveToday, null);
    expect(cubit.detailsOf(CeoDetailKind.leaveToday, null).data!.kind, 'LEAVE_TODAY');
  });

  test('a list asked for its own days is kept apart from the chosen period', () async {
    await cubit.load();
    const today = ('2026-10-16', '2026-10-16');
    expect(cubit.hasDetails(CeoDetailKind.saleOrders, null, range: today), isFalse);
    await cubit.loadDetails(CeoDetailKind.saleOrders, null, range: today);
    await cubit.loadDetails(CeoDetailKind.saleOrders, null, range: today);
    verify(() => api.details(kind: 'SALE_ORDERS', key: null, fromDate: '2026-10-16', toDate: '2026-10-16')).called(1);
    expect(cubit.hasDetails(CeoDetailKind.saleOrders, null, range: today), isTrue);
    expect(cubit.detailsOf(CeoDetailKind.saleOrders, null, range: today).data, isNotNull);
    // the chosen period (1 – 16 Oct) is another list
    expect(cubit.hasDetails(CeoDetailKind.saleOrders, null), isFalse);
    expect(cubit.detailsOf(CeoDetailKind.saleOrders, null).loading, isTrue);
    expect(cubit.today, _now);
  });
}
