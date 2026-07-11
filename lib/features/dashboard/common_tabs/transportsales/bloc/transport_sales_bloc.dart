import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/transport_sales_repository.dart';
import 'transport_sales_event.dart';
import 'transport_sales_state.dart';

class TransportSalesBloc extends Bloc<TransportSalesEvent, TransportSalesState> {
  final TransportSalesRepository repository; // ✅ Injected Repository

  TransportSalesBloc({required this.repository}) : super(const TransportSalesState()) {
    on<InitTransportSalesEvent>(_onInit);
    on<ChangeEmployeeEvent>(_onChangeEmployee);
    on<LoadSalesDataEvent>(_onLoadSalesData);

    // Auto-trigger initialization when created
    add(const InitTransportSalesEvent());
  }

  Future<void> _onInit(
      InitTransportSalesEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final empId = AppGlobals.EmpRefId;

    try {
      // ✅ Call Repository
      final resultData = await repository.fetchRules(comId, empId);

      if (resultData != null && resultData is List) {
        List<Map<String, dynamic>> rules = resultData.map((e) => e as Map<String, dynamic>).toList();

        String? defaultEmpId;
        final ids = rules.map((e) => e['Id'].toString()).toList();
        if (ids.contains(empId.toString())) {
          defaultEmpId = empId.toString();
        }

        emit(state.copyWith(
          rulesTypeEmployee: rules,
          selectedEmpId: defaultEmpId,
        ));

        // Load data initially right after setting up the employee
        add(const LoadSalesDataEvent());
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
    add(const LoadSalesDataEvent());
  }

  Future<void> _onLoadSalesData(
      LoadSalesDataEvent event, Emitter<TransportSalesState> emit) async {
    emit(state.copyWith(status: TransportSalesStatus.loading));

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    String fromDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String toDate = DateFormat('yyyy-MM-dd').format(now);

    int empId = int.tryParse(state.selectedEmpId ?? "0") ?? AppGlobals.EmpRefId;
    int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
      // ✅ Parallel API Calls using the Repository
      final responses = await Future.wait([
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': "2024-10-01", 'Todate': toDate, "Statusid": 0,
          "Employeeid": empId, "Remarks": 2, "Search": "0", "completestatusnotshow": false, "Invoice": false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, "Statusid": 0,
          "Employeeid": empId, "Remarks": 0, "Search": "0", "completestatusnotshow": false, "Invoice": false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, "Statusid": 0,
          "Employeeid": empId, "Remarks": 1, "Search": "0", "completestatusnotshow": false, "Invoice": false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, "Statusid": 0,
          "Employeeid": empId, "Remarks": 2, "Search": "0", "completestatusnotshow": false, "Invoice": false,
        }),
        repository.fetchOrderStatus(comId, empId),
      ]);

      final withoutInvoiceResult = responses[0];
      final totalResult = responses[1];
      final billedResult = responses[2];
      final unbilledResult = responses[3];
      final salesReportResult = responses[4];

      emit(state.copyWith(
        status: TransportSalesStatus.success,
        withoutInvoiceCount: (withoutInvoiceResult is List) ? withoutInvoiceResult.length : 0,
        totalCount: (totalResult is List) ? totalResult.length : 0,
        totalBilledCount: (billedResult is List) ? billedResult.length : 0,
        totalUnBilledCount: (unbilledResult is List) ? unbilledResult.length : 0,
        salesReport: salesReportResult is List ? salesReportResult : [],
      ));
    } catch (e) {
      emit(state.copyWith(
          status: TransportSalesStatus.failure, errorMessage: e.toString()));
    }
  }
}