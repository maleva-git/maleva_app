import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spareparts/bloc/spareparts_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spareparts/bloc/spareparts_state.dart';



class SparePartsBloc extends Bloc<SparePartsEvent, SparePartsState> {
  final BuildContext context;
  final ImagePicker _picker = ImagePicker();

  // ── Entry Page ────────────────────────────────────────────────────────────
  SparePartsBloc.form(this.context)
      : super(const SparePartsEntryState()) {
    _registerHandlers();
    add(const LoadSparePartsTrucksEvent());
  }

  // ── View Page ─────────────────────────────────────────────────────────────
  SparePartsBloc.view(this.context, {DateTime? fromDate, DateTime? toDate})
      : super(SparePartsViewState(
    fromDate: fromDate ?? DateTime.now(),
    toDate: toDate ?? DateTime.now(),
  )) {
    _registerHandlers();
    if (fromDate != null && toDate != null) {
      add(const LoadSparePartsViewEvent());
    }
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
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ENTRY HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onLoadTrucks(
      LoadSparePartsTrucksEvent e, Emitter<SparePartsState> emit) async {
    if (objfun.GetTruckList.isEmpty) {
      await OnlineApi.SelectTruckList(context, null);
    }
    if (state is SparePartsEntryState) {
      emit((state as SparePartsEntryState).copyWith());
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
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      final List<Map<String, dynamic>> body = [
        {
          "Comid": comid,
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

      final uri = Uri.parse("${objfun.apiInsertSpareParts}?Comid=$comid");
      final request = http.MultipartRequest("POST", uri);
      request.fields["details"] = jsonEncode(body);
      request.fields["Comid"] = comid.toString();

      if (s.pickedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath("Files", s.pickedImage!.path));
      }
      if (s.pickedPDF != null) {
        request.files.add(
            await http.MultipartFile.fromPath("Files", s.pickedPDF!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        emit(const SparePartsSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(SparePartsEntryError("Server error: ${response.statusCode}"));
      }
    } catch (err) {
      emit(s.copyWith(isSubmitting: false));
      emit(SparePartsEntryError(err.toString()));
    }
  }

  void _onReset(ResetSparePartsFormEvent e, Emitter<SparePartsState> emit) {
    emit(const SparePartsEntryState());
    add(const LoadSparePartsTrucksEvent()); // truck list keep பண்ணு
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

      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiGetSpareParts}${objfun.Comid}&Fromdate=$from&Todate=$to",
        null,
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      final records = resultData != null
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

  // ── Image Picker helper ───────────────────────────────────────────────────
  Future<void> pickDocument() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final path = picked.path.toLowerCase();
      if (path.endsWith('.pdf')) {
        add(PickSparePartsDocumentEvent(pdf: File(picked.path)));
      } else {
        add(PickSparePartsDocumentEvent(image: File(picked.path)));
      }
    }
  }
}