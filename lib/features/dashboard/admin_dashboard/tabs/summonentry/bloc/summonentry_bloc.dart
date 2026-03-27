import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/summonentry/bloc/summonentry_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/summonentry/bloc/summonentry_state.dart';



class SummonBloc extends Bloc<SummonEvent, SummonState> {
  final BuildContext context;
  final ImagePicker _picker = ImagePicker();

  // ── Entry Page init ───────────────────────────────────────────────────────
  SummonBloc.form(this.context) : super(const SummonEntryState()) {
    _registerHandlers();
  }

  // ── View Page init ────────────────────────────────────────────────────────
  SummonBloc.view(this.context, {DateTime? fromDate, DateTime? toDate})
      : super(SummonViewState(
    fromDate: fromDate ?? DateTime.now(),
    toDate: toDate ?? DateTime.now(),
  )) {
    _registerHandlers();
    if (fromDate != null && toDate != null) {
      add(const LoadSummonViewEvent());
    }
  }

  void _registerHandlers() {
    // Entry events
    on<SelectTruckEvent>(_onSelectTruck);
    on<SelectEntryDateEvent>(_onSelectEntryDate);
    on<SelectCountryEvent>(_onSelectCountry);
    on<SelectSummonTypeEvent>(_onSelectSummonType);
    on<UpdateAmountEvent>(_onUpdateAmount);
    on<UpdatePortPassEvent>(_onUpdatePortPass);
    on<UpdateTruckLcnMntEvent>(_onUpdateTruckLcnMnt);
    on<UpdateLevyEvent>(_onUpdateLevy);
    on<UpdateFuelEvent>(_onUpdateFuel);
    on<PickDocumentEvent>(_onPickDocument);
    on<SubmitSummonEvent>(_onSubmit);
    on<ResetEntryFormEvent>(_onReset);

    // View events
    on<SelectViewFromDateEvent>(_onViewFromDate);
    on<SelectViewToDateEvent>(_onViewToDate);
    on<LoadSummonViewEvent>(_onLoadView);
    _loadTrucks();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // ENTRY HANDLERS
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _loadTrucks() async {
    if (objfun.GetTruckList.isEmpty) {
      await OnlineApi.SelectTruckList(context, null);
      // Truck load ஆனதும் UI rebuild ஆகணும்னு emit பண்ணு
      emit(state as SummonEntryState); // same state re-emit → rebuild
    }
  }
  void _onSelectTruck(SelectTruckEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedTruck: e.truckId));
  }

  void _onSelectEntryDate(SelectEntryDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedDate: e.date));
  }

  void _onSelectCountry(SelectCountryEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    // Reset summon when country changes
    emit((state as SummonEntryState)
        .copyWith(selectedCountry: e.country, clearSummon: true));
  }

  void _onSelectSummonType(
      SelectSummonTypeEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(selectedSummon: e.summonType));
  }

  void _onUpdateAmount(UpdateAmountEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(amount: e.value));
  }

  void _onUpdatePortPass(UpdatePortPassEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(portPass: e.value));
  }

  void _onUpdateTruckLcnMnt(
      UpdateTruckLcnMntEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(truckLcnMnt: e.value));
  }

  void _onUpdateLevy(UpdateLevyEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(levy: e.value));
  }

  void _onUpdateFuel(UpdateFuelEvent e, Emitter<SummonState> emit) {
    if (state is! SummonEntryState) return;
    emit((state as SummonEntryState).copyWith(fuel: e.value));
  }

  Future<void> _onPickDocument(
      PickDocumentEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonEntryState) return;
    final s = state as SummonEntryState;

    if (e.image != null) {
      emit(s.copyWith(pickedImage: e.image, clearPDF: true));
    } else if (e.pdf != null) {
      emit(s.copyWith(pickedPDF: e.pdf, clearImage: true));
    }
  }

  Future<void> _onSubmit(
      SubmitSummonEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonEntryState) return;
    final s = state as SummonEntryState;

    emit(s.copyWith(isSubmitting: true));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      final List<Map<String, dynamic>> body = [
        {
          "Comid": comid,
          "Id": 0,
          "TruckName": s.selectedTruck ?? '',
          "DriverName": '',
          "Summon": s.selectedSummon ?? '',
          "PortPass": s.portPass,
          "TruckLcnMnt": s.truckLcnMnt,
          "Levy": s.levy,
          "Fuel": s.fuel,
          "Country": s.selectedCountry,
          "EntryDate": s.selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(s.selectedDate!)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()),
          "Amount": s.amount,
          "DocumentPath": "",
        }
      ];

      final uri = Uri.parse("${objfun.apiInsertSummonParts}?Comid=$comid");
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
        emit(const SummonSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(SummonEntryError("Server error: ${response.statusCode}"));
      }
    } catch (err) {
      emit(s.copyWith(isSubmitting: false));
      emit(SummonEntryError(err.toString()));
    }
  }

  void _onReset(ResetEntryFormEvent e, Emitter<SummonState> emit) {
    emit(const SummonEntryState());
  }

  // ════════════════════════════════════════════════════════════════════════════
  // VIEW HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  void _onViewFromDate(
      SelectViewFromDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonViewState) return;
    emit((state as SummonViewState).copyWith(fromDate: e.date));
  }

  void _onViewToDate(SelectViewToDateEvent e, Emitter<SummonState> emit) {
    if (state is! SummonViewState) return;
    emit((state as SummonViewState).copyWith(toDate: e.date));
  }

  Future<void> _onLoadView(
      LoadSummonViewEvent e, Emitter<SummonState> emit) async {
    if (state is! SummonViewState) return;
    final s = state as SummonViewState;

    emit(s.copyWith(isLoading: true));

    try {
      final String from = DateFormat('yyyy-MM-dd').format(s.fromDate);
      final String to = DateFormat('yyyy-MM-dd').format(s.toDate);

      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiGetSummonParts}${objfun.Comid}&Fromdate=$from&Todate=$to",
        null,
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      final records = resultData != null
          ? List<Map<String, dynamic>>.from(resultData)
          : <Map<String, dynamic>>[];

      emit(s.copyWith(records: records, isLoading: false));
    } catch (err) {
      emit(SummonViewError(
        message: err.toString(),
        fromDate: s.fromDate,
        toDate: s.toDate,
      ));
    }
  }

  // ── Image Picker helper (called from UI via PickDocumentEvent) ─────────────
  Future<void> pickDocument(BuildContext ctx) async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final path = picked.path.toLowerCase();
      if (path.endsWith('.pdf')) {
        add(PickDocumentEvent(pdf: File(picked.path)));
      } else {
        add(PickDocumentEvent(image: File(picked.path)));
      }
    }
  }
}