import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/stock_transfer_repository.dart';

part 'stock_transfer_event.dart';
part 'stock_transfer_state.dart';

class StockTransferBloc extends Bloc<StockTransferEvent, StockTransferState> {
  final StockTransferRepository repository;

  // Local cache to replace objfun.WareHouseList
  List<dynamic> _wareHouseList = [];

  StockTransferBloc({required this.repository}) : super(const StockTransferInitialLoading()) {
    on<StockTransferInitialized>(_onInitialized);
    on<StockTransferBarcodeScanned>(_onBarcodeScanned);
    on<StockTransferLoadStockData>(_onLoadStockData);
    on<StockTransferAddScannedItem>(_onAddScannedItem);
    on<StockTransferWareHouseSelected>(_onWareHouseSelected);
    on<StockTransferWareHouseCleared>(_onWareHouseCleared);
    on<StockTransferItemRemoved>(_onItemRemoved);
    on<StockTransferUpdateRequested>(_onUpdateRequested);
    on<StockTransferCleared>(_onCleared);
    on<StockTransferMessageDismissed>(_onMessageDismissed);
  }

  StockTransferLoaded get _loaded => state as StockTransferLoaded;

  StockTransferLoaded _withMsg(StockTransferLoaded s, String text, MessageType type) =>
      s.copyWith(message: StockTransferMessage(text, type), isBusy: false);

  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(StockTransferInitialized _, Emitter<StockTransferState> emit) async {
    emit(const StockTransferInitialLoading());
    try {
      _wareHouseList = await repository.fetchWarehouses();
      emit(StockTransferLoaded(data: const StockTransferData()));
    } catch (e) {
      emit(StockTransferInitError(e.toString()));
    }
  }

  Future<void> _onBarcodeScanned(StockTransferBarcodeScanned _, Emitter<StockTransferState> emit) async {
    if (state is! StockTransferLoaded) return;
    try {
      final barcodeString = await repository.scanBarcode();
      if (barcodeString == null || barcodeString.isEmpty) return;

      if (_loaded.data.stockNoList.isEmpty) {
        add(StockTransferLoadStockData(barcodeString.split('-')[0]));
        add(StockTransferAddScannedItem(barcodeString));
      } else {
        add(StockTransferAddScannedItem(barcodeString));
      }
    } catch (e) {
      emit(_withMsg(_loaded, e.toString(), MessageType.error));
    }
  }

  Future<void> _onLoadStockData(StockTransferLoadStockData event, Emitter<StockTransferState> emit) async {
    if (state is! StockTransferLoaded) return;
    final current = _loaded;
    emit(current.copyWith(isBusy: true));

    try {
      final row = await repository.fetchStockData(event.barcodeLabel);

      final int numPkg = row['NumberOfPackages'];
      final String barcodeDisplay = row['BarcodeLabelDisplay'];
      final int portMasterRefId = row['PortMasterRefId'];

      final checkList = List.generate(numPkg, (i) => '$barcodeDisplay-${i + 1}/$numPkg');

      // Look up Port Name from local list
      String portName = '';
      try {
        final match = _wareHouseList.firstWhere((w) => w['Id'] == portMasterRefId, orElse: () => null);
        if (match != null) portName = match['PortName'] ?? '';
      } catch (_) {}

      emit(current.copyWith(
        isBusy: false,
        data: current.data.copyWith(
          jobNo: barcodeDisplay,
          portName: portName,
          totalPkg: numPkg,
          stockId: row['Id'],
          checkStockNoList: checkList,
        ),
      ));
    } catch (e, st) {
      emit(_withMsg(current, e.toString(), MessageType.error));
    }
  }

  void _onAddScannedItem(StockTransferAddScannedItem event, Emitter<StockTransferState> emit) {
    if (state is! StockTransferLoaded) return;
    final current = _loaded;
    final data = current.data;

    final isValid = data.checkStockNoList.contains(event.barcodeString);
    final isDuplicate = data.stockNoList.contains(event.barcodeString);

    if (!isValid || isDuplicate) {
      emit(_withMsg(current, 'Invalid / duplicate barcode!', MessageType.info));
      return;
    }

    final newList = List<String>.from(data.stockNoList)..add(event.barcodeString);
    emit(current.copyWith(data: data.copyWith(stockNoList: newList, scnPkg: newList.length)));
  }

  void _onWareHouseSelected(StockTransferWareHouseSelected event, Emitter<StockTransferState> emit) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(
      data: _loaded.data.copyWith(selectedWareHouseId: event.wareHouseId, selectedWareHouseName: event.portName),
    ));
  }

  void _onWareHouseCleared(StockTransferWareHouseCleared _, Emitter<StockTransferState> emit) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(
      data: _loaded.data.copyWith(selectedWareHouseId: 0, selectedWareHouseName: ''),
    ));
  }

  void _onItemRemoved(StockTransferItemRemoved event, Emitter<StockTransferState> emit) {
    if (state is! StockTransferLoaded) return;
    final data = _loaded.data;
    final newList = List<String>.from(data.stockNoList)..removeAt(event.index);

    if (newList.isEmpty) {
      emit(StockTransferLoaded(data: const StockTransferData()));
      return;
    }
    emit(_loaded.copyWith(data: data.copyWith(stockNoList: newList, scnPkg: newList.length)));
  }

  Future<void> _onUpdateRequested(StockTransferUpdateRequested _, Emitter<StockTransferState> emit) async {
    if (state is! StockTransferLoaded) return;
    final current = _loaded;
    final data = current.data;

    if (data.selectedWareHouseId == 0) { emit(_withMsg(current, 'Select WareHouse', MessageType.info)); return; }
    if (data.totalPkg == 0 || data.totalPkg != data.scnPkg) { emit(_withMsg(current, 'Stock count mismatch', MessageType.info)); return; }
    if (data.stockId == 0) { emit(_withMsg(current, 'Invalid stock details', MessageType.info)); return; }

    emit(current.copyWith(isBusy: true));
    try {
      final result = await repository.updateStockTransfer(data.stockId, data.selectedWareHouseId);

      if (result?.IsSuccess == true) {
        emit(StockTransferLoaded(
          data: const StockTransferData(),
          message: const StockTransferMessage('Updated Successfully', MessageType.success),
        ));
      } else {
        emit(_withMsg(current, result?.Message ?? 'Update failed', MessageType.error));
      }
    } catch (e, st) {
      emit(_withMsg(current, e.toString(), MessageType.error));
    }
  }

  void _onCleared(StockTransferCleared _, Emitter<StockTransferState> emit) {
    emit(StockTransferLoaded(data: const StockTransferData()));
  }

  void _onMessageDismissed(StockTransferMessageDismissed _, Emitter<StockTransferState> emit) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(clearMessage: true));
  }
}