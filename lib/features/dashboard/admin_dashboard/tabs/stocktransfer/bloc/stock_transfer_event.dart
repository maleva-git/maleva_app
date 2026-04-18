part of 'stock_transfer_bloc.dart';

abstract class StockTransferEvent extends Equatable {
  const StockTransferEvent();
  @override
  List<Object?> get props => [];
}

class StockTransferInitialized extends StockTransferEvent {
  const StockTransferInitialized();
}

class StockTransferBarcodeScanned extends StockTransferEvent {
  const StockTransferBarcodeScanned();
}

class StockTransferLoadStockData extends StockTransferEvent {
  final String barcodeLabel;
  const StockTransferLoadStockData(this.barcodeLabel);
  @override
  List<Object?> get props => [barcodeLabel];
}

class StockTransferAddScannedItem extends StockTransferEvent {
  final String barcodeString;
  const StockTransferAddScannedItem(this.barcodeString);
  @override
  List<Object?> get props => [barcodeString];
}

class StockTransferWareHouseSelected extends StockTransferEvent {
  final String portName;
  final int wareHouseId;
  const StockTransferWareHouseSelected({required this.portName, required this.wareHouseId});
  @override
  List<Object?> get props => [portName, wareHouseId];
}

class StockTransferWareHouseCleared extends StockTransferEvent {
  const StockTransferWareHouseCleared();
}

class StockTransferItemRemoved extends StockTransferEvent {
  final int index;
  const StockTransferItemRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class StockTransferUpdateRequested extends StockTransferEvent {
  const StockTransferUpdateRequested();
}

class StockTransferCleared extends StockTransferEvent {
  const StockTransferCleared();
}

class StockTransferMessageDismissed extends StockTransferEvent {
  const StockTransferMessageDismissed();
}