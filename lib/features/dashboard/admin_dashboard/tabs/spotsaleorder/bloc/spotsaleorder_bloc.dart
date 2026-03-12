import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_state.dart';



class SpotSaleBloc extends Bloc<SpotSaleEvent, SpotSaleState> {
  final BuildContext context;
  final int editId;
  final ImagePicker _picker = ImagePicker();

  // ── Entry ─────────────────────────────────────────────────────────────────
  SpotSaleBloc.form(this.context, {this.editId = 0})
      : super(const SpotSaleEntryState()) {
    _register();
    add(const LoadSpotSaleListsEvent());
  }

  // ── View ──────────────────────────────────────────────────────────────────
  SpotSaleBloc.view(this.context, {DateTime? fromDate, DateTime? toDate})
      : editId = 0,
        super(SpotSaleViewState(
        fromDate: fromDate ?? DateTime.now(),
        toDate:   toDate   ?? DateTime.now(),
      )) {
    _register();
    if (fromDate != null && toDate != null) {
      add(const LoadSpotSaleViewEvent());
    }
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
    if (objfun.JobTypeList.isEmpty) {
      try {
        final comid = objfun.storagenew.getInt('Comid') ?? 0;
        final result = await objfun.apiAllinoneSelect(
            "${objfun.apiSelectJobType}$comid", null, null, context);
        if (result.isNotEmpty) {
          objfun.JobTypeList =
              result.map((e) => JobTypeModel.fromJson(e)).toList();
        }
      } catch (_) {}
    }

    // Load JobStatus
    if (objfun.JobStatusList.isEmpty) {
      try {
        final comid = objfun.storagenew.getInt('Comid') ?? 0;
        final result = await objfun.apiAllinoneSelect(
            "${objfun.apiSelectJobStatus}$comid", null, null, context);
        if (result.isNotEmpty) {
          objfun.JobStatusList =
              result.map((e) => JobStatusModel.fromJson(e)).toList();
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
      final comid      = objfun.storagenew.getInt('Comid') ?? 0;
      final employeeId = int.tryParse(
          objfun.storagenew.getString('OldUsername') ?? '0') ?? 0;

      final body = [
        {
          "CompanyRefId":  comid,
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

      final uri     = Uri.parse("${objfun.apiInsertSpotSaleEntry}?Comid=$comid");
      final request = http.MultipartRequest("POST", uri);
      request.fields["details"] = jsonEncode(body);
      request.fields["Comid"]   = comid.toString();

      if (s.pickedImage != null) {
        request.files
            .add(await http.MultipartFile.fromPath("Files", s.pickedImage!.path));
      }
      if (s.pickedPDF != null) {
        request.files
            .add(await http.MultipartFile.fromPath("Files", s.pickedPDF!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        emit(const SpotSaleSubmitSuccess());
      } else {
        emit(s.copyWith(isSubmitting: false));
        emit(SpotSaleEntryError("Server error: ${response.statusCode}"));
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

      final result = await objfun.apiAllinoneSelectArray(
        "${objfun.apiGetSpotSaleEntry}${objfun.Comid}&Fromdate=$from&Todate=$to&Id=0",
        null,
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      final records = result != null
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

  // ── Image picker helper ───────────────────────────────────────────────────
  Future<void> pickDocument() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final path = picked.path.toLowerCase();
      if (path.endsWith('.pdf')) {
        add(PickSpotSaleDocumentEvent(pdf: File(picked.path)));
      } else {
        add(PickSpotSaleDocumentEvent(image: File(picked.path)));
      }
    }
  }
}