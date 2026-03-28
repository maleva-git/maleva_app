import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/utils/clsfunction.dart' as objfun;
import 'airfreightsales_event.dart';
import 'airfreightsales_state.dart';


class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  CustomerDashboardBloc() : super(const CustomerDashboardState()) {
    on<LoadRulesTypeEvent>(_onLoadRulesType);
    on<EmployeeChangedEvent>(_onEmployeeChanged);
    on<LoadSalesDataEvent>(_onLoadSalesData);
  }

  Future<void> _onLoadRulesType(
      LoadRulesTypeEvent event,
      Emitter<CustomerDashboardState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final Map<String, dynamic> master = {
      'Comid': objfun.storagenew.getInt('Comid') ?? 0,
      'Employeeid': objfun.EmpRefId,
    };

    try {
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.LoadRulesType,
        master,
        header,
        null, // context BLoC la pass pannakoodadu
      );

      if (resultData != '') {
        final List<Map<String, dynamic>> employees =
        List<Map<String, dynamic>>.from(resultData);

        emit(state.copyWith(
          isLoading: false,
          rulesTypeEmployee: employees,
          dropdownValueEmp: objfun.EmpRefId.toString(),
          empId: objfun.EmpRefId,
        ));

        // Rules load aana udane sales data load pannurom
        add(LoadSalesDataEvent(objfun.EmpRefId));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false));
      // Error handling — UI la BlocListener through show pannalam
    }
  }

  void _onEmployeeChanged(
      EmployeeChangedEvent event,
      Emitter<CustomerDashboardState> emit,
      ) {
    final int newEmpId = int.parse(event.selectedEmpId);
    emit(state.copyWith(
      dropdownValueEmp: event.selectedEmpId,
      empId: newEmpId,
    ));
    add(LoadSalesDataEvent(newEmpId));
  }

  Future<void> _onLoadSalesData(
      LoadSalesDataEvent event,
      Emitter<CustomerDashboardState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final DateTime now = DateTime.now();
    final String toDate = DateFormat('yyyy-MM-dd').format(now);
    final String fromDate = DateFormat('yyyy-MM-dd')
        .format(DateTime(now.year, now.month, 1));
    final int comId = objfun.storagenew.getInt('Comid') ?? 0;
    final int empId = event.empId;

    try {
      // 1. Without Invoice Count
      final withoutInvoiceResult = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comId,
          'Fromdate': '2024-10-01',
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // 2. Total Count
      final totalCountResult = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comId,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empId,
          'Remarks': 0,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // 3. Billed Count
      final billedResult = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comId,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empId,
          'Remarks': 1,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // 4. UnBilled Count
      final unbilledResult = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comId,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // 5. Sales Report (Status wise list)
      final salesReportResult = await objfun.apiAllinoneSelectArray(
        objfun.SelectSalesOrderStatus,
        {
          'Comid': comId,
          'Employeeid': empId,
        },
        header,
        null,
      );

      emit(state.copyWith(
        isLoading: false,
        withoutInvoiceCount:
        withoutInvoiceResult != '' ? withoutInvoiceResult.length : 0,
        totalCount: totalCountResult != '' ? totalCountResult.length : 0,
        totalBilledCount: billedResult != '' ? billedResult.length : 0,
        totalUnBilledCount: unbilledResult != '' ? unbilledResult.length : 0,
        salesReport: salesReportResult != '' ? salesReportResult : [],
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}