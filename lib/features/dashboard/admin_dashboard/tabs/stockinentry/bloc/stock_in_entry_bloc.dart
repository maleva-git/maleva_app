import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockinentry/bloc/stock_in_entry_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockinentry/bloc/stock_in_entry_state.dart';



class StockInEntryBloc
    extends Bloc<StockInEntryEvent, StockInEntryState> {
  StockInEntryBloc() : super(StockInEntryInitial()) {
    on<StockInEntryStarted>(_onStarted);
    on<StockInEntryBillTypeChanged>(_onBillTypeChanged);
    on<StockInEntryJobNoTextChanged>(_onJobNoTextChanged);
    on<StockInEntryJobNoSelected>(_onJobNoSelected);
    on<StockInEntryOverlayDismissed>(_onOverlayDismissed);
    on<StockInEntryDateChanged>(_onDateChanged);
    on<StockInEntryPackagesChanged>(_onPackagesChanged);
    on<StockInEntryStatusSelected>(_onStatusSelected);
    on<StockInEntryStatusCleared>(_onStatusCleared);
    on<StockInEntryImageUploadToggled>(_onImageUploadToggled);
    on<StockInEntryImagePicked>(_onImagePicked);
    on<StockInEntryImageDeleted>(_onImageDeleted);
    on<StockInEntrySaveRequested>(_onSaveRequested);
    on<StockInEntryClearRequested>(_onClearRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      StockInEntryStarted event,
      Emitter<StockInEntryState> emit) async {
    emit(StockInEntryLoading());
    try {
      await OnlineApi.SelectWareHouse(null);
      await OnlineApi.SelectStockJob(null);
      await OnlineApi.MaxStockNo(null);
      await OnlineApi.GetJobNoForwarding(null, 0);

      final stockNo = objfun.MaxStockNum;
      final base    = StockInEntryLoaded.empty(stockNo: stockNo);

      // Pre-fill from dashboard
      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4
            ? event.jobNo!.substring(4)
            : event.jobNo!;

        // Check stock exists
        final isPresent = objfun.StockJobList
            .any((w) => w.Id == event.jobId);
        if (isPresent) {
          emit(base);
          emit(StockInEntryStockExistsConfirmNeeded(
              saleOrderId: event.jobId!, jobNo: shortNo));
          return;
        }

        final loaded = await _loadJobDetails(
            base, event.jobId!, shortNo, emit);
        emit(loaded);
      } else {
        emit(base);
      }
    } catch (e) {
      emit(StockInEntryError(e.toString()));
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      StockInEntryBillTypeChanged event,
      Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    try {
      await OnlineApi.GetJobNoForwarding(
          null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(
      billType:        event.billType,
      jobNoText:       '',
      saleOrderId:     0,
      jobNoSuggestions: [],
    ));
  }

  // ── Job No typed ─────────────────────────────────────────────────────────────
  void _onJobNoTextChanged(
      StockInEntryJobNoTextChanged event,
      Emitter<StockInEntryState> emit) {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    final q = event.text.trim();
    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      filtered = objfun.JobNoList
          .where((e) => e['CNumber'].toString().contains(q))
          .toList();
    }
    emit(s.copyWith(
      jobNoText:        q,
      jobNoSuggestions: filtered,
      saleOrderId:      0,
    ));
  }

  // ── Job No selected ───────────────────────────────────────────────────────────
  Future<void> _onJobNoSelected(
      StockInEntryJobNoSelected event,
      Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    // Check if stock already exists
    final isPresent = objfun.StockJobList
        .any((w) => w.Id == event.saleOrderId);
    if (isPresent && !event.stockExistsConfirmed) {
      emit(StockInEntryStockExistsConfirmNeeded(
          saleOrderId: event.saleOrderId,
          jobNo: event.jobNo));
      return;
    }

    emit(StockInEntryLoading());
    final loaded = await _loadJobDetails(
        s, event.saleOrderId, event.jobNo, emit);
    emit(loaded);
  }

  // ── Overlay dismissed ─────────────────────────────────────────────────────────
  void _onOverlayDismissed(
      StockInEntryOverlayDismissed event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded)
          .copyWith(jobNoSuggestions: []));
    }
  }

  // ── Date ─────────────────────────────────────────────────────────────────────
  void _onDateChanged(
      StockInEntryDateChanged event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded)
          .copyWith(stockDate: event.date));
    }
  }

  // ── Packages ──────────────────────────────────────────────────────────────────
  void _onPackagesChanged(
      StockInEntryPackagesChanged event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded)
          .copyWith(packages: event.value));
    }
  }

  // ── Status ────────────────────────────────────────────────────────────────────
  void _onStatusSelected(
      StockInEntryStatusSelected event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded).copyWith(
          statusId: event.statusId, statusName: event.statusName));
    }
  }

  void _onStatusCleared(
      StockInEntryStatusCleared event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded)
          .copyWith(statusId: 0, statusName: ''));
    }
  }

  // ── Image upload toggle ───────────────────────────────────────────────────────
  void _onImageUploadToggled(
      StockInEntryImageUploadToggled event,
      Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      emit((state as StockInEntryLoaded)
          .copyWith(imageUploadEnabled: event.value));
    }
  }

  // ── Image picked ──────────────────────────────────────────────────────────────
  void _onImagePicked(
      StockInEntryImagePicked event,
      Emitter<StockInEntryState> emit) {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    emit(s.copyWith(
        images: List<String>.from(s.images)..add(event.imageUrl)));
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(
      StockInEntryImageDeleted event,
      Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    emit(StockInEntryLoading());
    try {
      final folder =
      s.statusName.replaceAll(' ', '');
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
      emit(StockInEntryError(e.toString()));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      StockInEntrySaveRequested event,
      Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    emit(StockInEntryLoading());
    try {
      final preJob = int.parse(s.billType) == 1 ? 'TR00' : 'MY00';
      final imageUrls = s.images
          .map((img) =>
      '${objfun.imagepath}SalesOrder/${s.saleOrderId}/${s.statusName.replaceAll(' ', '')}/$img')
          .toList();

      final master = [
        {
          'Id':                     0,
          'CompanyRefId':           objfun.Comid,
          'UserRefId':              objfun.Comid,
          'EmployeeRefId':          objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
          'SaleOrderMasterRefId':   s.saleOrderId,
          'StockDate':              DateTime.parse(s.stockDate).toIso8601String(),
          'CNumberDisplay':         '',
          'CNumber':                0,
          'NumberOfPackages':       s.packages,
          'statusId':               s.statusId,
          'PortMasterRefId':        0,
          'Barcode':                preJob + s.jobNoText,
          'BarcodeLabelDisplay':    preJob + s.jobNoText,
          'Status':                 0,
          'ImageURL':               imageUrls,
        }
      ];

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiInsertStockIn}${objfun.Comid}',
          master,
          header,
          null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          final stockId = value.data2 as int;
          emit(StockInEntrySaveSuccess(stockId));
          return;
        }
      }
      emit(s);
    } catch (e) {
      emit(StockInEntryError(e.toString()));
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────────
  void _onClearRequested(
      StockInEntryClearRequested event,
      Emitter<StockInEntryState> emit) {
    final stockNo = state is StockInEntryLoaded
        ? (state as StockInEntryLoaded).stockNo
        : '';
    emit(StockInEntryLoaded.empty(stockNo: stockNo));
  }

  // ── Helper: LoadJobDetails API call ──────────────────────────────────────────
  Future<StockInEntryLoaded> _loadJobDetails(
      StockInEntryLoaded base,
      int saleOrderId,
      String jobNo,
      Emitter<StockInEntryState> emit) async {
    final comId = objfun.storagenew.getInt('Comid') ?? 0;
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiSaleOrderDetailsLoad}$comId&Id=$saleOrderId',
        {},
        header,
        null);

    String shipName     = '';
    String customerName = '';
    String jobDate      = '';
    int    jobMasterId  = 0;
    int    weightPkg    = 0;

    if (result != '') {
      final value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true) {
        final data = value.data1[0];
        customerName = data['CustomerName'] ?? '';
        shipName     = (customerName.isNotEmpty)
            ? (data['LoadingVesselName'] ?? '')
            : (data['OffVesselName'] ?? '');
        jobDate      = data['SSaleDate'] ?? '';
        jobMasterId  = data['JobMasterRefId'] ?? 0;

        // Parse packages count from quantity string
        final qty     = data['Quantity']?.toString() ?? '0';
        final match   = RegExp(r'\d+').stringMatch(qty);
        weightPkg     = int.tryParse(match ?? '0') ?? 0;

        await OnlineApi.SelectAllJobStatus(null, jobMasterId);
      }
    }

    return base.copyWith(
      jobNoText:        jobNo,
      saleOrderId:      saleOrderId,
      jobNoSuggestions: [],
      shipName:         shipName,
      customerName:     customerName,
      jobDate:          jobDate,
      jobMasterId:      jobMasterId,
      weightPkg:        weightPkg,
    );
  }
}