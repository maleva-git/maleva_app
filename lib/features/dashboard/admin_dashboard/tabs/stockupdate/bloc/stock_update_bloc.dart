import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_state.dart';


class StockUpdateBloc
    extends Bloc<StockUpdateEvent, StockUpdateState> {
  StockUpdateBloc() : super(StockUpdateInitial()) {
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

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      StockUpdateStarted event,
      Emitter<StockUpdateState> emit) async {
    emit(StockUpdateLoading());
    try {
      await OnlineApi.GetJobNoForwarding(null, 0);
      emit(StockUpdateLoaded.empty());
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  // ── Barcode scan ─────────────────────────────────────────────────────────────
  Future<void> _onBarcodeScan(
      StockUpdateBarcodeScanRequested event,
      Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    try {
      await objfun.barcodeScanning();
      if (objfun.barcodeerror == true) return;

      final scanned = objfun.barcodestring;

      // First scan — load stock data
      StockUpdateLoaded updated = s;
      if (s.stockNoList.isEmpty) {
        final jobId = scanned.split('-')[0];
        updated = await _loadStockData(s, jobId, emit);
        if (updated == s) return; // load failed
      }

      // Validate and add
      if (updated.checkStockNoList.contains(scanned) &&
          !updated.stockNoList.contains(scanned)) {
        final newList = List<dynamic>.from(updated.stockNoList)
          ..add(scanned);
        emit(updated.copyWith(
          stockNoList: newList,
          scnPkg:      newList.length,
        ));
      } else {
        emit(updated);
        objfun.ConfirmationOK('Invalid!!!', null);
      }
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  // ── Scanned item deleted ──────────────────────────────────────────────────────
  void _onScannedItemDeleted(
      StockUpdateScannedItemDeleted event,
      Emitter<StockUpdateState> emit) {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    final newList = List<dynamic>.from(s.stockNoList)
      ..removeAt(event.index);

    if (newList.isEmpty) {
      emit(s.copyWith(
        stockNoList:      newList,
        scnPkg:           0,
        checkStockNoList: [],
        totalPkg:         0,
        jobNo:            '',
      ));
    } else {
      emit(s.copyWith(
        stockNoList: newList,
        scnPkg:      newList.length,
      ));
    }
  }

  // ── Warehouse ─────────────────────────────────────────────────────────────────
  void _onWarehouseSelected(
      StockUpdateWarehouseSelected event,
      Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) {
      emit((state as StockUpdateLoaded).copyWith(
        warehouseId:   event.warehouseId,
        warehouseName: event.warehouseName,
      ));
    }
  }

  void _onWarehouseCleared(
      StockUpdateWarehouseCleared event,
      Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) {
      emit((state as StockUpdateLoaded)
          .copyWith(warehouseId: 0, warehouseName: ''));
    }
  }

  // ── Status ────────────────────────────────────────────────────────────────────
  void _onStatusSelected(
      StockUpdateStatusSelected event,
      Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) {
      emit((state as StockUpdateLoaded).copyWith(
        statusId:   event.statusId,
        statusName: event.statusName,
      ));
    }
  }

  void _onStatusCleared(
      StockUpdateStatusCleared event,
      Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) {
      emit((state as StockUpdateLoaded)
          .copyWith(statusId: 0, statusName: ''));
    }
  }

  // ── Image upload toggle ───────────────────────────────────────────────────────
  void _onImageUploadToggled(
      StockUpdateImageUploadToggled event,
      Emitter<StockUpdateState> emit) {
    if (state is StockUpdateLoaded) {
      emit((state as StockUpdateLoaded)
          .copyWith(imageUploadEnabled: event.value));
    }
  }

  // ── Image picked ──────────────────────────────────────────────────────────────
  void _onImagePicked(
      StockUpdateImagePicked event,
      Emitter<StockUpdateState> emit) {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;
    emit(s.copyWith(
        images: List<String>.from(s.images)..add(event.imageUrl)));
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(
      StockUpdateImageDeleted event,
      Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    emit(StockUpdateLoading());
    try {
      final folder = s.statusName.replaceAll(' ', '');
      final header = {
        'Content-Type':  'application/json; charset=UTF-8',
        'Comid':         objfun.Comid.toString(),
        'Id':            s.saleOrderId.toString(),
        'FolderName':    'SalesOrder',
        'FileName':
        '/Upload/${objfun.Comid}/SalesOrder/${s.saleOrderId}/$folder/${s.images[event.index]}',
        'SubFolderName': folder,
      };
      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiDeleteimage, null, header, null);
      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          final newImages = List<String>.from(s.images)
            ..removeAt(event.index);
          emit(s.copyWith(images: newImages));
          return;
        }
      }
      emit(s);
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  // ── Save (UpdateStockStatus) ──────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      StockUpdateSaveRequested event,
      Emitter<StockUpdateState> emit) async {
    if (state is! StockUpdateLoaded) return;
    final s = state as StockUpdateLoaded;

    emit(StockUpdateLoading());
    try {
      final imageUrls = s.images
          .map((img) =>
      '${objfun.imagepath}SalesOrder/${s.saleOrderId}/${s.statusName.replaceAll(' ', '')}/$img')
          .toList();

      final comId = objfun.storagenew.getInt('Comid') ?? 0;
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiUpdateStockIn}${s.stockId}&StatusId=${s.statusId}&Comid=$comId&PortRefid=${s.warehouseId}&ImageURL',
          imageUrls,
          header,
          null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          await _updateBoardingOfficier(s, s.statusId);
          emit(StockUpdateSaveSuccess());
          return;
        }
      }
      emit(s);
    } catch (e) {
      emit(StockUpdateError(e.toString()));
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────────
  void _onClearRequested(
      StockUpdateClearRequested event,
      Emitter<StockUpdateState> emit) {
    emit(StockUpdateLoaded.empty());
  }

  // ── Helper: loadStockData (apiEditStockIn) ────────────────────────────────────
  Future<StockUpdateLoaded> _loadStockData(
      StockUpdateLoaded base,
      String barcodeLabel,
      Emitter<StockUpdateState> emit) async {
    final comId = objfun.storagenew.getInt('Comid') ?? 0;
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiEditStockIn}0&barcodeLabel=$barcodeLabel&Comid=$comId',
        null,
        header,
        null);

    if (result == '') return base;
    final value = ResponseViewModel.fromJson(result);
    if (value.IsSuccess != true) return base;

    final d       = value.data1[0];
    final numPkg  = d['NumberOfPackages'] as int;
    final label   = d['BarcodeLabelDisplay'].toString();
    final stockId = d['Id'] as int;
    final status  = d['Status'] as int?;
    final soRefId = d['SaleOrderMasterRefId'] as int;

    // Build expected barcode list
    final checkList = List.generate(
      numPkg,
          (i) => '$label-${i + 1}/$numPkg',
    );

    // Load job details (status logic)
    final withJob = await _loadJobDetails(
      base.copyWith(
        jobNo:            label,
        totalPkg:         numPkg,
        stockId:          stockId,
        status:           status,
        saleOrderId:      soRefId,
        checkStockNoList: checkList,
      ),
      soRefId,
    );
    return withJob;
  }

  // ── Helper: LoadJobDetails (apiSaleOrderDetailsLoad) ─────────────────────────
  Future<StockUpdateLoaded> _loadJobDetails(
      StockUpdateLoaded base, int saleOrderId) async {
    final comId = objfun.storagenew.getInt('Comid') ?? 0;
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiSaleOrderDetailsLoad}$comId&Id=$saleOrderId',
        {},
        header,
        null);

    if (result == '') return base;
    final value = ResponseViewModel.fromJson(result);
    if (value.IsSuccess != true) return base;

    final data    = value.data1[0];
    final soId    = data['Id'] as int;
    final jobMId  = data['JobMasterRefId'] as int;
    final jStatus = data['JStatus'] as int;

    await OnlineApi.SelectAllJobStatus(null, jobMId);

    int    statusId   = 0;
    String statusName = '';

    if (objfun.DriverLogin == 1) {
      // Driver login: 3→11, 11→19
      if (jStatus == 3) {
        statusId = 11;
      } else if (jStatus == 11) {
        statusId = 19;
      } else {
        return StockUpdateLoaded.empty(); // invalid → clear
      }
    } else {
      // Non-driver: 19→4, 4→7, 7→5
      if (jStatus == 19) {
        statusId = 4;
      } else if (jStatus == 4) {
        statusId = 7;
      } else if (jStatus == 7) {
        statusId = 5;
      } else {
        return StockUpdateLoaded.empty(); // invalid → clear
      }
    }

    final matches = objfun.JobAllStatusList
        .where((s) => s.Status == statusId)
        .toList();
    if (matches.isNotEmpty) statusName = matches[0].StatusName;

    // Load boarding officer if needed (status 7 or 5)
    int    boardId1  = 0;
    int    boardId2  = 0;
    double boardAmt1 = 0.0;
    double boardAmt2 = 0.0;

    if (statusId == 7) {
      boardId1  = objfun.EmpRefId;
      boardAmt1 = 50;
    } else if (statusId == 5) {
      await OnlineApi.EditSalesOrder(null, soId, 0);
      boardId1 = objfun.SaleEditMasterList[0]['LBoardingOfficerRefid'] ?? 0;
      if (boardId1 != objfun.EmpRefId) {
        boardId2  = objfun.EmpRefId;
        boardAmt1 = 30;
        boardAmt2 = 30;
      }
    }

    return base.copyWith(
      saleOrderId:      soId,
      jobId:            jobMId,
      statusId:         statusId,
      statusName:       statusName,
      boardOfficerId1:  boardId1,
      boardOfficerId2:  boardId2,
      boardOfficerAmt1: boardAmt1,
      boardOfficerAmt2: boardAmt2,
    );
  }

  // ── Helper: UpdateBoardingOfficier ────────────────────────────────────────────
  Future<void> _updateBoardingOfficier(
      StockUpdateLoaded s, int statusType) async {
    if (statusType != 7 && statusType != 5) return;
    if (statusType == 5 && s.boardOfficerId1 == objfun.EmpRefId) return;

    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    Map<String, dynamic> master;

    if (statusType == 7) {
      master = {
        'Id':                    s.saleOrderId,
        'CompanyRefId':          objfun.Comid,
        'EmployeeRefId':         objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'LBoardingOfficerRefid': s.boardOfficerId1,
        'LBoardingAmount':       s.boardOfficerAmt1,
      };
    } else {
      master = {
        'Id':                     s.saleOrderId,
        'CompanyRefId':           objfun.Comid,
        'UserRefId':              null,
        'EmployeeRefId':          objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'LBoardingOfficerRefid':  s.boardOfficerId1,
        'LBoardingOfficer1Refid': s.boardOfficerId2,
        'LBoardingAmount':        s.boardOfficerAmt1,
        'LBoardingAmount1':       s.boardOfficerAmt2,
      };
    }

    await objfun.apiAllinoneSelectArray(
        objfun.apiUpdateBoardingOfficer, master, header, null);
  }
}