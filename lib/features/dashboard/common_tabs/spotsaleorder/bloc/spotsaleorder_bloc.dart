import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/utils/app_globals.dart';
import '../data/spotsale_repository.dart';
import 'spotsaleorder_event.dart';
import 'spotsaleorder_state.dart';

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


    // Load JobType
    if (AppGlobals.JobTypeList.isEmpty) {
      try {
        AppGlobals.JobTypeList = await repository.fetchJobTypes();
      } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
    }

    // Load JobStatus
    if (AppGlobals.JobStatusList.isEmpty) {
      try {
        AppGlobals.JobStatusList = await repository.fetchJobStatus();
      } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
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
      final employeeId = int.tryParse(
          AppGlobals.storagenew.getString('OldUsername') ?? '0') ?? 0;

      final id = await repository.submitSpotSaleEntry(
        id: editId,
        jobTypeId: int.tryParse(s.selectedJobType ?? '') ?? 0,
        jobStatusId: int.tryParse(s.selectedJobStatus ?? '') ?? 0,
        employeeId: employeeId,
        vehicleName: s.vehicleName,
        awbNo: s.awbNo,
        quantity: s.cargoQty,
        totalWeight: s.cargoWeight,
        port: s.selectedPort ?? '',
        image: s.pickedImage,
        pdf: s.pickedPDF,
      );
      final isSuccess = id > 0;

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

      // ✅ REFACTORED: Using the injected repository
      final records = await repository.fetchSpotSaleRecords(fromDate: from, toDate: to);

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