import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/subadminsale/bloc/salesreport%20event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/subadminsale/bloc/salesreport%20state.dart';

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
  String get _fromDate {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
  }

  String get _toDate => DateFormat('yyyy-MM-dd').format(DateTime.now());
  int get _comId => objfun.storagenew.getInt('Comid') ?? 0;

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
      _empId = objfun.EmpRefId;
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

      if (resultData != null && resultData is Map && resultData.containsKey("Data1")) {
        emit(SalesReportEmpDetailLoaded(empSalesReport: resultData["Data1"]));
      }
    } catch (e) {
      emit(SalesReportError(errorMessage: e.toString()));
    }
  }

  // ── Private: Load Employee List ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _loadRulesType() async {
    final resultData = await repository.fetchRules(_comId, objfun.EmpRefId);
    if (resultData != null && resultData is List) {
      return resultData.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  // ── Private: Load All 5 API Calls (Optimized Parallel Execution) ─────────────
  Future<Map<String, dynamic>> _loadAllSalesData() async {
    // ✅ Executing all 5 API calls at the same time makes loading significantly faster!
    final responses = await Future.wait([
      repository.fetchInvoiceCount({
        'Comid': _comId, 'Fromdate': "2024-10-01", 'Todate': _toDate, "Statusid": 0,
        "Employeeid": _empId, "Remarks": 2, "Search": "0", "completestatusnotshow": false, "Invoice": false,
      }),
      repository.fetchInvoiceCount({
        'Comid': _comId, 'Fromdate': _fromDate, 'Todate': _toDate, "Statusid": 0,
        "Employeeid": _empId, "Remarks": 0, "Search": "0", "completestatusnotshow": false, "Invoice": false,
      }),
      repository.fetchInvoiceCount({
        'Comid': _comId, 'Fromdate': _fromDate, 'Todate': _toDate, "Statusid": 0,
        "Employeeid": _empId, "Remarks": 1, "Search": "0", "completestatusnotshow": false, "Invoice": false,
      }),
      repository.fetchInvoiceCount({
        'Comid': _comId, 'Fromdate': _fromDate, 'Todate': _toDate, "Statusid": 0,
        "Employeeid": _empId, "Remarks": 2, "Search": "0", "completestatusnotshow": false, "Invoice": false,
      }),
      repository.fetchOrderStatus(_comId, _empId),
    ]);

    return {
      'withoutInvoiceCount': (responses[0] is List) ? responses[0].length : 0,
      'totalCount':          (responses[1] is List) ? responses[1].length : 0,
      'totalBilledCount':    (responses[2] is List) ? responses[2].length : 0,
      'totalUnBilledCount':  (responses[3] is List) ? responses[3].length : 0,
      'salesReport':         (responses[4] is List) ? responses[4] : [],
    };
  }
}