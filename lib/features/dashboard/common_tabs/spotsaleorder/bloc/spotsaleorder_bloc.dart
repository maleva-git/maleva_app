import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/utils/app_globals.dart';
import '../data/spotsale_repository.dart';
import 'spotsaleorder_event.dart';
import 'spotsaleorder_state.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';

class SpotSaleBloc extends Bloc<SpotSaleEvent, SpotSaleState> {
  final SpotSaleRepository repository; // ✅ Injected Repository
  final int editId;

  // ── Entry ─────────────────────────────────────────────────────────────────
  SpotSaleBloc.form({required this.repository, this.editId = 0})
      : super(const SpotSaleEntryState()) {
    _register();
    add(const LoadSpotSaleListsEvent());
  }

  // ── View ──────────────────────────────────────────────────────────────────
  SpotSaleBloc.view({
    required this.repository,
    DateTime? fromDate,
    DateTime? toDate
  })  : editId = 0,
        super(SpotSaleViewState(
        // ✅ Defaults to 30 days ago
        fromDate: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
        toDate:   toDate   ?? DateTime.now(),
      )) {
    _register();
    add(const LoadSpotSaleViewEvent()); // Auto-load since we have defaults
  }

  void _register() {
    on<LoadSpotSaleListsEvent>(_onLoadLists);
    on<SelectJobTypeEvent>(_onJobType);
    on<SelectJobStatusEvent>(_onJobStatus);
    on<SelectPortEvent>(_onPort);
    on<UpdateCargoQtyEvent>(_onQty);
    on<UpdateVehicleNameEvent>(_onVehicle);
    on<UpdateAWBNoEvent>(_onAWB);
    on<UpdateCargoWeightEvent>(_onWeight);
    on<PickSpotSaleDocumentEvent>(_onPickDoc);
    on<SubmitSpotSaleEvent>(_onSubmit);
    on<ResetSpotSaleFormEvent>(_onReset);

    // View
    on<SelectViewFromDateEvent>(_onViewFrom);
    on<SelectViewToDateEvent>(_onViewTo);
    on<LoadSpotSaleViewEvent>(_onLoadView);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ENTRY HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onLoadLists(
      LoadSpotSaleListsEvent e, Emitter<SpotSaleState> emit) async {
    if (state is! SpotSaleEntryState) return;

    final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    // Load JobType
    if (AppGlobals.JobTypeList.isEmpty) {
      try {
        final result = await repository.fetchJobTypes(comId);
        if (result != null && result is List && result.isNotEmpty) {
          AppGlobals.JobTypeList =
              result.map((e) => JobTypeModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    // Load JobStatus
    if (AppGlobals.JobStatusList.isEmpty) {
      try {
        final result = await repository.fetchJobStatus(comId);
        if (result != null && result is List && result.isNotEmpty) {
          AppGlobals.JobStatusList =
              result.map((e) => JobStatusModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    if (state is SpotSaleEntryState) {
      emit((state as SpotSaleEntryState).copyWith(listsLoaded: true));
    }
  }

  void _onJobType(SelectJobTypeEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(selectedJobType: e.id));
  }

  void _onJobStatus(SelectJobStatusEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(selectedJobStatus: e.id));
  }

  void _onPort(SelectPortEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(selectedPort: e.name));
  }

  void _onQty(UpdateCargoQtyEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(cargoQty: e.value));
  }

  void _onVehicle(UpdateVehicleNameEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(vehicleName: e.value));
  }

  void _onAWB(UpdateAWBNoEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(awbNo: e.value));
  }

  void _onWeight(UpdateCargoWeightEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    emit((state as SpotSaleEntryState).copyWith(cargoWeight: e.value));
  }

  void _onPickDoc(PickSpotSaleDocumentEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleEntryState) return;
    final s = state as SpotSaleEntryState;
    if (e.image != null) {
      emit(s.copyWith(pickedImage: e.image, clearPDF: true, clearNetworkImage: true));
    } else if (e.pdf != null) {
      emit(s.copyWith(pickedPDF: e.pdf, clearImage: true, clearNetworkImage: true));
    }
  }

  Future<void> _onSubmit(
      SubmitSpotSaleEvent e, Emitter<SpotSaleState> emit) async {
    if (state is! SpotSaleEntryState) return;
    final s = state as SpotSaleEntryState;

    emit(s.copyWith(isSubmitting: true));

    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final employeeId = int.tryParse(
          AppGlobals.storagenew.getString('OldUsername') ?? '0') ?? 0;

      final body = [
        {
          "CompanyRefId":  comId,
          "Id":            editId,
          "EmployeeRefId": employeeId,
          "JobMasterRefId": s.selectedJobType ?? '',
          "CustomerRefId": 0,
          "VechicelName":  s.vehicleName,
          "AWBNo":         s.awbNo,
          "Quantity":      s.cargoQty,
          "TotalWeight":   s.cargoWeight,
          "JStatus":       s.selectedJobStatus ?? '',
          "Port":          s.selectedPort ?? '',
          "DocumentPath":  "",
        }
      ];

      // ✅ REFACTORED: Using the injected repository
      final isSuccess = await repository.submitSpotSaleEntry(
        body: body,
        comId: comId,
        image: s.pickedImage,
        pdf: s.pickedPDF,
      );

      if (isSuccess) {
        emit(const SpotSaleSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(const SpotSaleEntryError("Server error: Failed to submit"));
      }
    } catch (err) {
      emit(s.copyWith(isSubmitting: false));
      emit(SpotSaleEntryError(err.toString()));
    }
  }

  void _onReset(ResetSpotSaleFormEvent e, Emitter<SpotSaleState> emit) {
    emit(const SpotSaleEntryState(listsLoaded: true));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // VIEW HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  void _onViewFrom(SelectViewFromDateEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleViewState) return;
    emit((state as SpotSaleViewState).copyWith(fromDate: e.date));
  }

  void _onViewTo(SelectViewToDateEvent e, Emitter<SpotSaleState> emit) {
    if (state is! SpotSaleViewState) return;
    emit((state as SpotSaleViewState).copyWith(toDate: e.date));
  }

  Future<void> _onLoadView(
      LoadSpotSaleViewEvent e, Emitter<SpotSaleState> emit) async {
    if (state is! SpotSaleViewState) return;
    final s = state as SpotSaleViewState;

    emit(s.copyWith(isLoading: true));

    try {
      final from = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final to   = DateFormat('yyyy-MM-dd').format(s.toDate);
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

      // ✅ REFACTORED: Using the injected repository
      final result = await repository.fetchSpotSaleRecords(
          comId: comId,
          fromDate: from,
          toDate: to
      );

      final records = result != null && result is List
          ? List<Map<String, dynamic>>.from(result)
          : <Map<String, dynamic>>[];

      emit(s.copyWith(records: records, isLoading: false));
    } catch (err) {
      emit(SpotSaleViewError(
        message:  err.toString(),
        fromDate: s.fromDate,
        toDate:   s.toDate,
      ));
    }
  }
}