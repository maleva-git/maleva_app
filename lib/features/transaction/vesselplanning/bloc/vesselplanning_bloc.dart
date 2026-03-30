import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/transaction/vesselplanning/bloc/vesselplanning_event.dart';
import 'package:maleva/features/transaction/vesselplanning/bloc/vesselplanning_state.dart';


class VesselPlanningBloc extends Bloc<VesselPlanningEvent, VesselPlanningState> {
  VesselPlanningBloc() : super(VesselPlanningInitial()) {
    on<VesselPlanningStarted>(_onStarted);
    on<VesselPlanningFilterChanged>(_onFilterChanged);
    on<VesselPlanningRowToggled>(_onRowToggled);
    on<VesselPlanningShareRequested>(_onShareRequested);
    on<VesselPlanningEditRequested>(_onEditRequested);
    on<VesselPlanningEmployeeSelected>(_onEmployeeSelected);
    on<VesselPlanningEmployeeCleared>(_onEmployeeCleared);
  }

  final String _today = DateFormat("yyyy-MM-dd").format(DateTime.now());

  // ─── Started ────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      VesselPlanningStarted event,
      Emitter<VesselPlanningState> emit,
      ) async {
    emit(VesselPlanningLoading());
    try {
      // SelectEmployee needs a context – keep using objfun pattern
      // We call it here and store result in objfun.EmployeeList (existing pattern)
      await _loadData(
        fromDate: _today,
        toDate: _today,
        planningNo: '',
        empId: objfun.EmpRefId,
        isLoggedInEmp: true,
        emit: emit,
        existingState: null,
      );
    } catch (e) {
      emit(VesselPlanningError(e.toString()));
    }
  }

  // ─── Filter Changed ──────────────────────────────────────────────────────────
  Future<void> _onFilterChanged(
      VesselPlanningFilterChanged event,
      Emitter<VesselPlanningState> emit,
      ) async {
    final current = state is VesselPlanningLoaded ? state as VesselPlanningLoaded : null;
    emit(VesselPlanningLoading());
    await _loadData(
      fromDate: event.fromDate,
      toDate: event.toDate,
      planningNo: event.planningNo,
      empId: event.isLoggedInEmp ? objfun.EmpRefId : event.empId,
      isLoggedInEmp: event.isLoggedInEmp,
      emit: emit,
      existingState: current,
    );
  }

  // ─── Row Toggled ─────────────────────────────────────────────────────────────
  void _onRowToggled(
      VesselPlanningRowToggled event,
      Emitter<VesselPlanningState> emit,
      ) {
    if (state is! VesselPlanningLoaded) return;
    final s = state as VesselPlanningLoaded;

    final isAlreadyOpen = s.expandedIndex == event.index;
    final newIndex = isAlreadyOpen ? -1 : event.index;

    final selectedDetails = isAlreadyOpen
        ? []
        : s.detailsList
        .where((item) => item["VESSELPLANINGMasterRefId"] == event.masterRefId)
        .toList();

    emit(s.copyWith(
      expandedIndex: newIndex,
      selectedDetails: selectedDetails,
    ));
  }

  // ─── Share (PDF) ─────────────────────────────────────────────────────────────
  Future<void> _onShareRequested(
      VesselPlanningShareRequested event,
      Emitter<VesselPlanningState> emit,
      ) async {
    if (state is! VesselPlanningLoaded) return;
    final s = state as VesselPlanningLoaded;

    Map<String?, dynamic> master = {
      'SoId': event.id,
      'Comid': objfun.Comid,
    };
    Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8'};

    await objfun
        .apiAllinoneSelectArray(
      "${objfun.apiViewVesselPlanningPdf}${event.planningNoDisplay}",
      master,
      header,
      null,
    )
        .then((resultData) {
      if (resultData != "") {
        ResponseViewModel? value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          objfun.launchInBrowser(value.data1);
        }
      }
    });

    // Re-emit same loaded state (no change needed)
    emit(s.copyWith());
  }

  // ─── Edit Requested (after password verified) ────────────────────────────────
  Future<void> _onEditRequested(
      VesselPlanningEditRequested event,
      Emitter<VesselPlanningState> emit,
      ) async {
    if (state is! VesselPlanningLoaded) return;
    final s = state as VesselPlanningLoaded;

    try {
      await OnlineApi.EditVesselPlanning(null, event.id, event.planningNo);
      emit(VesselPlanningNavigateToEdit());
      // Restore loaded state so UI doesn't break on back navigation
      emit(s.copyWith());
    } catch (e) {
      emit(VesselPlanningError(e.toString()));
      emit(s.copyWith());
    }
  }

  // ─── Employee Selected ───────────────────────────────────────────────────────
  void _onEmployeeSelected(
      VesselPlanningEmployeeSelected event,
      Emitter<VesselPlanningState> emit,
      ) {
    if (state is! VesselPlanningLoaded) return;
    final s = state as VesselPlanningLoaded;
    emit(s.copyWith(empName: event.name, empId: event.empId));
  }

  // ─── Employee Cleared ────────────────────────────────────────────────────────
  void _onEmployeeCleared(
      VesselPlanningEmployeeCleared event,
      Emitter<VesselPlanningState> emit,
      ) {
    if (state is! VesselPlanningLoaded) return;
    final s = state as VesselPlanningLoaded;
    emit(s.copyWith(empName: '', empId: 0));
  }

  // ─── Private: load data ──────────────────────────────────────────────────────
  Future<void> _loadData({
    required String fromDate,
    required String toDate,
    required String planningNo,
    required int empId,
    required bool isLoggedInEmp,
    required Emitter<VesselPlanningState> emit,
    required VesselPlanningLoaded? existingState,
  }) async {
    Map<String, dynamic> master = {
      "Comid": objfun.storagenew.getInt('Comid') ?? 0,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Employeeid": empId,
      "Search": planningNo,
    };
    Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8'};

    await objfun
        .apiAllinoneSelectArray(objfun.apiSelectVesselPlanning, master, header, null)
        .then((resultData) {
      if (resultData != "" && resultData.length != 0) {
        objfun.VesselPlanningMasterList = resultData[0]["salemaster"]
            .map((e) => VesselPlanningMasterModel.fromJson(e))
            .toList();
        objfun.VesselPlanningDetailsList = resultData[0]["saledetails"].toList();
      } else {
        objfun.VesselPlanningMasterList = [];
        objfun.VesselPlanningDetailsList = [];
      }

      emit(VesselPlanningLoaded(
        masterList: List.from(objfun.VesselPlanningMasterList),
        detailsList: List.from(objfun.VesselPlanningDetailsList),
        selectedDetails: [],
        expandedIndex: -1,
        fromDate: fromDate,
        toDate: toDate,
        planningNo: planningNo,
        empId: empId,
        empName: existingState?.empName ?? '',
        isLoggedInEmp: isLoggedInEmp,
      ));
    });
  }
}