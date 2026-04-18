import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

part 'stock_transfer_event.dart';
part 'stock_transfer_state.dart';

class StockTransferBloc extends Bloc<StockTransferEvent, StockTransferState> {
  StockTransferBloc() : super(const StockTransferInitialLoading()) {
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

  StockTransferLoaded _withMsg(
      StockTransferLoaded s,
      String text,
      MessageType type,
      ) =>
      s.copyWith(message: StockTransferMessage(text, type), isBusy: false);

  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
      StockTransferInitialized _,
      Emitter<StockTransferState> emit,
      ) async {
    emit(const StockTransferInitialLoading());
    try {
      await OnlineApi.SelectWareHouse(null);
      emit(StockTransferLoaded(data: const StockTransferData()));
    } catch (e) {
      emit(StockTransferInitError(e.toString()));
    }
  }

  Future<void> _onBarcodeScanned(
      StockTransferBarcodeScanned _,
      Emitter<StockTransferState> emit,
      ) async {
    if (state is! StockTransferLoaded) return;
    try {
      await objfun.barcodeScanning();
      if (objfun.barcodeerror == true) return;
      final barcodeString = objfun.barcodestring as String;
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

  Future<void> _onLoadStockData(
      StockTransferLoadStockData event,
      Emitter<StockTransferState> emit,
      ) async {
    if (state is! StockTransferLoaded) return;
    final current = _loaded;
    emit(current.copyWith(isBusy: true));
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiEditStockIn}0&barcodeLabel=${event.barcodeLabel}&Comid=$comid",
        null, header, null,
      );
      if (resultData == '') {
        emit(_withMsg(current, 'No data returned', MessageType.error));
        return;
      }
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess != true) {
        emit(_withMsg(current, value.Message ?? 'Error', MessageType.info));
        return;
      }
      final row = value.data1[0];
      final int numPkg = row['NumberOfPackages'];
      final String barcodeDisplay = row['BarcodeLabelDisplay'];
      final int portMasterRefId = row['PortMasterRefId'];
      final checkList = List.generate(
        numPkg,
            (i) => '$barcodeDisplay-${i + 1}/$numPkg',
      );
      String portName = '';
      try {
        portName = objfun.WareHouseList
            .firstWhere((w) => w.Id == portMasterRefId)
            .PortName ?? '';
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
      emit(_withMsg(current, '$e\n$st', MessageType.error));
    }
  }

  void _onAddScannedItem(
      StockTransferAddScannedItem event,
      Emitter<StockTransferState> emit,
      ) {
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
    emit(current.copyWith(
      data: data.copyWith(stockNoList: newList, scnPkg: newList.length),
    ));
  }

  void _onWareHouseSelected(
      StockTransferWareHouseSelected event,
      Emitter<StockTransferState> emit,
      ) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(
      data: _loaded.data.copyWith(
        selectedWareHouseId: event.wareHouseId,
        selectedWareHouseName: event.portName,
      ),
    ));
  }

  void _onWareHouseCleared(
      StockTransferWareHouseCleared _,
      Emitter<StockTransferState> emit,
      ) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(
      data: _loaded.data.copyWith(
        selectedWareHouseId: 0,
        selectedWareHouseName: '',
      ),
    ));
  }

  void _onItemRemoved(
      StockTransferItemRemoved event,
      Emitter<StockTransferState> emit,
      ) {
    if (state is! StockTransferLoaded) return;
    final data = _loaded.data;
    final newList = List<String>.from(data.stockNoList)..removeAt(event.index);
    if (newList.isEmpty) {
      emit(StockTransferLoaded(data: const StockTransferData()));
      return;
    }
    emit(_loaded.copyWith(
      data: data.copyWith(stockNoList: newList, scnPkg: newList.length),
    ));
  }

  Future<void> _onUpdateRequested(
      StockTransferUpdateRequested _,
      Emitter<StockTransferState> emit,
      ) async {
    if (state is! StockTransferLoaded) return;
    final current = _loaded;
    final data = current.data;
    if (data.selectedWareHouseId == 0) {
      emit(_withMsg(current, 'Select WareHouse', MessageType.info));
      return;
    }
    if (data.totalPkg == 0 || data.totalPkg != data.scnPkg) {
      emit(_withMsg(current, 'Stock count mismatch', MessageType.info));
      return;
    }
    if (data.stockId == 0) {
      emit(_withMsg(current, 'Invalid stock details', MessageType.info));
      return;
    }
    emit(current.copyWith(isBusy: true));
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiUpdateStockTransfer}${data.stockId}&PortId=${data.selectedWareHouseId}&Comid=$comid",
        <String, dynamic>{}, header, null,
      );
      if (resultData == '') {
        emit(_withMsg(current, 'No response from server', MessageType.error));
        return;
      }
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true) {
        emit(StockTransferLoaded(
          data: const StockTransferData(),
          message: const StockTransferMessage('Updated Successfully', MessageType.success),
        ));
      } else {
        emit(_withMsg(current, value.Message ?? 'Update failed', MessageType.error));
      }
    } catch (e, st) {
      emit(_withMsg(current, '$e\n$st', MessageType.error));
    }
  }

  void _onCleared(StockTransferCleared _, Emitter<StockTransferState> emit) {
    emit(StockTransferLoaded(data: const StockTransferData()));
  }

  void _onMessageDismissed(
      StockTransferMessageDismissed _,
      Emitter<StockTransferState> emit,
      ) {
    if (state is! StockTransferLoaded) return;
    emit(_loaded.copyWith(clearMessage: true));
  }
}