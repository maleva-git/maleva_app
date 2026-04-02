import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'forwardingsalary_event.dart';
import 'forwardingsalary_state.dart';


class ForwardingSalaryBloc
    extends Bloc<ForwardingSalaryEvent, ForwardingSalaryState> {
  ForwardingSalaryBloc() : super(ForwardingSalaryInitial()) {
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
  Future<void> _onStarted(
      ForwardingSalaryStarted event,
      Emitter<ForwardingSalaryState> emit) async {
    emit(ForwardingSalaryLoading());
    try {
      await OnlineApi.GetRTINoForwarding(null, 0);
      await OnlineApi.SelectEmployee(null, '', 'Operation');
      await OnlineApi.loadComboS1(null, 0);
      emit(ForwardingSalaryLoaded.empty());
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  // ── BillType ─────────────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      ForwardingSalaryBillTypeChanged event,
      Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;
    try {
      await OnlineApi.GetRTINoForwarding(null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(
      billType:       event.billType,
      rtiText:        '',
      saleOrderId:    0,
      rtiSuggestions: [],
    ));
  }

  // ── RTI text typed ───────────────────────────────────────────────────────────
  void _onRtiTextChanged(
      ForwardingSalaryRtiTextChanged event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;
    final q = event.text.trim();

    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      filtered = objfun.JobNoList
          .where((e) => e['CNumber'].toString().contains(q))
          .toList();
    }
    emit(s.copyWith(
      rtiText:        q,
      rtiSuggestions: filtered,
      saleOrderId:    0,
    ));
  }

  // ── RTI suggestion selected ──────────────────────────────────────────────────
  Future<void> _onRtiSelected(
      ForwardingSalaryRtiSelected event,
      Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;

    emit(ForwardingSalaryLoading());
    try {
      final comId = objfun.storagenew.getInt('comid') ?? 6;
      final body = {
        'Comid':           comId,
        'RTIMasterRefId':  event.saleOrderId,
      };
      final header = {'Content-Type': 'application/json;charset=UTF-8'};

      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiSelectForwarding, body, header, null);

      int sealEmpId    = 0;
      String sealName  = '';
      int breakEmpId   = 0;
      String breakName = '';
      String salary1   = '';
      String salary2   = '';
      int editId       = 0;

      if (result != null &&
          result is Map<String, dynamic> &&
          result['IsSuccess'] == true) {
        final data = result['Data1'][0];

        editId  = data['Id'] ?? 0;
        salary1 = data['Salary1']?.toString() ?? '';
        salary2 = data['Salary2']?.toString() ?? '';

        sealEmpId = data['EmployeeMasterRefId'] ?? 0;
        if (sealEmpId != 0) {
          final emp = objfun.EmployeeList.firstWhere(
                (e) => e.Id == sealEmpId,
            orElse: () => EmployeeModel.Empty(),
          );
          sealName = emp.AccountName;
        }

        breakEmpId = data['EmployeeMasterRefId1'] ?? 0;
        if (breakEmpId != 0) {
          final emp = objfun.EmployeeList.firstWhere(
                (e) => e.Id == breakEmpId,
            orElse: () => EmployeeModel.Empty(),
          );
          breakName = emp.AccountName;
        }
      }

      emit(s.copyWith(
        rtiText:        event.rtiNo,
        saleOrderId:    event.saleOrderId,
        editId:         editId,
        rtiSuggestions: [],
        sealEmpId:      sealEmpId,
        sealEmpName:    sealName,
        breakEmpId:     breakEmpId,
        breakEmpName:   breakName,
        salary1:        salary1,
        salary2:        salary2,
      ));
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  // ── Overlay dismissed ────────────────────────────────────────────────────────
  void _onOverlayDismissed(
      ForwardingSalaryOverlayDismissed event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded)
          .copyWith(rtiSuggestions: []));
    }
  }

  // ── Seal Employee ────────────────────────────────────────────────────────────
  void _onSealEmpChanged(
      ForwardingSalarySealEmpChanged event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded).copyWith(
          sealEmpId: event.empId, sealEmpName: event.empName));
    }
  }

  void _onSealEmpCleared(
      ForwardingSalarySealEmpCleared event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded)
          .copyWith(sealEmpId: 0, sealEmpName: ''));
    }
  }

  // ── Break Employee ────────────────────────────────────────────────────────────
  void _onBreakEmpChanged(
      ForwardingSalaryBreakEmpChanged event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded).copyWith(
          breakEmpId: event.empId, breakEmpName: event.empName));
    }
  }

  void _onBreakEmpCleared(
      ForwardingSalaryBreakEmpCleared event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded)
          .copyWith(breakEmpId: 0, breakEmpName: ''));
    }
  }

  // ── Salary fields ─────────────────────────────────────────────────────────────
  void _onSalary1Changed(
      ForwardingSalarySalary1Changed event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded).copyWith(salary1: event.value));
    }
  }

  void _onSalary2Changed(
      ForwardingSalarySalary2Changed event,
      Emitter<ForwardingSalaryState> emit) {
    if (state is ForwardingSalaryLoaded) {
      emit((state as ForwardingSalaryLoaded).copyWith(salary2: event.value));
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      ForwardingSalarySaveRequested event,
      Emitter<ForwardingSalaryState> emit) async {
    if (state is! ForwardingSalaryLoaded) return;
    final s = state as ForwardingSalaryLoaded;

    emit(ForwardingSalaryLoading());
    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;
      final master = {
        'Id':                   s.editId,
        'CompanyRefId':         comId,
        'EmployeeMasterRefId':  s.sealEmpId,
        'EmployeeMasterRefId1': s.breakEmpId,
        'RTIMasterRefId':       s.saleOrderId,
        'Salary1':              double.tryParse(s.salary1) ?? 0.0,
        'Salary2':              double.tryParse(s.salary2) ?? 0.0,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiInsertForwarding, [master], header, null);

      if (result != null &&
          result is Map<String, dynamic> &&
          (result['Result'] == 1 || result['IsSuccess'] == true)) {
        emit(ForwardingSalarySaveSuccess());
        emit(ForwardingSalaryLoaded.empty());
      } else {
        emit(s); // revert — error shown by UI listener
      }
    } catch (e) {
      emit(ForwardingSalaryError(e.toString()));
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────
  void _onResetRequested(
      ForwardingSalaryResetRequested event,
      Emitter<ForwardingSalaryState> emit) {
    emit(ForwardingSalaryLoaded.empty());
  }
}