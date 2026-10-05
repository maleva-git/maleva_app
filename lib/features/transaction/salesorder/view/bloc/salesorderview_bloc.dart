import 'package:maleva/core/utils/system_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/transaction/salesorder/view/data/salesorderview_repository.dart';
import 'package:maleva/features/transaction/salesorder/view/bloc/salesorderview_event.dart';
import 'package:maleva/features/transaction/salesorder/view/bloc/salesorderview_state.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/features/transaction/salesorder/models/sale_order_detail_model.dart';
import 'package:maleva/features/transaction/salesorder/models/sale_order_master_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';



class SalesOrderViewBloc extends Bloc<SalesOrderViewEvent, SalesOrderViewState> {
  final BuildContext context;
  final SalesOrderViewRepository _repository;
  final SaleOrderApi _saleOrders;

  SalesOrderViewBloc(this.context, this._repository, {SaleOrderApi? saleOrders})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        super(SalesOrderViewInitial()) {

    // ────────────────────────────────────────────────────
    // STARTUP
    // ────────────────────────────────────────────────────
    on<StartupSalesOrderView>((event, emit) async {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final isAdmin = AppGlobals.storagenew.getString('RulesType') == "ADMIN";

      emit(SalesOrderViewLoading());
      try {
        AppGlobals.CustomerList = (await _repository.selectCustomer()).map<CustomerModel>((e) => CustomerModel.fromJson(e)).toList();
        AppGlobals.JobStatusList = (await _repository.selectJobStatus()).map<JobStatusModel>((e) => JobStatusModel.fromJson(e)).toList();
        AppGlobals.EmployeeList = await _repository.selectEmployee('Sales', '');
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
        final leEmpRefId = s.checkBoxValueLEmp ? AppGlobals.EmpRefId : s.empId;
        final result = await _saleOrders.search({
          'Id': s.custId,
          'Employeeid': leEmpRefId,
          'Statusid': s.statusId,
          'completestatusnotshow': false,
          'Search': s.txtJobNo.isNotEmpty ? s.txtJobNo : null,
          'Offvesselname': s.txtOffVessel.isNotEmpty ? s.txtOffVessel : null,
          'Loadingvesselname': s.txtLoadingVessel.isNotEmpty ? s.txtLoadingVessel : null,
          'Remarks': int.tryParse(s.cls),
          'ETA': s.checkBoxValueETA,
          'ETAType': int.tryParse(s.etaRadioVal),
          'Pickup': s.checkBoxValuePickUp,
        }, from: DateTime.parse(s.dtpFromDate), to: DateTime.parse(s.dtpToDate));

        emit(s.copyWith(
          masterList: result.masters.map(SaleOrderMasterModel.fromJson).toList(),
          detailList: result.details.map(SaleOrderDetailModel.fromJson).toList(),
          progress: true,
          expandedIndex: -1,
        ));
      } catch (e) {
        emit(s.copyWith(progress: true));
        _show(e.toString());
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
    // DO / INVOICE REPORTS (the Java print links, opened in the browser)
    // ────────────────────────────────────────────────────
    on<ShareDO>((event, emit) => _openReport(emit, () => _saleOrders.doPrintPath(event.id)));
    on<ViewInvoice>((event, emit) => _openReport(emit, () => _saleOrders.invoicePrintPath(event.id)));
  }

  Future<void> _openReport(Emitter<SalesOrderViewState> emit, Future<String> Function() path) async {
    if (state is! SalesOrderViewLoaded) return;
    final s = state as SalesOrderViewLoaded;
    emit(s.copyWith(progress: false));
    try {
      SystemHelpers.launchInBrowser(SaleOrderApi.reportUrl(await path()));
    } catch (e) {
      _show(e.toString());
    }
    emit(s.copyWith(progress: true));
  }

  void _show(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
