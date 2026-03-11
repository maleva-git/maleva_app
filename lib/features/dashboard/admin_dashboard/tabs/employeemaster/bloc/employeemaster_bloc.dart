import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'employeemaster_event.dart';
import 'employeemaster_state.dart';



class EmployeeMasterBloc extends Bloc<EmployeeMasterEvent, EmployeeState> {
  final BuildContext context;

  // ── List page-க்கு init ──────────────────────────────────────────────────
  EmployeeMasterBloc.list(this.context) : super(const EmployeeListLoading()) {
    _registerHandlers();
    add(const LoadEmployeesmasterEvent());
  }

  // ── Add/Edit page-க்கு init ──────────────────────────────────────────────
  EmployeeMasterBloc.form(this.context, {EmployeeDetailsModel? existing})
      : super(EmployeeFormState(
    employee: existing ?? EmployeeDetailsModel.Empty(),
    selectedCurrency: existing?.Employeecurrency?.isNotEmpty == true
        ? existing!.Employeecurrency
        : null,
    selectedEmployeeType: existing?.EmployeeType?.isNotEmpty == true
        ? existing!.EmployeeType
        : null,
    selectedRulesType: existing?.RulesType?.isNotEmpty == true
        ? existing!.RulesType
        : null,
  )) {
    _registerHandlers();
  }

  void _registerHandlers() {
    // List Events
    on<LoadEmployeesmasterEvent>(_onLoad);
    on<SearchEmployeeMasterEvent>(_onSearch);
    on<DeleteEmployeeMasterEvent>(_onDelete);

    // Form Events
    on<UpdateFieldEvent>(_onUpdateField);
    on<SelectCurrencyEvent>(_onSelectCurrency);
    on<SelectEmployeeTypeEvent>(_onSelectEmployeeType);
    on<SelectRulesTypeEvent>(_onSelectRulesType);
    on<SelectJoiningDateEvent>(_onSelectJoiningDate);
    on<SelectLeavingDateEvent>(_onSelectLeavingDate);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<SaveEmployeeMasterEvent>(_onSave);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LIST HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onLoad(
      LoadEmployeesmasterEvent event,
      Emitter<EmployeeState> emit,
      ) async {
    emit(const EmployeeListLoading());
    await _fetchEmployees(emit);
  }

  void _onSearch(SearchEmployeeMasterEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeListLoaded) return;
    final current = state as EmployeeListLoaded;
    final query = event.query.toLowerCase();

    final filtered = query.isEmpty
        ? List<EmployeeDetailsModel>.from(current.allRecords)
        : current.allRecords.where((emp) {
      return (emp.EmployeeName ?? '').toLowerCase().contains(query) ||
          (emp.MobileNo ?? '').toLowerCase().contains(query);
    }).toList();

    emit(current.copyWith(filteredRecords: filtered, searchQuery: event.query));
  }

  Future<void> _onDelete(
      DeleteEmployeeMasterEvent event,
      Emitter<EmployeeState> emit,
      ) async {
    final previous = state;
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final apiUrl =
          "${objfun.apiDeleteEmployeeType}${event.id}&Comid=$comid";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      String message = 'Employee deleted successfully';
      if (resultData is String && resultData.contains('Deleted')) {
        message = resultData;
      }

      emit(EmployeeDeleteSuccess(message));
      await _fetchEmployees(emit);
    } catch (e) {
      emit(EmployeeError(e.toString()));
      emit(previous);
    }
  }

  Future<void> _fetchEmployees(Emitter<EmployeeState> emit) async {
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final apiUrl =
          "${objfun.apiSelectEmployeeDetails}$comid&Startindex=0&PageCount=100&keyword=&Column=All&type=";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl,
        '',
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      if (resultData is List && resultData.isNotEmpty) {
        final records = resultData
            .map((e) =>
            EmployeeDetailsModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(EmployeeListLoaded(
            allRecords: records, filteredRecords: records));
      } else {
        emit(const EmployeeListLoaded(allRecords: [], filteredRecords: []));
      }
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FORM HANDLERS
  // ════════════════════════════════════════════════════════════════════════════

  void _onUpdateField(UpdateFieldEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    final emp = s.employee;

    switch (event.field) {
      case 'EmployeeName': emp.EmployeeName = event.value; break;
      case 'Email':        emp.Email = event.value; break;
      case 'MobileNo':     emp.MobileNo = event.value; break;
      case 'EmergencyNo':  emp.EmergencyNo = event.value; break;
      case 'Address1':     emp.Address1 = event.value; break;
      case 'Address2':     emp.Address2 = event.value; break;
      case 'City':         emp.City = event.value; break;
      case 'State':        emp.State = event.value; break;
      case 'Zipcode':      emp.Zipcode = event.value; break;
      case 'Country':      emp.Country = event.value; break;
      case 'GSTNO':        emp.GSTNO = event.value; break;
      case 'UserName':     emp.UserName = event.value; break;
      case 'Password':     emp.Password = event.value; break;
      case 'Latitude':     emp.Latitude = event.value; break;
      case 'longitude':    emp.longitude = event.value; break;
      case 'BankName':     emp.BankName = event.value; break;
      case 'AccountNo':    emp.AccountNo = event.value; break;
      case 'AccountCode':  emp.AccountCode = event.value; break;
    }
    emit(s.copyWith(employee: emp));
  }

  void _onSelectCurrency(
      SelectCurrencyEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    s.employee.Employeecurrency = event.currency ?? '';
    emit(s.copyWith(selectedCurrency: event.currency));
  }

  void _onSelectEmployeeType(
      SelectEmployeeTypeEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    s.employee.EmployeeType = event.employeeType ?? '';
    emit(s.copyWith(selectedEmployeeType: event.employeeType));
  }

  void _onSelectRulesType(
      SelectRulesTypeEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    s.employee.RulesType = event.rulesType ?? '';
    emit(s.copyWith(selectedRulesType: event.rulesType));
  }

  void _onSelectJoiningDate(
      SelectJoiningDateEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    s.employee.JoiningDate = event.date;
    emit(s.copyWith(employee: s.employee));
  }

  void _onSelectLeavingDate(
      SelectLeavingDateEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    s.employee.LeavingDate = event.date;
    emit(s.copyWith(employee: s.employee));
  }

  void _onNextStep(NextStepEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    if (s.currentStep < 3) emit(s.copyWith(currentStep: s.currentStep + 1));
  }

  void _onPreviousStep(PreviousStepEvent event, Emitter<EmployeeState> emit) {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    if (s.currentStep > 0) emit(s.copyWith(currentStep: s.currentStep - 1));
  }

  Future<void> _onSave(
      SaveEmployeeMasterEvent event, Emitter<EmployeeState> emit) async {
    if (state is! EmployeeFormState) return;
    final s = state as EmployeeFormState;
    emit(s.copyWith(isSaving: true));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiInsertEmployeeDetails,
        [s.employee.toJson()],
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'Comid': comid.toString(),
        },
        context,
      );

      if (resultData is Map) {
        final bool ok = resultData['ok'] ?? false;
        final String msg = resultData['message'] ?? 'Something went wrong';
        ok
            ? emit(EmployeeSaveSuccess(msg))
            : emit(EmployeeError(msg));
      } else {
        final int id = int.tryParse(resultData.toString()) ?? 0;
        id > 0
            ? emit(const EmployeeSaveSuccess('Employee saved successfully ✅'))
            : emit(const EmployeeError('Unexpected response'));
      }
    } catch (e) {
      emit(s.copyWith(isSaving: false));
      emit(EmployeeError(e.toString()));
    }
  }
}