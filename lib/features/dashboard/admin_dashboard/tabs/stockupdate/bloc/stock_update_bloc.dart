import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun; // Only for image path parsing

import '../data/stock_update_repository.dart';
import 'stock_update_event.dart';
import 'stock_update_state.dart';

class StockUpdateBloc extends Bloc<StockUpdateEvent, StockUpdateState> {
  final StockUpdateRepository repository;

  StockUpdateBloc({required this.repository}) : super(StockUpdateInitial()) {
    on<StockUpdateStarted>(_onStarted);
    on<StockUpdateBarcodeScanRequested>(_onBarcodeScan);
    on<StockUpdateScannedItemDeleted>(_onScannedItemDeleted);
    on<StockUpdateWarehouseSelected>(_onWarehouseSelected);
    on<StockUpdateWarehouseCleared>(_onWarehouseCleared);
    on<StockUpdateStatusSelected>(_onStatusSelected);
    on<StockUpdateStatusCleared>(_onStatusCleared);
    on<StockUpdateImageUploadToggled>(_onImageUploadToggled);
    on<StockUpdateImagePicked>(_onImagePicked);
    on<StockUpdateImageDeleted>(_onImageDeleted);
    on<StockUpdateSaveRequested>(_onSaveRequested);
    on<StockUpdateClearRequested>(_onClearRequested);
  }

  Future<void> _onStarted(StockUpdateStarted event, Emitter<StockUpdateState> emit) async {
    emit(StockUpdateLoading());
    try {
      await repository.prefetchJobData();
      emit(StockUpdateLoaded.empty());
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  Future<void> _onBarcodeScan(StockUpdateBarcodeScanRequested event, Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    try {
      final scanned = await repository.scanBarcode();
      if (scanned == null || scanned.isEmpty) return;

      StockUpdateLoaded updated = s;

      // First scan — load stock data
      if (s.stockNoList.isEmpty) {
        final jobId = scanned.split('-')[0];
        updated = await _loadStockData(s, jobId);
        if (updated == s) return; // Load failed or invalid state
      }

      // Validate and add
      if (updated.checkStockNoList.contains(scanned) && !updated.stockNoList.contains(scanned)) {
        final newList = List<dynamic>.from(updated.stockNoList)..add(scanned);
        emit(updated.copyWith(stockNoList: newList, scnPkg: newList.length));
      } else {
        emit(updated); // Send back state without adding
      }
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  Future<StockUpdateLoaded> _loadStockData(StockUpdateLoaded base, String barcodeLabel) async {
    final stockRow = await repository.loadStockData(barcodeLabel);
    if (stockRow == null) return base;

    final numPkg = stockRow['NumberOfPackages'] as int;
    final label = stockRow['BarcodeLabelDisplay'].toString();
    final stockId = stockRow['Id'] as int;
    final status = stockRow['Status'] as int?;
    final soRefId = stockRow['SaleOrderMasterRefId'] as int;

    // Build expected barcode list
    final checkList = List.generate(numPkg, (i) => '$label-${i + 1}/$numPkg');

    // Load Job Details and calculate new status
    final jobDetails = await repository.loadJobDetails(soRefId);

    if (jobDetails == null) return StockUpdateLoaded.empty(); // Invalid state transition

    return base.copyWith(
      jobNo: label,
      totalPkg: numPkg,
      stockId: stockId,
      status: status,
      saleOrderId: soRefId,
      checkStockNoList: checkList,
      jobId: jobDetails['jobId'],
      statusId: jobDetails['statusId'],
      statusName: jobDetails['statusName'],
      boardOfficerId1: jobDetails['boardOfficerId1'],
      boardOfficerId2: jobDetails['boardOfficerId2'],
      boardOfficerAmt1: jobDetails['boardOfficerAmt1'],
      boardOfficerAmt2: jobDetails['boardOfficerAmt2'],
    );
  }

  void _onScannedItemDeleted(StockUpdateScannedItemDeleted event, Emitter<StockUpdateState> emit) {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;
    final newList = List<dynamic>.from(s.stockNoList)..removeAt(event.index);

    if (newList.isEmpty) {
      emit(s.copyWith(stockNoList: newList, scnPkg: 0, checkStockNoList: [], totalPkg: 0, jobNo: ''));
    } else {
      emit(s.copyWith(stockNoList: newList, scnPkg: newList.length));
    }
  }

  Future<void> _onImageDeleted(StockUpdateImageDeleted event, Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    emit(StockUpdateLoading());
    try {
      final folder = s.statusName.replaceAll(' ', '');
      final imageName = s.images[event.index];

      final result = await repository.deleteImage(s.saleOrderId, folder, imageName);
      if (result?.IsSuccess == true) {
        final newImages = List<String>.from(s.images)..removeAt(event.index);
        emit(s.copyWith(images: newImages));
      } else {
        emit(s);
      }
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(StockUpdateSaveRequested event, Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    emit(StockUpdateLoading());
    try {
      final imageUrls = s.images.map((img) => '${objfun.imagepath}SalesOrder/${s.saleOrderId}/${s.statusName.replaceAll(' ', '')}/$img').toList();

      final result = await repository.saveStockUpdate(s.stockId, s.statusId, s.warehouseId, imageUrls);

      if (result?.IsSuccess == true) {
        await repository.updateBoardingOfficer(s.saleOrderId, s.statusId, s.boardOfficerId1, s.boardOfficerId2, s.boardOfficerAmt1, s.boardOfficerAmt2);
        emit(StockUpdateSaveSuccess());
      } else {
        emit(s);
      }
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  // ─── Simple Mutators ───────────────────────────────────────────────────────
  void _onWarehouseSelected(StockUpdateWarehouseSelected event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(warehouseId: event.warehouseId, warehouseName: event.warehouseName));
  }
  void _onWarehouseCleared(StockUpdateWarehouseCleared event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(warehouseId: 0, warehouseName: ''));
  }
  void _onStatusSelected(StockUpdateStatusSelected event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(statusId: event.statusId, statusName: event.statusName));
  }
  void _onStatusCleared(StockUpdateStatusCleared event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(statusId: 0, statusName: ''));
  }
  void _onImageUploadToggled(StockUpdateImageUploadToggled event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(imageUploadEnabled: event.value));
  }
  void _onImagePicked(StockUpdateImagePicked event, Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) emit((state as StockUpdateLoaded).copyWith(images: List<String>.from((state as StockUpdateLoaded).images)..add(event.imageUrl)));
  }
  void _onClearRequested(StockUpdateClearRequested event, Emitter<StockUpdateState> emit) {
    emit(StockUpdateLoaded.empty());
  }
}