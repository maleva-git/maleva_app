import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/stock_in_entry_repository.dart';
import 'stock_in_entry_event.dart';
import 'stock_in_entry_state.dart';

class StockInEntryBloc extends Bloc<StockInEntryEvent, StockInEntryState> {
  final StockInEntryRepository repository;

  // Local caching to replace objfun globals
  List<dynamic> _jobNoList = [];
  List<dynamic> _stockJobList = [];
  List<dynamic> _jobAllStatusList = [];

  StockInEntryBloc({required this.repository}) : super(StockInEntryInitial()) {
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
    on<StockInEntryEditSalesOrderRequested>(_onEditSalesOrderRequested);
    on<StockInEntryNavigationHandled>(_onNavigationHandled);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(StockInEntryStarted event, Emitter<StockInEntryState> emit) async {
    emit(StockInEntryLoading());
    try {
      // 0 = default BillType param equivalent from original code
      final initData = await repository.fetchInitialData(0);

      final stockNo = initData['maxStockNo'] as String;
      _stockJobList = initData['stockJobList'] as List<dynamic>;
      _jobNoList = initData['jobNoList'] as List<dynamic>;

      final base = StockInEntryLoaded.empty(stockNo: stockNo);

      // Pre-fill from dashboard
      if (event.jobId != null && event.jobNo != null) {
        final shortNo = event.jobNo!.length >= 4 ? event.jobNo!.substring(4) : event.jobNo!;

        // Check stock exists using local list
        final isPresent = _stockJobList.any((w) => w['Id'] == event.jobId);
        if (isPresent) {
          emit(base);
          emit(StockInEntryStockExistsConfirmNeeded(saleOrderId: event.jobId!, jobNo: shortNo));
          return;
        }

        final loaded = await _loadJobDetails(base, event.jobId!, shortNo, emit);
        emit(loaded);
      } else {
        emit(base);
      }
    } catch (e) {
      emit(StockInEntryError(e.toString()));
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(StockInEntryBillTypeChanged event, Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    try {
      _jobNoList = await repository.fetchJobNoList(int.parse(event.billType));
    } catch (_) {}

    emit(s.copyWith(
      billType: event.billType,
      jobNoText: '',
      saleOrderId: 0,
      jobNoSuggestions: [],
    ));
  }

  // ── Job No typed ─────────────────────────────────────────────────────────────
  void _onJobNoTextChanged(StockInEntryJobNoTextChanged event, Emitter<StockInEntryState> emit) {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    final q = event.text.trim();

    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      filtered = _jobNoList.where((e) => e['CNumber'].toString().contains(q)).toList();
    }

    emit(s.copyWith(
      jobNoText: q,
      jobNoSuggestions: filtered,
      saleOrderId: 0,
    ));
  }

  // ── Job No selected ───────────────────────────────────────────────────────────
  Future<void> _onJobNoSelected(StockInEntryJobNoSelected event, Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    // Check if stock already exists
    final isPresent = _stockJobList.any((w) => w['Id'] == event.saleOrderId);
    if (isPresent && !event.stockExistsConfirmed) {
      emit(StockInEntryStockExistsConfirmNeeded(saleOrderId: event.saleOrderId, jobNo: event.jobNo));
      return;
    }

    emit(StockInEntryLoading());
    final loaded = await _loadJobDetails(s, event.saleOrderId, event.jobNo, emit);
    emit(loaded);
  }

  // ── Helper: LoadJobDetails API call ──────────────────────────────────────────
  Future<StockInEntryLoaded> _loadJobDetails(StockInEntryLoaded base, int saleOrderId, String jobNo, Emitter<StockInEntryState> emit) async {
    final details = await repository.fetchJobDetails(saleOrderId);

    _jobAllStatusList = details['jobStatuses'];
    objfun.JobAllStatusList = _jobAllStatusList.map((e) => JobAllStatusModel.fromJson(e)).toList(); // Propagate for JobAllStatus screen

    return base.copyWith(
      jobNoText: jobNo,
      saleOrderId: saleOrderId,
      jobNoSuggestions: [],
      shipName: details['shipName'],
      customerName: details['customerName'],
      jobDate: details['jobDate'],
      jobMasterId: details['jobMasterId'],
      weightPkg: details['weightPkg'],
    );
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(StockInEntryImageDeleted event, Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    emit(StockInEntryLoading());
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
      emit(StockInEntryError(e.toString()));
    }
  }

  
  // ── Edit Sales Order ─────────────────────────────────────────────────────────
  Future<void> _onEditSalesOrderRequested(StockInEntryEditSalesOrderRequested event, Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    
    // Fetch data from repository
    final result = await repository.fetchSalesOrderForEdit(event.saleOrderId, event.jobNo);
    
    // We only need the master list for StockInEntry navigation
    final masterList = result['masterList'] as List<dynamic>;
    
    emit(s.copyWith(
      navigateEditSalesOrder: true,
      saleEditMasterList: masterList,
    ));
  }

  void _onNavigationHandled(StockInEntryNavigationHandled event, Emitter<StockInEntryState> emit) {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;
    emit(s.copyWith(navigateEditSalesOrder: false));
  }

  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(StockInEntrySaveRequested event, Emitter<StockInEntryState> emit) async {
    if (state is! StockInEntryLoaded) return;
    final s = state as StockInEntryLoaded;

    emit(StockInEntryLoading());
    try {
      final preJob = int.parse(s.billType) == 1 ? 'TR00' : 'MY00';
      // objfun is only used here for formatting the image URL prefix structure securely
      final imageUrls = s.images.map((img) => '${objfun.imagepath}SalesOrder/${s.saleOrderId}/${s.statusName.replaceAll(' ', '')}/$img').toList();

      final empRefId =  objfun.EmpRefId ;
      final comId = AppPreferences.getComid();

      final master = [{
        'Id': 0,
        'CompanyRefId': comId,
        'UserRefId': comId,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'SaleOrderMasterRefId': s.saleOrderId,
        'StockDate': DateTime.parse(s.stockDate).toIso8601String(),
        'CNumberDisplay': '',
        'CNumber': 0,
        'NumberOfPackages': s.packages,
        'statusId': s.statusId,
        'PortMasterRefId': 0,
        'Barcode': preJob + s.jobNoText,
        'BarcodeLabelDisplay': preJob + s.jobNoText,
        'Status': 0,
        'ImageURL': imageUrls,
      }];

      final result = await repository.saveStockIn(master);

      if (result?.IsSuccess == true) {
        final stockId = result?.data2 as int;
        emit(StockInEntrySaveSuccess(stockId));
      } else {
        emit(s);
      }
    } catch (e) {
      emit(StockInEntryError(e.toString()));
    }
  }

  // ── Other standard state mutators ──────────────────────────────────────────
  void _onOverlayDismissed(StockInEntryOverlayDismissed event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(jobNoSuggestions: []));
  }
  void _onDateChanged(StockInEntryDateChanged event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(stockDate: event.date));
  }
  void _onPackagesChanged(StockInEntryPackagesChanged event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(packages: event.value));
  }
  void _onStatusSelected(StockInEntryStatusSelected event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(statusId: event.statusId, statusName: event.statusName));
  }
  void _onStatusCleared(StockInEntryStatusCleared event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(statusId: 0, statusName: ''));
  }
  void _onImageUploadToggled(StockInEntryImageUploadToggled event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) emit((state as StockInEntryLoaded).copyWith(imageUploadEnabled: event.value));
  }
  void _onImagePicked(StockInEntryImagePicked event, Emitter<StockInEntryState> emit) {
    if (state is StockInEntryLoaded) {
      final s = state as StockInEntryLoaded;
      emit(s.copyWith(images: List<String>.from(s.images)..add(event.imageUrl)));
    }
  }
  void _onClearRequested(StockInEntryClearRequested event, Emitter<StockInEntryState> emit) {
    final stockNo = state is StockInEntryLoaded ? (state as StockInEntryLoaded).stockNo : '';
    emit(StockInEntryLoaded.empty(stockNo: stockNo));
  }
}