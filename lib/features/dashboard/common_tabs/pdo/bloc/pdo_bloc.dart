import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/pdo_repository.dart';
import 'pdo_event.dart';
import 'pdo_state.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';

class PDOBloc extends Bloc<PDOViewEvent, PDOViewState> {
  final PDORepository repository; // ✅ Injected Repository

  // ── Params passed from parent page ───────────────────────────────────────
  final String fromDate;
  final String toDate;
  final int driverId;
  final int truckId;
  final int employeeId;
  final String search;

  PDOBloc({
    required this.repository,
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
  Future<void> _onLoad(LoadPDOViewEvent e, Emitter<PDOViewState> emit) async {
    emit(const PDOViewLoading());
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

      // ✅ REFACTORED: Using the injected repository
      final result = await repository.fetchPDORecords(
        comId: comId,
        fromDate: fromDate,
        toDate: toDate,
        driverId: driverId,
        truckId: truckId,
        employeeId: employeeId,
        search: search,
      );

      List<RTIMasterViewModel> masters = [];
      List<RTIDetailsViewModel> details = [];

      if (result != null && result is List && result.isNotEmpty) {
        masters = (result[0]["salemaster"] as List)
            .map((e) => RTIMasterViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        details = (result[0]["saledetails"] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e as Map<String, dynamic>))
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
  // SEARCH
  // ════════════════════════════════════════════════════════════════════════════
  void _onSearch(SearchPDOEvent e, Emitter<PDOViewState> emit) {
    if (state is! PDOViewLoaded) return;
    final q = e.query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? List<RTIMasterViewModel>.from(_s.allMasters)
        : _s.allMasters.where((m) {
      return (m.RTINoDisplay.toLowerCase().contains(q)) ||
          (m.DriverName.toLowerCase().contains(q) ?? false) ||
          (m.TruckName.toLowerCase().contains(q) ?? false);
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
  Future<void> _onSave(SavePDOEvent e, Emitter<PDOViewState> emit) async {
    if (state is! PDOViewLoaded) return;

    emit(_s.copyWith(isSaving: true));

    try {
      final comId  = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final master = _s.allMasters.firstWhere((m) => m.Id == e.masterId);

      // Extract checked details for payload
      final checkedDetails = _s.details
          .where((d) => d.RTIMasterRefId == e.masterId && d.isChecked)
          .toList();

      final payload = checkedDetails.map((x) => {
        "Id":                      x.StatusId,
        "CompanyRefId":            comId,
        "RTIMasterRefId":          master.Id,
        "RTIDetailsRefId":         x.Id,
        "RTICNumberDisplay":       master.RTINoDisplay,
        "DriverName":              master.DriverName,
        "JobNumber":               x.JobNo,
        "SaleOrderMasterRefId":    x.SaleOrderMasterRefId,
        "CustomerMasterRefId":     x.CustomerMasterRefId,
        "TruckMasterRefId":        master.TruckMasterRefId,
        "DriverMasterRefId":       AppGlobals.EmpRefId,
        "TruckName":               master.TruckName,
        "Verify":                  x.isVerified ? 1 : 0,
        "ImagePath":               x.imagePath,
      }).toList();

      // ✅ REFACTORED: Using the injected repository
      final isSuccess = await repository.submitPDOVerification(
          comId: comId,
          payload: payload,
          checkedDetails: checkedDetails
      );

      if (isSuccess) {
        emit(_s.copyWith(
          isSaving:            false,
          saveSuccessMasterId: e.masterId,
        ));
      } else {
        emit(_s.copyWith(
          isSaving:  false,
          saveError: "Failed to save data. Please try again.",
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
  // RESET SAVE STATUS
  // ════════════════════════════════════════════════════════════════════════════
  void _onResetStatus(ResetPDOSaveStatusEvent e, Emitter<PDOViewState> emit) {
    if (state is! PDOViewLoaded) return;
    emit(_s.copyWith(clearSuccess: true, clearError: true));
  }
}