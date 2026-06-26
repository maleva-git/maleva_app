import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_state.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/data/stock_update_repository.dart';

class MockStockUpdateRepository extends Mock implements StockUpdateRepository {}

void main() {
  late MockStockUpdateRepository mockRepository;
  late StockUpdateBloc bloc;

  setUp(() {
    mockRepository = MockStockUpdateRepository();
    bloc = StockUpdateBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be StockUpdateInitial', () {
    expect(bloc.state, equals(StockUpdateInitial()));
  });

  blocTest<StockUpdateBloc, StockUpdateState>(
    'emits [StockUpdateLoaded] instantly when StockUpdateStarted event is added',
    build: () => bloc,
    act: (bloc) => bloc.add(StockUpdateStarted()),
    expect: () => [
      StockUpdateLoaded.empty(),
    ],
  );

  blocTest<StockUpdateBloc, StockUpdateState>(
    'emits updated state when StockUpdateWarehouseSelected is added',
    build: () => bloc,
    seed: () => StockUpdateLoaded.empty(),
    act: (bloc) => bloc.add(StockUpdateWarehouseSelected(
      warehouseId: 10,
      warehouseName: 'Test Warehouse',
    )),
    expect: () => [
      StockUpdateLoaded.empty().copyWith(
        warehouseId: 10,
        warehouseName: 'Test Warehouse',
      ),
    ],
  );

  blocTest<StockUpdateBloc, StockUpdateState>(
    'emits updated state when StockUpdateWarehouseCleared is added',
    build: () => bloc,
    seed: () => StockUpdateLoaded.empty().copyWith(
      warehouseId: 10,
      warehouseName: 'Test Warehouse',
    ),
    act: (bloc) => bloc.add(StockUpdateWarehouseCleared()),
    expect: () => [
      StockUpdateLoaded.empty(),
    ],
  );

  blocTest<StockUpdateBloc, StockUpdateState>(
    'emits updated state when StockUpdateStatusSelected is added',
    build: () => bloc,
    seed: () => StockUpdateLoaded.empty(),
    act: (bloc) => bloc.add(StockUpdateStatusSelected(
      statusId: 5,
      statusName: 'Status Five',
    )),
    expect: () => [
      StockUpdateLoaded.empty().copyWith(
        statusId: 5,
        statusName: 'Status Five',
      ),
    ],
  );

  blocTest<StockUpdateBloc, StockUpdateState>(
    'emits updated state when StockUpdateStatusCleared is added',
    build: () => bloc,
    seed: () => StockUpdateLoaded.empty().copyWith(
      statusId: 5,
      statusName: 'Status Five',
    ),
    act: (bloc) => bloc.add(StockUpdateStatusCleared()),
    expect: () => [
      StockUpdateLoaded.empty(),
    ],
  );
}
