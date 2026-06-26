import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stocktransfer/bloc/stock_transfer_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stocktransfer/data/stock_transfer_repository.dart';

class MockStockTransferRepository extends Mock implements StockTransferRepository {}

void main() {
  late MockStockTransferRepository mockRepository;
  late StockTransferBloc bloc;

  setUp(() {
    mockRepository = MockStockTransferRepository();
    bloc = StockTransferBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be StockTransferInitialLoading', () {
    expect(bloc.state, equals(const StockTransferInitialLoading()));
  });

  blocTest<StockTransferBloc, StockTransferState>(
    'emits [StockTransferInitialLoading, StockTransferLoaded] when StockTransferInitialized succeeds',
    build: () {
      when(() => mockRepository.fetchWarehouses()).thenAnswer((_) async => [
        {'Id': 1, 'PortName': 'Warehouse A'}
      ]);
      return bloc;
    },
    act: (bloc) => bloc.add(const StockTransferInitialized()),
    expect: () => [
      const StockTransferInitialLoading(),
      const StockTransferLoaded(data: StockTransferData()),
    ],
    verify: (_) {
      verify(() => mockRepository.fetchWarehouses()).called(1);
    },
  );

  blocTest<StockTransferBloc, StockTransferState>(
    'emits [StockTransferInitialLoading, StockTransferInitError] when StockTransferInitialized fails',
    build: () {
      when(() => mockRepository.fetchWarehouses()).thenThrow(Exception('Fetch Failed'));
      return bloc;
    },
    act: (bloc) => bloc.add(const StockTransferInitialized()),
    expect: () => [
      const StockTransferInitialLoading(),
      const StockTransferInitError('Exception: Fetch Failed'),
    ],
  );

  blocTest<StockTransferBloc, StockTransferState>(
    'emits updated state when StockTransferWareHouseSelected is added',
    build: () => bloc,
    seed: () => const StockTransferLoaded(data: StockTransferData()),
    act: (bloc) => bloc.add(const StockTransferWareHouseSelected(
      portName: 'Warehouse A',
      wareHouseId: 10,
    )),
    expect: () => [
      const StockTransferLoaded(
        data: StockTransferData(
          selectedWareHouseId: 10,
          selectedWareHouseName: 'Warehouse A',
        ),
      ),
    ],
  );

  blocTest<StockTransferBloc, StockTransferState>(
    'emits updated state when StockTransferWareHouseCleared is added',
    build: () => bloc,
    seed: () => const StockTransferLoaded(
      data: StockTransferData(
        selectedWareHouseId: 10,
        selectedWareHouseName: 'Warehouse A',
      ),
    ),
    act: (bloc) => bloc.add(const StockTransferWareHouseCleared()),
    expect: () => [
      const StockTransferLoaded(data: StockTransferData()),
    ],
  );

  blocTest<StockTransferBloc, StockTransferState>(
    'emits reset state when StockTransferCleared is added',
    build: () => bloc,
    seed: () => const StockTransferLoaded(
      data: StockTransferData(
        jobNo: 'MY001',
        totalPkg: 5,
        scnPkg: 2,
      ),
    ),
    act: (bloc) => bloc.add(const StockTransferCleared()),
    expect: () => [
      const StockTransferLoaded(data: StockTransferData()),
    ],
  );

  blocTest<StockTransferBloc, StockTransferState>(
    'emits clearMessage when StockTransferMessageDismissed is added',
    build: () => bloc,
    seed: () => const StockTransferLoaded(
      data: StockTransferData(),
      message: StockTransferMessage('Test message', MessageType.info),
    ),
    act: (bloc) => bloc.add(const StockTransferMessageDismissed()),
    expect: () => [
      const StockTransferLoaded(
        data: StockTransferData(),
        message: null, // clearMessage sets message to null
      ),
    ],
  );
}
