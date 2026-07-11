import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/common_tabs/saleorderview/bloc/saleorderview_event.dart';
import 'package:maleva/features/dashboard/common_tabs/saleorderview/bloc/saleorderview_state.dart';

import '../data/saleorderrepository.dart';

// Import your repository


class SaleOrderBloc extends Bloc<SaleOrderEvent, SaleOrderState> {
  // Define the repository
  final SaleOrderRepository repository;

  // Require the repository in the constructor
  SaleOrderBloc({required this.repository}) : super(SaleOrderState(
    checkBoxValueLEmp:
    AppGlobals.storagenew.getString('RulesType') != 'ADMIN',
  )) {
    on<SaleOrderStartupRequested>(_onStartup);
    on<SaleOrderDataRequested>(_onDataRequested);
    on<SaleOrderRefreshRequested>(_onRefresh);
    on<SaleOrderCardToggled>(_onCardToggled);
    on<SaleOrderItemChecked>(_onItemChecked);
    on<SaleOrderFromDateChanged>(_onFromDateChanged);
    on<SaleOrderToDateChanged>(_onToDateChanged);
    on<SaleOrderCustomerChanged>(_onCustomerChanged);
    on<SaleOrderEmployeeChanged>(_onEmployeeChanged);
    on<SaleOrderStatusChanged>(_onStatusChanged);
    on<SaleOrderLEmpToggled>(_onLEmpToggled);
    on<SaleOrderPickUpToggled>(_onPickUpToggled);
    on<SaleOrderClsChanged>(_onClsChanged);
    on<SaleOrderETARadioChanged>(_onETARadioChanged);
    on<SaleOrderCompleteStatusToggled>(_onCompleteStatusToggled);
    on<SaleOrderETADatesSet>(_onETADatesSet);
    on<SaleOrderUpdateRequested>(_onUpdateRequested);
    on<SaleOrderSearchTextChanged>(_onSearchTextChanged);
  }

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStartup(
      SaleOrderStartupRequested event,
      Emitter<SaleOrderState> emit,
      ) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    try {
      // Load all combo / dropdown data first
      await OnlineApi.SelectCustomer(null);await OnlineApi.SelectJobStatus(null);await OnlineApi.SelectEmployee(null, 'Sales', '');await OnlineApi.loadComboS1(null, 0);// Then load the list
      await _fetchData(emit);
    } catch (e, st) {
      emit(state.copyWith(
        status: SaleOrderStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Load list data ────────────────────────────────────────────────────────

  Future<void> _onDataRequested(
      SaleOrderDataRequested event,
      Emitter<SaleOrderState> emit,
      ) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
      SaleOrderRefreshRequested event,
      Emitter<SaleOrderState> emit,
      ) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<SaleOrderState> emit) async {
    try {
      final int empRefId =
      state.checkBoxValueLEmp ? AppGlobals.EmpRefId : state.empId;

      final Map<String, dynamic> body = {
        'SoId': 0,
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'Fromdate': state.fromDate,
        'Todate': state.toDate,
        'Id': state.custId,
        'DId': 0,
        'TId': 0,
        'Employeeid': empRefId,
        'Statusid': state.statusId,
        'completestatusnotshow': state.completeStatusNotShow,
        'Search': state.jobNo.isNotEmpty ? state.jobNo : null,
        'Offvesselname': state.offVessel.isNotEmpty ? state.offVessel : null,
        'Loadingvesselname':
        state.loadingVessel.isNotEmpty ? state.loadingVessel : null,
        'Remarks': state.cls,
        'Westport': 0,
        'ETA': state.checkBoxValueETA,
        'ETAType': state.etaRadioVal,
        'Pickup': state.checkBoxValuePickUp,
      };

      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await AppGlobals.apiAllinoneSelectArray(
        AppGlobals.apiSelectTVSaleOrder,
        body,
        headers,
        null,
      );

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty) {
        final List<SaleOrderMasterModel> masters = resultData[0]['salemaster']
            .map<SaleOrderMasterModel>(
                (e) => SaleOrderMasterModel.fromJson(e))
            .toList();

        final List<SaleOrderDetailModel> details = resultData[0]['saledetails']
            .map<SaleOrderDetailModel>(
                (e) => SaleOrderDetailModel.fromJson(e))
            .toList();

        // Keep global lists in sync (other pages may read them)
        AppGlobals.SaleOrderMasterList = masters;
        AppGlobals.SaleOrderDetailList = details;

        emit(state.copyWith(
          status: SaleOrderStatus.success,
          masterList: List<SaleOrderMasterModel>.from(masters),
          currentlyVisibleIndex: -1,
        ));
      } else {
        emit(state.copyWith(
          status: SaleOrderStatus.success,
          masterList: const [],
        ));
      }
    } catch (e, st) {
      emit(state.copyWith(
        status: SaleOrderStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Card toggle ───────────────────────────────────────────────────────────

  void _onCardToggled(
      SaleOrderCardToggled event,
      Emitter<SaleOrderState> emit,
      ) {
    final next =
    state.currentlyVisibleIndex == event.index ? -1 : event.index;
    emit(state.copyWith(currentlyVisibleIndex: next));
  }

  // ── Item checkbox ─────────────────────────────────────────────────────────

  void _onItemChecked(
      SaleOrderItemChecked event,
      Emitter<SaleOrderState> emit,
      ) {
    final updated = List<SaleOrderMasterModel>.from(state.masterList);
    updated[event.index].isETASelected = event.value;
    emit(state.copyWith(
      masterList: updated,
      toggleTrigger: state.toggleTrigger + 1,
    ));
  }

  // ── Filter events (pure state updates, no API call) ───────────────────────

  void _onFromDateChanged(SaleOrderFromDateChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(fromDate: e.date));

  void _onToDateChanged(SaleOrderToDateChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(toDate: e.date));

  void _onCustomerChanged(SaleOrderCustomerChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(custId: e.custId, custName: e.custName));

  void _onEmployeeChanged(SaleOrderEmployeeChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(empId: e.empId, empName: e.empName));

  void _onStatusChanged(SaleOrderStatusChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(statusId: e.statusId, statusName: e.statusName));

  void _onLEmpToggled(SaleOrderLEmpToggled e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(checkBoxValueLEmp: e.value));

  void _onPickUpToggled(SaleOrderPickUpToggled e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(checkBoxValuePickUp: e.value));

  void _onClsChanged(SaleOrderClsChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(cls: e.cls));

  void _onETARadioChanged(SaleOrderETARadioChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(
        etaVal: e.etaVal,
        etaRadioVal: e.etaRadioVal,
        checkBoxValueETA: e.etaEnabled,
      ));

  void _onCompleteStatusToggled(
      SaleOrderCompleteStatusToggled e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(completeStatusNotShow: e.value));

  void _onSearchTextChanged(SaleOrderSearchTextChanged e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(
        jobNo:         e.jobNo         ?? state.jobNo,
        loadingVessel: e.loadingVessel ?? state.loadingVessel,
        offVessel:     e.offVessel     ?? state.offVessel,
      ));

  // ── ETA dates set from dialog ─────────────────────────────────────────────

  void _onETADatesSet(SaleOrderETADatesSet e, Emitter<SaleOrderState> emit) =>
      emit(state.copyWith(
        leta: e.leta,
        letb: e.letb,
        oeta: e.oeta,
        oetb: e.oetb,
      ));

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> _onUpdateRequested(
      SaleOrderUpdateRequested event,
      Emitter<SaleOrderState> emit,
      ) async {
    final toSave = state.masterList
        .where((e) => e.isETASelected)
        .toList();

    if (toSave.isEmpty) {
      emit(state.copyWith(
        status: SaleOrderStatus.failure,
        errorMessage: 'Please check at least one row before updating.',
      ));
      // Restore previous success state so UI shows the list again
      emit(state.copyWith(status: SaleOrderStatus.success));
      return;
    }

    emit(state.copyWith(status: SaleOrderStatus.updating));

    try {
      for (final item in toSave) {
        item.SETA  = state.leta  != null ? _fmt(state.leta!)  : item.SETA;
        item.SETB  = state.letb  != null ? _fmt(state.letb!)  : item.SETB;
        item.SOETA = state.oeta  != null ? _fmt(state.oeta!) : item.SOETA;
        item.SOETB = state.oetb  != null ? _fmt(state.oetb!) : item.SOETB;
      }

      // We call the clean repository method instead of apiAllinoneMapSelect
      final result = await repository.updateSaleOrderMaster(toSave);

      if (result != null && result['IsSuccess'] == true) {
        emit(state.copyWith(status: SaleOrderStatus.success));
        // Reload fresh data after update
        add(const SaleOrderDataRequested());
      } else {
        emit(state.copyWith(
          status: SaleOrderStatus.failure,
          errorMessage: result?['Message'] ?? 'Update failed. Please try again.',
        ));
      }
    } catch (e, st) {
      emit(state.copyWith(
        status: SaleOrderStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      _log(e, st);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}:00';

  void _log(Object e, StackTrace st) {
    assert(() {
      debugPrint('SaleOrderBloc error: $e\n$st');
      return true;
    }());
  }
}