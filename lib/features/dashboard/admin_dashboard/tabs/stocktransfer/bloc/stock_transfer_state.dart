part of 'stock_transfer_bloc.dart';

enum MessageType { success, error, info }

class StockTransferMessage {
  final String text;
  final MessageType type;
  const StockTransferMessage(this.text, this.type);
}

class StockTransferData extends Equatable {
  final String jobNo;
  final String portName;
  final int totalPkg;
  final int scnPkg;
  final int stockId;
  final int selectedWareHouseId;
  final String selectedWareHouseName;
  final List<String> stockNoList;
  final List<String> checkStockNoList;

  const StockTransferData({
    this.jobNo = '',
    this.portName = '',
    this.totalPkg = 0,
    this.scnPkg = 0,
    this.stockId = 0,
    this.selectedWareHouseId = 0,
    this.selectedWareHouseName = '',
    this.stockNoList = const [],
    this.checkStockNoList = const [],
  });

  StockTransferData copyWith({
    String? jobNo,
    String? portName,
    int? totalPkg,
    int? scnPkg,
    int? stockId,
    int? selectedWareHouseId,
    String? selectedWareHouseName,
    List<String>? stockNoList,
    List<String>? checkStockNoList,
  }) =>
      StockTransferData(
        jobNo: jobNo ?? this.jobNo,
        portName: portName ?? this.portName,
        totalPkg: totalPkg ?? this.totalPkg,
        scnPkg: scnPkg ?? this.scnPkg,
        stockId: stockId ?? this.stockId,
        selectedWareHouseId: selectedWareHouseId ?? this.selectedWareHouseId,
        selectedWareHouseName: selectedWareHouseName ?? this.selectedWareHouseName,
        stockNoList: stockNoList ?? this.stockNoList,
        checkStockNoList: checkStockNoList ?? this.checkStockNoList,
      );

  @override
  List<Object?> get props => [
    jobNo, portName, totalPkg, scnPkg, stockId,
    selectedWareHouseId, selectedWareHouseName,
    stockNoList, checkStockNoList,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────

abstract class StockTransferState extends Equatable {
  const StockTransferState();
  @override
  List<Object?> get props => [];
}

class StockTransferInitialLoading extends StockTransferState {
  const StockTransferInitialLoading();
}

class StockTransferInitError extends StockTransferState {
  final String message;
  const StockTransferInitError(this.message);
  @override
  List<Object?> get props => [message];
}

class StockTransferLoaded extends StockTransferState {
  final StockTransferData data;
  final StockTransferMessage? message;
  final bool isBusy;

  const StockTransferLoaded({
    required this.data,
    this.message,
    this.isBusy = false,
  });

  StockTransferLoaded copyWith({
    StockTransferData? data,
    StockTransferMessage? message,
    bool clearMessage = false,
    bool? isBusy,
  }) =>
      StockTransferLoaded(
        data: data ?? this.data,
        message: clearMessage ? null : (message ?? this.message),
        isBusy: isBusy ?? this.isBusy,
      );

  @override
  List<Object?> get props => [data, message, isBusy];
}