import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/transaction/salesorder/view/bloc/salesorderview_event.dart';
import 'package:maleva/features/transaction/salesorder/view/bloc/salesorderview_state.dart';



class SalesOrderViewBloc extends Bloc<SalesOrderViewEvent, SalesOrderViewState> {
  final BuildContext context;

  SalesOrderViewBloc(this.context) : super(SalesOrderViewInitial()) {

    // ────────────────────────────────────────────────────
    // STARTUP
    // ────────────────────────────────────────────────────
    on<StartupSalesOrderView>((event, emit) async {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final isAdmin = objfun.storagenew.getString('RulesType') == "ADMIN";

      emit(SalesOrderViewLoading());
      try {
        await OnlineApi.SelectCustomer(context);
        await OnlineApi.SelectJobStatus(context);
        await OnlineApi.SelectEmployee(context, 'Sales', '');
        await OnlineApi.loadComboS1(context, 0);

        final base = SalesOrderViewLoaded(
          dtpFromDate: today,
          dtpToDate: today,
          checkBoxValueLEmp: !isAdmin,
          progress: true,
        );

        emit(base);
        add(LoadSalesOrderView());
      } catch (e) {
        emit(SalesOrderViewError(e.toString()));
      }
    });

    // ────────────────────────────────────────────────────
    // LOAD DATA
    // ────────────────────────────────────────────────────
    on<LoadSalesOrderView>((event, emit) async {
      if (state is! SalesOrderViewLoaded) return;
      final s = state as SalesOrderViewLoaded;

      emit(s.copyWith(progress: false));

      try {
        final leEmpRefId = s.checkBoxValueLEmp ? objfun.EmpRefId : s.empId;
        final master = {
          'SoId': 0,
          'Comid': objfun.storagenew.getInt('Comid') ?? 0,
          'Fromdate': s.dtpFromDate,
          'Todate': s.dtpToDate,
          'Id': s.custId,
          'DId': 0,
          'TId': 0,
          'Employeeid': leEmpRefId,
          'Statusid': s.statusId,
          'completestatusnotshow': false,
          'Search': s.txtJobNo.isNotEmpty ? s.txtJobNo : null,
          'Offvesselname': s.txtOffVessel.isNotEmpty ? s.txtOffVessel : null,
          'Loadingvesselname': s.txtLoadingVessel.isNotEmpty ? s.txtLoadingVessel : null,
          'Remarks': s.cls,
          'ETA': s.checkBoxValueETA,
          'ETAType': s.etaRadioVal,
          'Pickup': s.checkBoxValuePickUp,
        };

        final header = {'Content-Type': 'application/json; charset=UTF-8'};
        final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectSalesOrder, master, header, context,
        );

        if (resultData != "" && resultData.length != 0) {
          final masterList = (resultData[0]["salemaster"] as List)
              .map((e) => SaleOrderMasterModel.fromJson(e))
              .toList();
          final detailList = (resultData[0]["saledetails"] as List)
              .map((e) => SaleOrderDetailModel.fromJson(e))
              .toList();

          // Update global lists too (for compatibility)
          objfun.SaleOrderMasterList = masterList;
          objfun.SaleOrderDetailList = detailList;

          emit(s.copyWith(
            masterList: masterList,
            detailList: detailList,
            progress: true,
            expandedIndex: -1,
          ));
        } else {
          emit(s.copyWith(masterList: [], detailList: [], progress: true));
        }
      } catch (e) {
        emit(s.copyWith(progress: true));
      }
    });

    // ────────────────────────────────────────────────────
    // ROW EXPAND / COLLAPSE
    // ────────────────────────────────────────────────────
    on<ExpandRow>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      final s = state as SalesOrderViewLoaded;

      final newIndex = s.expandedIndex == event.index ? -1 : event.index;
      final selectedId = newIndex == -1 ? null : s.masterList[newIndex].Id;
      final details = selectedId == null
          ? <SaleOrderDetailModel>[]
          : s.detailList.where((d) => d.SaleRefId == selectedId).toList();

      emit(s.copyWith(expandedIndex: newIndex, selectedDetails: details));
    });

    on<CollapseRow>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(expandedIndex: -1, selectedDetails: []));
    });

    // ────────────────────────────────────────────────────
    // FILTER UPDATES
    // ────────────────────────────────────────────────────
    on<ViewUpdateFromDate>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(dtpFromDate: event.date));
    });

    on<ViewUpdateToDate>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(dtpToDate: event.date));
    });

    on<ViewCustomerSelected>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(
        txtCustomer: event.name,
        custId: event.id,
      ));
    });

    on<ViewCustomerCleared>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(txtCustomer: '', custId: 0));
    });

    on<ViewEmployeeSelected>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(
        txtEmployee: event.name,
        empId: event.id,
      ));
    });

    on<ViewEmployeeCleared>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(txtEmployee: '', empId: 0));
    });

    on<ViewStatusSelected>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(
        txtStatus: event.name,
        statusId: event.id,
      ));
    });

    on<ViewStatusCleared>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(txtStatus: '', statusId: 0));
    });

    on<ViewUpdateTextField>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      final s = state as SalesOrderViewLoaded;
      switch (event.field) {
        case 'txtJobNo': emit(s.copyWith(txtJobNo: event.value)); break;
        case 'txtLoadingVessel': emit(s.copyWith(txtLoadingVessel: event.value)); break;
        case 'txtOffVessel': emit(s.copyWith(txtOffVessel: event.value)); break;
      }
    });

    on<ViewUpdateCheckbox>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      final s = state as SalesOrderViewLoaded;
      switch (event.field) {
        case 'checkBoxValuePickUp': emit(s.copyWith(checkBoxValuePickUp: event.value)); break;
        case 'checkBoxValueLEmp': emit(s.copyWith(checkBoxValueLEmp: event.value)); break;
      }
    });

    on<ViewUpdateRadio>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(
        etaVal: event.etaVal,
        etaRadioVal: event.etaRadioVal,
        checkBoxValueETA: event.checkBoxValueETA,
      ));
    });

    on<ViewUpdateCls>((event, emit) {
      if (state is! SalesOrderViewLoaded) return;
      emit((state as SalesOrderViewLoaded).copyWith(cls: event.cls));
    });

    // ────────────────────────────────────────────────────
    // SHARE DO
    // ────────────────────────────────────────────────────
    on<ShareDO>((event, emit) async {
      if (state is! SalesOrderViewLoaded) return;
      final s = state as SalesOrderViewLoaded;
      emit(s.copyWith(progress: false));

      try {
        final master = {'SoId': event.id, 'Comid': objfun.Comid};
        final header = {'Content-Type': 'application/json; charset=UTF-8'};
        final resultData = await objfun.apiAllinoneSelectArray(
          "${objfun.apiViewDOConvert}${event.billNo}",
          master, header, context,
        );

        if (resultData != "") {
          final value = ResponseViewModel.fromJson(resultData);
          if (value.IsSuccess == true) {
            objfun.launchInBrowser(value.data1);
          }
        }
      } catch (_) {}

      emit(s.copyWith(progress: true));
    });
  }
}