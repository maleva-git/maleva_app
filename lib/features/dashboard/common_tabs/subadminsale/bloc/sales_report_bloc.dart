import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/common_tabs/subadminsale/bloc/sales_report_event.dart';
import 'package:maleva/features/dashboard/common_tabs/subadminsale/bloc/sales_report_state.dart';

import '../data/salesreport_repository.dart';


class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  final SalesReportRepository repository; // ✅ Injected Repository
  int _empId = 0;

  SalesReportBloc({required this.repository}) : super(const SalesReportInitial()) {
    on<LoadSalesReportEvent>(_onLoad);
    on<ChangeEmployeeEvent>(_onChangeEmployee);
    on<LoadEmpInvDataEvent>(_onLoadEmpInvData);

    // ✅ Auto-trigger the initial load
    add(const LoadSalesReportEvent());
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  int get _comId => AppGlobals.storagenew.getInt('Comid') ?? 0;

  // ── Load Initial Data ───────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadSalesReportEvent event,
      Emitter<SalesReportState> emit,
      ) async {
    emit(const SalesReportLoading());

    try {
      // 1️⃣ Load employee dropdown
      final empList = await _loadRulesType();

      // 2️⃣ Set default dropdown value
      _empId = AppGlobals.EmpRefId;
      String? dropdownValue;
      final ids = empList.map((e) => e['Id'].toString()).toList();
      if (ids.contains(_empId.toString())) {
        dropdownValue = _empId.toString();
      }

      // 3️⃣ Load all sales counts + report
      final results = await _loadAllSalesData();

      emit(SalesReportLoaded(
        rulesTypeEmployee: empList,
        dropdownValueEmp: dropdownValue,
        withoutInvoiceCount: results['withoutInvoiceCount'],
        totalCount: results['totalCount'],
        totalBilledCount: results['totalBilledCount'],
        totalUnBilledCount: results['totalUnBilledCount'],
        salesReport: results['salesReport'],
      ));
    } catch (e) {
      emit(SalesReportError(errorMessage: e.toString()));
    }
  }

  // ── Dropdown Change ─────────────────────────────────────────────────────────
  Future<void> _onChangeEmployee(
      ChangeEmployeeEvent event,
      Emitter<SalesReportState> emit,
      ) async {
    final currentState = state;
    if (currentState is! SalesReportLoaded) return;

    _empId = int.tryParse(event.employeeId ?? "0") ?? 0;
    emit(const SalesReportLoading());

    try {
      final results = await _loadAllSalesData();

      emit(currentState.copyWith(
        dropdownValueEmp: event.employeeId,
        withoutInvoiceCount: results['withoutInvoiceCount'],
        totalCount: results['totalCount'],
        totalBilledCount: results['totalBilledCount'],
        totalUnBilledCount: results['totalUnBilledCount'],
        salesReport: results['salesReport'],
      ));
    } catch (e) {
      emit(SalesReportError(errorMessage: e.toString()));
    }
  }

  // ── Load Employee Invoice Data (Dialog) ─────────────────────────────────────
  Future<void> _onLoadEmpInvData(
      LoadEmpInvDataEvent event,
      Emitter<SalesReportState> emit,
      ) async {
    try {
      final resultData = await repository.fetchEmployeeInvData(_comId, event.type);

      emit(SalesReportEmpDetailLoaded(empSalesReport: resultData));
    } catch (e) {
      emit(SalesReportError(errorMessage: e.toString()));
    }
  }

  // ── Private: Load Employee List ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _loadRulesType() async {
    return repository.fetchRules(_comId, AppGlobals.EmpRefId);
  }

  // ── Private: Load All 5 API Calls (Optimized Parallel Execution) ─────────────
  Future<Map<String, dynamic>> _loadAllSalesData() async {
    final desk = await repository.fetchSalesDesk(_comId, _empId);
    return {
      'withoutInvoiceCount': desk.withoutInvoice,
      'totalCount':          desk.total,
      'totalBilledCount':    desk.billed,
      'totalUnBilledCount':  desk.unbilled,
      'salesReport':         desk.statuses,
    };
  }
}