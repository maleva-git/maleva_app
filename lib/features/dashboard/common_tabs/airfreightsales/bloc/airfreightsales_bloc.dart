import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/airfreight_repository.dart';
import 'airfreightsales_event.dart';
import 'airfreightsales_state.dart';

class AirfreightBloc extends Bloc<CustomerDashboardEvent, AirfreightState> {
  final AirfreightRepository repository; // ✅ Injected Repository

  AirfreightBloc({required this.repository}) : super(const AirfreightState()) {
    on<LoadRulesTypeEvent>(_onLoadRulesType);
    on<EmployeeChangedEvent>(_onEmployeeChanged);
    on<LoadSalesDataEvent>(_onLoadSalesData);

    // ✅ Auto-load data when BLoC is created
    add(LoadRulesTypeEvent());
  }

  Future<void> _onLoadRulesType(
      LoadRulesTypeEvent event,
      Emitter<AirfreightState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    try {
      // ✅ Call repository
      final resultData = await repository.fetchRules(comId, AppGlobals.EmpRefId);

      if (resultData != null && resultData is List) {
        final List<Map<String, dynamic>> employees =
        resultData.map((e) => e as Map<String, dynamic>).toList();

        emit(state.copyWith(
          isLoading: false,
          rulesTypeEmployee: employees,
          dropdownValueEmp: AppGlobals.EmpRefId.toString(),
          empId: AppGlobals.EmpRefId,
        ));

        // Rules load aana udane sales data load pannurom
        add(LoadSalesDataEvent(AppGlobals.EmpRefId));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onEmployeeChanged(
      EmployeeChangedEvent event,
      Emitter<AirfreightState> emit,
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
      Emitter<AirfreightState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    final DateTime now = DateTime.now();
    final String toDate = DateFormat('yyyy-MM-dd').format(now);
    final String fromDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));

    final int comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final int empId = event.empId;

    try {
      // ✅ Execute all 5 heavy API calls in parallel for a massive speed boost!
      final responses = await Future.wait([
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': '2024-10-01', 'Todate': toDate, 'Statusid': 0,
          'Employeeid': empId, 'Remarks': 2, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
          'Employeeid': empId, 'Remarks': 0, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
          'Employeeid': empId, 'Remarks': 1, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
        }),
        repository.fetchInvoiceCount({
          'Comid': comId, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
          'Employeeid': empId, 'Remarks': 2, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
        }),
        repository.fetchOrderStatus(comId, empId),
      ]);

      emit(state.copyWith(
        isLoading: false,
        withoutInvoiceCount: responses[0] is List ? responses[0].length : 0,
        totalCount:          responses[1] is List ? responses[1].length : 0,
        totalBilledCount:    responses[2] is List ? responses[2].length : 0,
        totalUnBilledCount:  responses[3] is List ? responses[3].length : 0,
        salesReport:         responses[4] is List ? responses[4] : [],
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }
}