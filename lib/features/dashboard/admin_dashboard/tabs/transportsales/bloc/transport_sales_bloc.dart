import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'transport_sales_event.dart';
import 'transport_sales_state.dart';

class TransportSalesBloc extends Bloc<TransportSalesEvent, TransportSalesState> {
  TransportSalesBloc() : super(const TransportSalesState()) {
    on<InitTransportSalesEvent>(_onInit);
    on<ChangeEmployeeEvent>(_onChangeEmployee);
    on<LoadSalesDataEvent>(_onLoadSalesData);
  }

  Future<void> _onInit(
      InitTransportSalesEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      "Employeeid": objfun.EmpRefId,
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.LoadRulesType, master, header, event.context);

      if (resultData != "" && resultData != null) {
        List<Map<String, dynamic>> rules = [];
        for (var item in resultData) {
          rules.add(item as Map<String, dynamic>);
        }

        String? defaultEmpId;
        final ids = rules.map((e) => e['Id'].toString()).toList();
        if (ids.contains(objfun.EmpRefId.toString())) {
          defaultEmpId = objfun.EmpRefId.toString();
        }

        emit(state.copyWith(
          rulesTypeEmployee: rules,
          selectedEmpId: defaultEmpId,
        ));

        // Load data initially right after setting up the employee
        add(LoadSalesDataEvent(event.context));
      }
    } catch (e) {
      emit(state.copyWith(
          status: TransportSalesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onChangeEmployee(
      ChangeEmployeeEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(
        selectedEmpId: event.empId, status: TransportSalesStatus.loading));
    add(LoadSalesDataEvent(event.context));
  }

  Future<void> _onLoadSalesData(
      LoadSalesDataEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    String fromDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String toDate = DateFormat('yyyy-MM-dd').format(now);

    int empId = int.tryParse(state.selectedEmpId ?? "0") ?? objfun.EmpRefId;
    int comId = objfun.storagenew.getInt('Comid') ?? 0;

    try {
      // 1. Without Invoice Count
      var withoutInvoiceResult = await objfun.apiAllinoneSelectArray(
          objfun.SaleInvoiceCountDB,
          {
            'Comid': comId,
            'Fromdate': "2024-10-01",
            'Todate': toDate,
            "Statusid": 0,
            "Employeeid": empId,
            "Remarks": 2,
            "Search": "0",
            "completestatusnotshow": false,
            "Invoice": false,
          },
          header,
          event.context);

      // 2. Total Count
      var totalResult = await objfun.apiAllinoneSelectArray(
          objfun.SaleInvoiceCountDB,
          {
            'Comid': comId,
            'Fromdate': fromDate,
            'Todate': toDate,
            "Statusid": 0,
            "Employeeid": empId,
            "Remarks": 0,
            "Search": "0",
            "completestatusnotshow": false,
            "Invoice": false,
          },
          header,
          event.context);

      // 3. Billed Count
      var billedResult = await objfun.apiAllinoneSelectArray(
          objfun.SaleInvoiceCountDB,
          {
            'Comid': comId,
            'Fromdate': fromDate,
            'Todate': toDate,
            "Statusid": 0,
            "Employeeid": empId,
            "Remarks": 1,
            "Search": "0",
            "completestatusnotshow": false,
            "Invoice": false,
          },
          header,
          event.context);

      // 4. UnBilled Count
      var unbilledResult = await objfun.apiAllinoneSelectArray(
          objfun.SaleInvoiceCountDB,
          {
            'Comid': comId,
            'Fromdate': fromDate,
            'Todate': toDate,
            "Statusid": 0,
            "Employeeid": empId,
            "Remarks": 2,
            "Search": "0",
            "completestatusnotshow": false,
            "Invoice": false,
          },
          header,
          event.context);

      // 5. Sales Report Data
      var salesReportResult = await objfun.apiAllinoneSelectArray(
          objfun.SelectSalesOrderStatus,
          {
            'Comid': comId,
            "Employeeid": empId,
          },
          header,
          event.context);

      emit(state.copyWith(
        status: TransportSalesStatus.success,
        withoutInvoiceCount:
        (withoutInvoiceResult is List) ? withoutInvoiceResult.length : 0,
        totalCount: (totalResult is List) ? totalResult.length : 0,
        totalBilledCount: (billedResult is List) ? billedResult.length : 0,
        totalUnBilledCount:
        (unbilledResult is List) ? unbilledResult.length : 0,
        salesReport: salesReportResult is List ? salesReportResult : [],
      ));
    } catch (e) {
      emit(state.copyWith(
          status: TransportSalesStatus.failure, errorMessage: e.toString()));
    }
  }
}