import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';

import '../data/forwardingsalary_repository.dart'; // Adjust path
import 'forwardingsalary_event.dart';
import 'forwardingsalary_state.dart';

class ForwardingSalaryBloc extends Bloc<ForwardingSalaryEvent, ForwardingSalaryState> {
  final ForwardingSalaryRepository repository;

  // Local caching to replace direct objfun global accesses
  List<dynamic> _jobNoList = [];
  List<EmployeeModel> _employeeList = [];

  ForwardingSalaryBloc({required this.repository}) : super(ForwardingSalaryInitial()) {
    on<ForwardingSalaryStarted>(_onStarted);
    on<ForwardingSalaryBillTypeChanged>(_onBillTypeChanged);
    on<ForwardingSalaryRtiTextChanged>(_onRtiTextChanged);
    on<ForwardingSalaryRtiSelected>(_onRtiSelected);
    on<ForwardingSalaryOverlayDismissed>(_onOverlayDismissed);
    on<ForwardingSalarySealEmpChanged>(_onSealEmpChanged);
    on<ForwardingSalarySealEmpCleared>(_onSealEmpCleared);
    on<ForwardingSalaryBreakEmpChanged>(_onBreakEmpChanged);
    on<ForwardingSalaryBreakEmpCleared>(_onBreakEmpCleared);
    on<ForwardingSalarySalary1Changed>(_onSalary1Changed);
    on<ForwardingSalarySalary2Changed>(_onSalary2Changed);
    on<ForwardingSalarySaveRequested>(_onSaveRequested);
    on<ForwardingSalaryResetRequested>(_onResetRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(ForwardingSalaryStarted event, Emitter<ForwardingSalaryState> emit) async {
    emit(ForwardingSalaryLoading());
    try {
      final data = await repository.initializeData();
      _jobNoList = data['jobNoList'] ?? [];
      _employeeList = data['employeeList'] ?? [];

      emit(ForwardingSalaryLoaded.empty());
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(ForwardingSalaryBillTypeChanged event, Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;
    try {
      _jobNoList = await repository.fetchRTINoForwarding(int.parse(event.billType));
    } catch (_) {}

    emit(s.copyWith(
      billType: event.billType,
      rtiText: '',
      saleOrderId: 0,
      rtiSuggestions: [],
    ));
  }

  // ── RTI text typed ───────────────────────────────────────────────────────────
  void _onRtiTextChanged(ForwardingSalaryRtiTextChanged event, Emitter<ForwardingSalaryState> emit) {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;
    final q = event.text.trim();

    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      // Filter from local cache instead of global objfun
      filtered = _jobNoList.where((e) => e['CNumber'].toString().contains(q)).toList();
    }
    emit(s.copyWith(
      rtiText: q,
      rtiSuggestions: filtered,
      saleOrderId: 0,
    ));
  }

  // ── RTI suggestion selected ──────────────────────────────────────────────────
  Future<void> _onRtiSelected(ForwardingSalaryRtiSelected event, Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;

    emit(ForwardingSalaryLoading());
    try {
      final data = await repository.fetchForwardingData(event.saleOrderId);

      int sealEmpId = 0;
      String sealName = '';
      int breakEmpId = 0;
      String breakName = '';
      String salary1 = '';
      String salary2 = '';
      int editId = 0;

      if (data != null) {
        editId   = data['Id'] ?? 0;
        salary1  = data['Salary1']?.toString() ?? '';
        salary2  = data['Salary2']?.toString() ?? '';

        sealEmpId  = data['EmployeeMasterRefId'] ?? 0;
        breakEmpId = data['EmployeeMasterRefId1'] ?? 0;

        // ✅ API-ல null வருது — so local list-ல தேடு
        if (sealEmpId != 0) {
          final emp = _employeeList.firstWhere(
                (e) => e.Id == sealEmpId,
            orElse: () => EmployeeModel.Empty(),
          );
          sealName = emp.AccountName;
          print('✅ SealEmp found: $sealName for id $sealEmpId');
        }

        if (breakEmpId != 0) {
          final emp = _employeeList.firstWhere(
                (e) => e.Id == breakEmpId,
            orElse: () => EmployeeModel.Empty(),
          );
          breakName = emp.AccountName;
          print('✅ BreakEmp found: $breakName for id $breakEmpId');
        }
      }

      // 🔍 Debug — இந்த print output என்ன வருதுன்னு சொல்லுங்க
      print('📋 _employeeList length: ${_employeeList.length}');
      print('🔍 sealEmpId: $sealEmpId | breakEmpId: $breakEmpId');

      emit(s.copyWith(
        rtiText:      event.rtiNo,
        saleOrderId:  event.saleOrderId,
        editId:       editId,
        rtiSuggestions: [],
        sealEmpId:    sealEmpId,
        sealEmpName:  sealName,
        breakEmpId:   breakEmpId,
        breakEmpName: breakName,
        salary1:      salary1,
        salary2:      salary2,
      ));
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  // ── Modifiers ────────────────────────────────────────────────────────────────
  void _onOverlayDismissed(ForwardingSalaryOverlayDismissed event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(rtiSuggestions: []));
  }

  void _onSealEmpChanged(ForwardingSalarySealEmpChanged event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(sealEmpId: event.empId, sealEmpName: event.empName));
  }
  void _onSealEmpCleared(ForwardingSalarySealEmpCleared event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(sealEmpId: 0, sealEmpName: ''));
  }

  void _onBreakEmpChanged(ForwardingSalaryBreakEmpChanged event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(breakEmpId: event.empId, breakEmpName: event.empName));
  }
  void _onBreakEmpCleared(ForwardingSalaryBreakEmpCleared event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(breakEmpId: 0, breakEmpName: ''));
  }

  void _onSalary1Changed(ForwardingSalarySalary1Changed event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(salary1: event.value));
  }
  void _onSalary2Changed(ForwardingSalarySalary2Changed event, Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) emit((state as ForwardingSalaryLoaded).copyWith(salary2: event.value));
  }

  // ── Save / Reset ─────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(ForwardingSalarySaveRequested event, Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;

    emit(ForwardingSalaryLoading());
    try {
      final master = {
        'Id': s.editId,
        'CompanyRefId': repository.comid,
        'EmployeeMasterRefId': s.sealEmpId,
        'EmployeeMasterRefId1': s.breakEmpId,
        'RTIMasterRefId': s.saleOrderId,
        'Salary1': double.tryParse(s.salary1) ?? 0.0,
        'Salary2': double.tryParse(s.salary2) ?? 0.0,
      };

      final success = await repository.saveForwardingSalary(master);

      if (success) {
        emit(ForwardingSalarySaveSuccess());
        emit(ForwardingSalaryLoaded.empty());
      } else {
        emit(s); // revert — error shown by UI listener
      }
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  void _onResetRequested(ForwardingSalaryResetRequested event, Emitter<ForwardingSalaryState> emit) {
    emit(ForwardingSalaryLoaded.empty());
  }
}