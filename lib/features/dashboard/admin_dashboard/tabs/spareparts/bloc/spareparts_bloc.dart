import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/spareparts_repository.dart';
import 'spareparts_event.dart';
import 'spareparts_state.dart';

class SparePartsBloc extends Bloc<SparePartsEvent, SparePartsState> {
  // ❌ REMOVED: final BuildContext context;
  // ❌ REMOVED: final ImagePicker _picker = ImagePicker(); (Moved to UI)
  final SparePartsRepository repository; // ✅ Injected Repository

  // ── Entry Page ────────────────────────────────────────────────────────────
  SparePartsBloc.form({required this.repository})
      : super(const SparePartsEntryState()) {
    _registerHandlers();
    add(const LoadSparePartsTrucksEvent());
  }

  // ── View Page ─────────────────────────────────────────────────────────────
  SparePartsBloc.view({
    required this.repository,
    DateTime? fromDate,
    DateTime? toDate
  }) : super(SparePartsViewState(
    // ✅ Defaults to 30 days ago
    fromDate: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
    toDate: toDate ?? DateTime.now(),
  )) {
    _registerHandlers();
    add(const LoadSparePartsViewEvent()); // Auto-load since we have defaults
  }

  void _registerHandlers() {
    // Entry
    on<LoadSparePartsTrucksEvent>(_onLoadTrucks);
    on<SelectSparePartsTruckEvent>(_onSelectTruck);
    on<SelectSparePartsDateEvent>(_onSelectDate);
    on<UpdateSparePartsTextEvent>(_onUpdateText);
    on<UpdateSparePartsAmountEvent>(_onUpdateAmount);
    on<PickSparePartsDocumentEvent>(_onPickDocument);
    on<SubmitSparePartsEvent>(_onSubmit);
    on<ResetSparePartsFormEvent>(_onReset);

    // View
    on<SelectSparePartsFromDateEvent>(_onFromDate);
    on<SelectSparePartsToDateEvent>(_onToDate);
    on<LoadSparePartsViewEvent>(_onLoadView);
    on<SelectSparePartsRecordEvent>(_onSelectRecord);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ENTRY HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onLoadTrucks(
      LoadSparePartsTrucksEvent e, Emitter<SparePartsState> emit) async {
    if (objfun.GetTruckList.isEmpty) {
      await repository.fetchTrucks();
    }
    if (state is SparePartsEntryState) {
      emit((state as SparePartsEntryState).copyWith());
    }
  }

  void _onSelectRecord(
      SelectSparePartsRecordEvent event,
      Emitter<SparePartsState> emit,
      ) {
    if (state is SparePartsViewState) {
      emit((state as SparePartsViewState)
          .copyWith(selectedRecord: event.record));
    }
  }

  void _onSelectTruck(
      SelectSparePartsTruckEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsEntryState) return;
    emit((state as SparePartsEntryState).copyWith(selectedTruck: e.truckId));
  }

  void _onSelectDate(
      SelectSparePartsDateEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsEntryState) return;
    emit((state as SparePartsEntryState).copyWith(selectedDate: e.date));
  }

  void _onUpdateText(
      UpdateSparePartsTextEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsEntryState) return;
    emit((state as SparePartsEntryState).copyWith(spareParts: e.value));
  }

  void _onUpdateAmount(
      UpdateSparePartsAmountEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsEntryState) return;
    emit((state as SparePartsEntryState).copyWith(amount: e.value));
  }

  void _onPickDocument(
      PickSparePartsDocumentEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsEntryState) return;
    final s = state as SparePartsEntryState;
    if (e.image != null) {
      emit(s.copyWith(pickedImage: e.image, clearPDF: true));
    } else if (e.pdf != null) {
      emit(s.copyWith(pickedPDF: e.pdf, clearImage: true));
    }
  }

  Future<void> _onSubmit(
      SubmitSparePartsEvent e, Emitter<SparePartsState> emit) async {
    if (state is! SparePartsEntryState) return;
    final s = state as SparePartsEntryState;

    emit(s.copyWith(isSubmitting: true));

    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;

      final List<Map<String, dynamic>> body = [
        {
          "Comid": comId,
          "Id": 0,
          "TruckName": s.selectedTruck ?? '',
          "DriverName": '',
          "SpareParts": s.spareParts,
          "EntryDate": s.selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(s.selectedDate!)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "Amount": s.amount,
          "DocumentPath": "",
        }
      ];

      // ✅ REFACTORED: Using the injected repository
      final isSuccess = await repository.submitSpareParts(
        body: body,
        comId: comId,
        image: s.pickedImage,
        pdf: s.pickedPDF,
      );

      if (isSuccess) {
        emit(const SparePartsSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(const SparePartsEntryError("Server error: Failed to submit"));
      }
    } catch (err) {
      emit(s.copyWith(isSubmitting: false));
      emit(SparePartsEntryError(err.toString()));
    }
  }

  void _onReset(ResetSparePartsFormEvent e, Emitter<SparePartsState> emit) {
    emit(const SparePartsEntryState());
    add(const LoadSparePartsTrucksEvent()); // keep truck list
  }

  // ════════════════════════════════════════════════════════════════════════════
  // VIEW HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  void _onFromDate(
      SelectSparePartsFromDateEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsViewState) return;
    emit((state as SparePartsViewState).copyWith(fromDate: e.date));
  }

  void _onToDate(
      SelectSparePartsToDateEvent e, Emitter<SparePartsState> emit) {
    if (state is! SparePartsViewState) return;
    emit((state as SparePartsViewState).copyWith(toDate: e.date));
  }

  Future<void> _onLoadView(
      LoadSparePartsViewEvent e, Emitter<SparePartsState> emit) async {
    if (state is! SparePartsViewState) return;
    final s = state as SparePartsViewState;

    emit(s.copyWith(isLoading: true));

    try {
      final from = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final to   = DateFormat('yyyy-MM-dd').format(s.toDate);
      final comId = objfun.storagenew.getInt('Comid') ?? 0;

      // ✅ REFACTORED: Using the injected repository
      final resultData = await repository.fetchSparePartsRecords(
          comId: comId,
          fromDate: from,
          toDate: to
      );

      final records = resultData != null && resultData is List
          ? List<Map<String, dynamic>>.from(resultData)
          : <Map<String, dynamic>>[];

      emit(s.copyWith(records: records, isLoading: false));
    } catch (err) {
      emit(SparePartsViewError(
        message: err.toString(),
        fromDate: s.fromDate,
        toDate: s.toDate,
      ));
    }
  }
}