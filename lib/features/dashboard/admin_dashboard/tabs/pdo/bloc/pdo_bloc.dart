import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'pdo_event.dart';
import 'pdo_state.dart';

class PDOBloc extends Bloc<PDOViewEvent, PDOViewState> {
  final BuildContext context;

  // ── Params passed from parent page ───────────────────────────────────────
  final String fromDate;
  final String toDate;
  final int driverId;
  final int truckId;
  final int employeeId;
  final String search;

  PDOBloc(
      this.context, {
        required this.fromDate,
        required this.toDate,
        this.driverId = 0,
        this.truckId = 0,
        this.employeeId = 0,
        this.search = '',
      }) : super(const PDOViewLoading()) {
    on<LoadPDOViewEvent>(_onLoad);
    on<SearchPDOEvent>(_onSearch);
    on<TogglePDOVerifyEvent>(_onToggle);
    on<SavePDOEvent>(_onSave);
    on<ResetPDOSaveStatusEvent>(_onResetStatus);

    add(const LoadPDOViewEvent());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  PDOViewLoaded get _s => state as PDOViewLoaded;

  // ════════════════════════════════════════════════════════════════════════════
  // LOAD
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _onLoad(
      LoadPDOViewEvent e, Emitter<PDOViewState> emit) async {
    emit(const PDOViewLoading());
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      final result = await objfun.apiAllinoneSelect(
        "${objfun.apiSelectRTIView}$comid"
            "&Fromdate=$fromDate&Todate=$toDate"
            "&DId=$driverId&TId=$truckId&Employeeid=$employeeId"
            "&Search=$search",
        null,
        null,
        context,
      );

      List<RTIMasterViewModel> masters = [];
      List<RTIDetailsViewModel> details = [];

      if (result != null && result.isNotEmpty) {
        masters = (result[0]["salemaster"] as List)
            .map((e) => RTIMasterViewModel.fromJson(e))
            .toList();
        details = (result[0]["saledetails"] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e))
            .toList();
      }

      emit(PDOViewLoaded(
        allMasters:      masters,
        filteredMasters: masters,
        details:         details,
      ));
    } catch (err) {
      emit(PDOViewError(err.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH — filter masters by RTINo / DriverName / TruckName
  // ════════════════════════════════════════════════════════════════════════════
  void _onSearch(SearchPDOEvent e, Emitter<PDOViewState> emit) {
    if (state is! PDOViewLoaded) return;
    final q = e.query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? List<RTIMasterViewModel>.from(_s.allMasters)
        : _s.allMasters.where((m) {
      return (m.RTINoDisplay.toLowerCase().contains(q)) ||
          (m.DriverName?.toLowerCase().contains(q) ?? false) ||
          (m.TruckName?.toLowerCase().contains(q) ?? false);
    }).toList();

    emit(_s.copyWith(
      filteredMasters: filtered,
      searchQuery:     e.query,
    ));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TOGGLE VERIFY CHECKBOX
  // ════════════════════════════════════════════════════════════════════════════
  void _onToggle(TogglePDOVerifyEvent e, Emitter<PDOViewState> emit) {
    if (state is! PDOViewLoaded) return;

    // Immutable update — new list with updated item
    final updated = _s.details.map((d) {
      if (d.Id == e.detailId) {
        return d.copyWith(
          isVerified: e.value,
          Verify:     e.value ? 1 : 0,
        );
      }
      return d;
    }).toList();

    emit(_s.copyWith(details: updated));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SAVE (Verify button)
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> _onSave(
      SavePDOEvent e, Emitter<PDOViewState> emit) async {
    if (state is! PDOViewLoaded) return;

    emit(_s.copyWith(isSaving: true));

    try {
      final comid  = objfun.storagenew.getInt('Comid') ?? 0;
      final master = _s.allMasters.firstWhere((m) => m.Id == e.masterId);

      // Build payload — only checked details for this master
      final checkedDetails = _s.details
          .where((d) => d.RTIMasterRefId == e.masterId && d.isChecked)
          .toList();

      final payload = checkedDetails.map((x) => {
        "Id":                      x.StatusId,
        "CompanyRefId":            comid,
        "RTIMasterRefId":          master.Id,
        "RTIDetailsRefId":         x.Id,
        "RTICNumberDisplay":       master.RTINoDisplay,
        "DriverName":              master.DriverName,
        "JobNumber":               x.JobNo,
        "SaleOrderMasterRefId":    x.SaleOrderMasterRefId,
        "CustomerMasterRefId":     x.CustomerMasterRefId,
        "TruckMasterRefId":        master.TruckMasterRefId,
        "DriverMasterRefId":       objfun.EmpRefId,
        "TruckName":               master.TruckName,
        "Verify":                  x.isVerified ? 1 : 0,
        "ImagePath":               x.imagePath,
      }).toList();

      final uri     = Uri.parse("${objfun.apiRTIDetailsInsert}$comid");
      final request = http.MultipartRequest("POST", uri);

      request.fields["objReceipt"] = jsonEncode(payload);
      request.fields["Comid"]      = comid.toString();

      // Attach image files
      for (final d in checkedDetails) {
        if (d.imageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "Files_${d.Id}",
              d.imageFile!.path,
              filename: d.imageFile!.name,
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        emit(_s.copyWith(
          isSaving:            false,
          saveSuccessMasterId: e.masterId,
        ));
      } else {
        emit(_s.copyWith(
          isSaving:  false,
          saveError: "Failed to save (${response.statusCode})",
        ));
      }
    } catch (err) {
      emit(_s.copyWith(
        isSaving:  false,
        saveError: err.toString(),
      ));
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // RESET SAVE STATUS — after dialog is dismissed
  // ════════════════════════════════════════════════════════════════════════════
  void _onResetStatus(
      ResetPDOSaveStatusEvent e, Emitter<PDOViewState> emit) {
    if (state is! PDOViewLoaded) return;
    emit(_s.copyWith(clearSuccess: true, clearError: true));
  }
}