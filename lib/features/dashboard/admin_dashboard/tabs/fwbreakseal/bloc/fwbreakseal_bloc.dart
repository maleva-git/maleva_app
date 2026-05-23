import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import '../data/fwbreakseal_repository.dart';
import 'fwbreakseal_event.dart';
import 'fwbreakseal_state.dart';

class FWBreakSealBloc extends Bloc<FWBreakSealEvent, FWBreakSealState> {
  final FWBreakSealRepository repository;

  // Local caches to replace objfun globals
  List<Map<String, dynamic>> _allJobs = [];
  List<dynamic> _employees = [];
  Map<String, dynamic> _currentEditData = {};

  FWBreakSealBloc({required this.repository})
      : super(FWBreakSealState(
    userName: AppPreferences.getUsername(),
  )) {
    on<FWBreakSealInitialised>(_onInitialised);
    on<FWBreakSealTabChanged>(_onTabChanged);
    on<FWBreakSealSmkChanged>(_onSmkChanged);
    on<FWBreakSealSmkSelected>(_onSmkSelected);
    on<FWBreakSealOverlayClosed>(_onOverlayClosed);
    on<FWBreakSealEmpSearchTapped>(_onEmpSearchTapped);
    on<FWBreakSealEmpSelected>(_onEmpSelected);
    on<FWBreakSealExRefChanged>(_onExRefChanged);
    on<FWBreakSealUpdateSubmitted>(_onUpdateSubmitted);
    on<FWBreakSealCleared>(_onCleared);
  }

  Future<void> _onInitialised(FWBreakSealInitialised event, Emitter<FWBreakSealState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Fetch data that was previously global
      _allJobs = await repository.fetchJobs(3);
      _employees = await repository.fetchEmployees();
    } catch (_) {}
    emit(state.copyWith(isLoading: false));
  }

  void _onTabChanged(FWBreakSealTabChanged event, Emitter<FWBreakSealState> emit) {
    emit(state.copyWith(activeTab: event.index, overlayStatus: OverlayStatus.hidden));
  }

  void _onSmkChanged(FWBreakSealSmkChanged event, Emitter<FWBreakSealState> emit) {
    final value = event.value.trim();
    emit(_updateSlotSmkNo(state, event.smkType, value));

    if (value.isEmpty) {
      emit(state.copyWith(overlayStatus: OverlayStatus.hidden, suggestions: const []));
      return;
    }

    final String field = event.smkType == 1
        ? 'ForwardingSMKNo'
        : event.smkType == 2 ? 'ForwardingSMKNo2' : 'ForwardingSMKNo3';

    final filtered = _allJobs.where((e) => e[field].toString().contains(value)).toList();

    emit(state.copyWith(
      suggestions: filtered,
      overlayStatus: filtered.isEmpty ? OverlayStatus.hidden : OverlayStatus.visible,
      overlayForType: event.smkType,
    ));

    if (filtered.isEmpty) {
      // Emitting error instead of triggering UI toast directly
      emit(state.copyWith(
        screenStatus: FWScreenStatus.failure,
        errorMessage: "Enter Correct Smk No",
      ));
      // Reset status so it can be fired again if needed
      emit(state.copyWith(screenStatus: FWScreenStatus.idle));
    }
  }

  Future<void> _onSmkSelected(FWBreakSealSmkSelected event, Emitter<FWBreakSealState> emit) async {
    emit(state.copyWith(isLoading: true, overlayStatus: OverlayStatus.hidden));

    try {
      final int id = event.prediction['Id'] as int;
      final int cNumber = int.parse(event.prediction['CNumber'].toString());

      // Fetch specific sales order data
      _currentEditData = await repository.fetchSalesOrderDetails(id, cNumber);

      final int t = event.smkType;
      final String smkField = t == 1 ? 'ForwardingSMKNo' : t == 2 ? 'ForwardingSMKNo2' : 'ForwardingSMKNo3';
      final String exRefField = t == 1 ? 'ForwardingExitRef' : t == 2 ? 'ForwardingExitRef2' : 'ForwardingExitRef3';
      final String sealRefField = t == 1 ? 'SealbreakbyRefid' : t == 2 ? 'SealbreakbyRefid2' : 'SealbreakbyRefid3';

      final String smkNo = event.prediction[smkField].toString();
      final String exRef = _currentEditData[exRefField] ?? '';
      final int sealRefId = _currentEditData[sealRefField] ?? 0;

      String empName = '';
      int empId = 0;

      if (sealRefId != 0) {
        empId = sealRefId;
        final matches = _employees.where((item) => item['Id'] == empId).toList(); // Ensure 'Id' matches your API map key
        if (matches.isNotEmpty) empName = matches[0]['AccountName'];
      }

      final updatedSlot = SmkSlotData(
        smkNo: smkNo,
        exRef: exRef,
        breakByEmpId: empId,
        breakByEmpName: empName,
      );

      FWBreakSealState next = _applySlot(state, t, updatedSlot);
      emit(next.copyWith(saleOrderId: id, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, screenStatus: FWScreenStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onOverlayClosed(FWBreakSealOverlayClosed event, Emitter<FWBreakSealState> emit) {
    emit(state.copyWith(overlayStatus: OverlayStatus.hidden, suggestions: const []));
  }

  Future<void> _onEmpSearchTapped(FWBreakSealEmpSearchTapped event, Emitter<FWBreakSealState> emit) async {
    if (event.isClear) {
      final clearedSlot = state.slotFor(event.smkType).copyWith(breakByEmpId: 0, breakByEmpName: '');
      emit(_applySlot(state, event.smkType, clearedSlot));
    } else {
      // Employees are already fetched in _onInitialised.
      // The UI should handle pushing the selection screen using the state/bloc.
    }
  }

  void _onEmpSelected(FWBreakSealEmpSelected event, Emitter<FWBreakSealState> emit) {
    final updated = state.slotFor(event.smkType).copyWith(breakByEmpId: event.empId, breakByEmpName: event.empName);
    emit(_applySlot(state, event.smkType, updated));
  }

  void _onExRefChanged(FWBreakSealExRefChanged event, Emitter<FWBreakSealState> emit) {
    final updated = state.slotFor(event.smkType).copyWith(exRef: event.value);
    emit(_applySlot(state, event.smkType, updated));
  }

  Future<void> _onUpdateSubmitted(FWBreakSealUpdateSubmitted event, Emitter<FWBreakSealState> emit) async {
    final s1 = state.slot1;
    final s2 = state.slot2;
    final s3 = state.slot3;

    if (s1.isEmpty && s2.isEmpty && s3.isEmpty) {
      emit(state.copyWith(screenStatus: FWScreenStatus.failure, errorMessage: 'Enter Entry SMK No'));
      emit(state.copyWith(screenStatus: FWScreenStatus.idle));
      return;
    }

    final exCount = [s1.exRef, s2.exRef, s3.exRef].where((e) => e.isNotEmpty).length;
    if (exCount > 1) {
      emit(state.copyWith(screenStatus: FWScreenStatus.failure, errorMessage: 'Enter Proper Exit Ref Details'));
      emit(state.copyWith(screenStatus: FWScreenStatus.idle));
      return;
    }

    final smkCount = [s1.smkNo, s2.smkNo, s3.smkNo].where((e) => e.isNotEmpty).length;
    if (smkCount > 1) {
      emit(state.copyWith(screenStatus: FWScreenStatus.failure, errorMessage: 'Enter Proper Entry Details'));
      emit(state.copyWith(screenStatus: FWScreenStatus.idle));
      return;
    }

    emit(state.copyWith(isLoading: true, screenStatus: FWScreenStatus.idle));

    try {
      final empRefId = AppPreferences.getEmpRefId();

      final Map<String, dynamic> master = {
        'Id': state.saleOrderId,
        'Comid': AppPreferences.getComid(),
        'Jobid': s1.smkNo,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'SealbyRefid': 0,
        'SealbreakbyRefid': s1.breakByEmpId,
        'SealbyRefid2': 0,
        'SealbreakbyRefid2': s2.breakByEmpId,
        'SealbyRefid3': 0,
        'SealbreakbyRefid3': s3.breakByEmpId,
        'ForwardingEnterRef': _currentEditData["ForwardingEnterRef"] ?? '',
        'ForwardingExitRef': s1.exRef,
        'ForwardingEnterRef2': _currentEditData["ForwardingEnterRef2"] ?? '',
        'ForwardingExitRef2': s2.exRef,
        'ForwardingEnterRef3': _currentEditData["ForwardingEnterRef3"] ?? '',
        'ForwardingExitRef3': s3.exRef,
        'Forwarding': null,
        'Forwarding2': null,
        'Forwarding3': null,
      };

      final result = await repository.updateForwarding(master);

      if (result?.IsSuccess == true) {
        emit(state.copyWith(isLoading: false, screenStatus: FWScreenStatus.success, successMessage: 'Updated Successfully'));
      } else {
        emit(state.copyWith(isLoading: false, screenStatus: FWScreenStatus.failure, errorMessage: result?.Message ?? 'Update failed'));
      }
    } catch (e, st) {
      emit(state.copyWith(isLoading: false, screenStatus: FWScreenStatus.failure, errorMessage: e.toString()));
      debugPrint(st.toString());
    }
  }

  void _onCleared(FWBreakSealCleared event, Emitter<FWBreakSealState> emit) {
    emit(state.cleared);
  }

  FWBreakSealState _applySlot(FWBreakSealState s, int type, SmkSlotData slot) {
    switch (type) {
      case 2: return s.copyWith(slot2: slot);
      case 3: return s.copyWith(slot3: slot);
      default: return s.copyWith(slot1: slot);
    }
  }

  FWBreakSealState _updateSlotSmkNo(FWBreakSealState s, int type, String smkNo) {
    final updated = s.slotFor(type).copyWith(smkNo: smkNo);
    return _applySlot(s, type, updated);
  }
}