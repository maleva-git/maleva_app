import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/features/dashboard/common_tabs/stocktransfer/bloc/stock_transfer_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/bloc/stock_update_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/bloc/stock_update_event.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/bloc/stock_update_state.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/data/stock_update_repository.dart';
class TransferMock extends Mock implements StockTransferRepository {}
class UpdateMock extends Mock implements StockUpdateRepository {}
void main() {
  for (final barcode in ['bad', 'X-1/1']) {
    blocTest<StockTransferBloc, StockTransferState>('reject invalid/duplicate $barcode',
      build: () => StockTransferBloc(repository: TransferMock()),
      seed: () => const StockTransferLoaded(data: StockTransferData(
        checkStockNoList: ['X-1/1'], stockNoList: ['X-1/1'], scnPkg: 1)),
      act: (b) => b.add(StockTransferAddScannedItem(barcode)),
      expect: () => [isA<StockTransferLoaded>().having((s) => s.data.scnPkg, 'count', 1)
        .having((s) => s.message?.text, 'message', 'Invalid / duplicate barcode!')]);
  }
  final transfer = TransferMock();
  blocTest<StockTransferBloc, StockTransferState>('missing warehouse never submits',
    build: () => StockTransferBloc(repository: transfer),
    seed: () => const StockTransferLoaded(data: StockTransferData()),
    act: (b) => b.add(const StockTransferUpdateRequested()),
    expect: () => [isA<StockTransferLoaded>().having((s) => s.message?.text, 'message', 'Select WareHouse')],
    verify: (_) => verifyNever(() => transfer.updateStockTransfer(any(), any())));
  blocTest<StockTransferBloc, StockTransferState>('cancelled scan does not load',
    build: () { when(() => transfer.scanBarcode()).thenAnswer((_) async => null); return StockTransferBloc(repository: transfer); },
    seed: () => const StockTransferLoaded(data: StockTransferData()),
    act: (b) => b.add(const StockTransferBarcodeScanned()), expect: () => [],
    verify: (_) => verifyNever(() => transfer.fetchStockData(any())));
  blocTest<StockTransferBloc, StockTransferState>('complete transfer resets after success',
    build: () { when(() => transfer.updateStockTransfer(8, 2)).thenAnswer((_) async {}); return StockTransferBloc(repository: transfer); },
    seed: () => const StockTransferLoaded(data: StockTransferData(selectedWareHouseId: 2, totalPkg: 1, scnPkg: 1, stockId: 8)),
    act: (b) => b.add(const StockTransferUpdateRequested()),
    expect: () => [isA<StockTransferLoaded>().having((s) => s.isBusy, 'busy', true),
      isA<StockTransferLoaded>().having((s) => s.data.stockId, 'reset', 0).having((s) => s.message?.text, 'message', 'Updated Successfully')]);
  for (final delayed in [false, true]) {
    test('first scan scheduling remains characterized (delayed=$delayed)', () async {
      final repo = TransferMock();
      final response = Completer<Map<String, dynamic>>();
      final row = {'numberOfPackages': 1, 'barcodeLabelDisplay': 'X', 'portMasterRefId': 1, 'id': 8};
      when(() => repo.fetchWarehouses()).thenAnswer((_) async => []);
      when(() => repo.scanBarcode()).thenAnswer((_) async => 'X-1/1');
      when(() => repo.fetchStockData('X')).thenAnswer((_) => delayed ? response.future : Future.value(row));
      final b = StockTransferBloc(repository: repo);
      final loaded = b.stream.firstWhere((s) => s is StockTransferLoaded);
      b.add(const StockTransferInitialized()); await loaded;
      final ready = b.stream.firstWhere((s) => s is StockTransferLoaded && s.data.stockId == 8);
      b.add(const StockTransferBarcodeScanned());
      if (delayed) { await Future<void>.delayed(Duration.zero); response.complete(row); }
      await ready;
      // Existing load/add race depends on lookup completion timing.
      expect((b.state as StockTransferLoaded).data.scnPkg, delayed ? 0 : 1);
      await b.close();
    });
  }
  final update = UpdateMock();
  final calls = <String>[];
  blocTest<StockUpdateBloc, StockUpdateState>('follow-up failure follows successful stock write',
    build: () {
      when(() => update.saveStockUpdate(any(), any(), any(), any())).thenAnswer((_) async { calls.add('stock'); });
      when(() => update.updateBoardingOfficer(any(), any(), any(), any(), any(), any())).thenAnswer((_) async { calls.add('officer'); throw StateError('fixture failure'); });
      return StockUpdateBloc(repository: update);
    }, seed: () => StockUpdateLoaded.empty(),
    act: (b) => b.add(StockUpdateSaveRequested()),
    expect: () => [isA<StockUpdateLoading>(), isA<StockUpdateError>()],
    verify: (_) => expect(calls, ['stock', 'officer']));
}
