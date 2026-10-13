import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_event.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_state.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/data/salesorder_repository.dart';

/// Answers `/api/dashboard/sales` with TodaySales = the call number, and
/// records the sale-order types asked for.
class _FakeRepository extends SalesOrderRepository {
  _FakeRepository() : super(comid: () => 1);

  final types = <int>[];

  @override
  Future<Map<String, dynamic>> fetchSalesData(int type) async {
    types.add(type);
    return {'TodaySales': types.length, 'monthlySales': <dynamic>[]};
  }
}

Future<InvoiceLoaded> _nextLoaded(SalesOrderBloc bloc) async =>
    await bloc.stream.firstWhere((s) => s is InvoiceLoaded) as InvoiceLoaded;

void main() {
  test('pull-to-refresh on the All tab reloads sale orders (type 1), not invoices', () async {
    final repo = _FakeRepository();
    final bloc = SalesOrderBloc(repository: repo);

    bloc.add(LoadInvoiceByTypes(1));
    final first = await _nextLoaded(bloc);
    expect(first.selectedTabIndex, 0);

    bloc.add(RefreshSalesOrder());
    final refreshed = await _nextLoaded(bloc);

    expect(repo.types, [1, 1]);
    expect(refreshed.selectedTabIndex, 0);
    expect((refreshed.saleDataAll.first as Map)['TodaySales'], 2);
    await bloc.close();
  });

  test('pull-to-refresh on the Without tab reloads type 3', () async {
    final repo = _FakeRepository();
    final bloc = SalesOrderBloc(repository: repo);

    bloc.add(LoadInvoiceByTypes(3));
    await _nextLoaded(bloc);
    bloc.add(RefreshSalesOrder());
    final refreshed = await _nextLoaded(bloc);

    expect(repo.types, [3, 3]);
    expect(refreshed.selectedTabIndex, 2);
    await bloc.close();
  });

  test('tapping the tab already shown does not reload', () async {
    final repo = _FakeRepository();
    final bloc = SalesOrderBloc(repository: repo);

    bloc.add(LoadInvoiceByTypes(1));
    await _nextLoaded(bloc);
    bloc.add(LoadInvoiceByTypes(1));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(repo.types, [1]);
    await bloc.close();
  });
}
