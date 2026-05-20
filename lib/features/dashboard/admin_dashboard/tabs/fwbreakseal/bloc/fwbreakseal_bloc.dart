import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:flutter/material.dart';

import 'fwbreakseal_event.dart';
import 'fwbreakseal_state.dart';



class FWBreakSealBloc extends Bloc<FWBreakSealEvent, FWBreakSealState> {
  final BuildContext context;

  FWBreakSealBloc({required this.context})
      : super(FWBreakSealState(
    userName: objfun.storagenew.getString('Username') ?? '',
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

  // ─── Initialise ──────────────────────────────────────────────────────────

  Future<void> _onInitialised(
      FWBreakSealInitialised event,
      Emitter<FWBreakSealState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await OnlineApi.GetJobNoForwarding(context, 3);
    } catch (_) {}
    emit(state.copyWith(isLoading: false));
  }

  // ─── Tab changed ─────────────────────────────────────────────────────────

  void _onTabChanged(
      FWBreakSealTabChanged event,
      Emitter<FWBreakSealState> emit,
      ) {
    emit(state.copyWith(
      activeTab: event.index,
      overlayStatus: OverlayStatus.hidden,
    ));
  }

  // ─── SMK text changed → filter suggestions ───────────────────────────────

  void _onSmkChanged(
      FWBreakSealSmkChanged event,
      Emitter<FWBreakSealState> emit,
      ) {
    final value = event.value.trim();

    // Update the typed text in the matching slot
    emit(_updateSlotSmkNo(state, event.smkType, value));

    if (value.isEmpty) {
      emit(state.copyWith(
          overlayStatus: OverlayStatus.hidden, suggestions: const []));
      return;
    }

    final List<Map<String, dynamic>> allJobs =
    List<Map<String, dynamic>>.from(objfun.JobNoList);

    final String field = event.smkType == 1
        ? 'ForwardingSMKNo'
        : event.smkType == 2
        ? 'ForwardingSMKNo2'
        : 'ForwardingSMKNo3';

    final filtered = allJobs
        .where((e) => e[field].toString().contains(value))
        .toList();

    emit(state.copyWith(
      suggestions: filtered,
      overlayStatus:
      filtered.isEmpty ? OverlayStatus.hidden : OverlayStatus.visible,
      overlayForType: event.smkType,
    ));

    if (filtered.isEmpty) {
      objfun.toastMsg("Enter Correct Smk No", " ", context);
    }
  }

  // ─── User selected a suggestion ─────────────────────────────────────────

  Future<void> _onSmkSelected(
      FWBreakSealSmkSelected event,
      Emitter<FWBreakSealState> emit,
      ) async {
    emit(state.copyWith(
        isLoading: true, overlayStatus: OverlayStatus.hidden));

    try {
      final int id = event.prediction['Id'] as int;
      final int cNumber = int.parse(event.prediction['CNumber'].toString());

      await OnlineApi.EditSalesOrder(context, id, cNumber);
      await OnlineApi.SelectEmployee(context, '', 'Operation');

      final editData = objfun.SaleEditMasterList[0];
      final int t = event.smkType;

      final String smkField = t == 1
          ? 'ForwardingSMKNo'
          : t == 2
          ? 'ForwardingSMKNo2'
          : 'ForwardingSMKNo3';
      final String exRefField = t == 1
          ? 'ForwardingExitRef'
          : t == 2
          ? 'ForwardingExitRef2'
          : 'ForwardingExitRef3';
      final String sealRefField = t == 1
          ? 'SealbreakbyRefid'
          : t == 2
          ? 'SealbreakbyRefid2'
          : 'SealbreakbyRefid3';

      final String smkNo = event.prediction[smkField].toString();
      final String exRef = editData[exRefField] ?? '';
      final int sealRefId = editData[sealRefField] ?? 0;

      String empName = '';
      int empId = 0;

      if (sealRefId != 0) {
        empId = sealRefId;
        final matches = objfun.EmployeeList
            .where((item) => item.Id == empId)
            .toList();
        if (matches.isNotEmpty) empName = matches[0].AccountName;
      }

      final updatedSlot = SmkSlotData(
        smkNo: smkNo,
        exRef: exRef,
        breakByEmpId: empId,
        breakByEmpName: empName,
      );

      FWBreakSealState next = _applySlot(state, t, updatedSlot);
      next = next.copyWith(saleOrderId: id, isLoading: false);
      emit(next);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        screenStatus: FWScreenStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Overlay closed ──────────────────────────────────────────────────────

  void _onOverlayClosed(
      FWBreakSealOverlayClosed event,
      Emitter<FWBreakSealState> emit,
      ) {
    emit(state.copyWith(
        overlayStatus: OverlayStatus.hidden, suggestions: const []));
  }

  // ─── Employee search tapped ──────────────────────────────────────────────

  Future<void> _onEmpSearchTapped(
      FWBreakSealEmpSearchTapped event,
      Emitter<FWBreakSealState> emit,
      ) async {
    if (event.isClear) {
      // Clear the selected employee
      final clearedSlot =
      state.slotFor(event.smkType).copyWith(breakByEmpId: 0, breakByEmpName: '');
      emit(_applySlot(state, event.smkType, clearedSlot));
    } else {
      await OnlineApi.SelectEmployee(context, '', 'Operation');
      // Navigation to Employee picker is handled in the UI layer;
      // result comes back via FWBreakSealEmpSelected.
    }
  }

  // ─── Employee selected from picker ──────────────────────────────────────

  void _onEmpSelected(
      FWBreakSealEmpSelected event,
      Emitter<FWBreakSealState> emit,
      ) {
    final updated = state.slotFor(event.smkType).copyWith(
      breakByEmpId: event.empId,
      breakByEmpName: event.empName,
    );
    emit(_applySlot(state, event.smkType, updated));
  }

  // ─── ExRef text changed ──────────────────────────────────────────────────

  void _onExRefChanged(
      FWBreakSealExRefChanged event,
      Emitter<FWBreakSealState> emit,
      ) {
    final updated = state.slotFor(event.smkType).copyWith(exRef: event.value);
    emit(_applySlot(state, event.smkType, updated));
  }

  // ─── Submit ──────────────────────────────────────────────────────────────

  Future<void> _onUpdateSubmitted(
      FWBreakSealUpdateSubmitted event,
      Emitter<FWBreakSealState> emit,
      ) async {
    final s1 = state.slot1;
    final s2 = state.slot2;
    final s3 = state.slot3;

    // Validation: at least one SMK entered
    if (s1.isEmpty && s2.isEmpty && s3.isEmpty) {
      objfun.toastMsg('Enter Entry SMK No', '', context);
      return;
    }

    // Only one ExRef can be filled at a time
    final exCount = [s1.exRef, s2.exRef, s3.exRef]
        .where((e) => e.isNotEmpty)
        .length;
    if (exCount > 1) {
      objfun.toastMsg('Enter Proper Exit Ref Details', '', context);
      return;
    }

    // Only one SMK can be filled at a time
    final smkCount = [s1.smkNo, s2.smkNo, s3.smkNo]
        .where((e) => e.isNotEmpty)
        .length;
    if (smkCount > 1) {
      objfun.toastMsg('Enter Proper Entry Details', '', context);
      return;
    }

    final confirmed =
    await objfun.ConfirmationMsgYesNo(context, "Are you sure to Update ?");
    if (!confirmed) return;

    emit(state.copyWith(isLoading: true, screenStatus: FWScreenStatus.idle));

    try {
      final editData = objfun.SaleEditMasterList[0];

      final Map<String?, dynamic> master = {
        'Id': state.saleOrderId,
        'Comid': objfun.Comid,
        'Jobid': s1.smkNo,
        'EmployeeRefId':
        objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'SealbyRefid': 0,
        'SealbreakbyRefid': s1.breakByEmpId,
        'SealbyRefid2': 0,
        'SealbreakbyRefid2': s2.breakByEmpId,
        'SealbyRefid3': 0,
        'SealbreakbyRefid3': s3.breakByEmpId,
        'ForwardingEnterRef': editData["ForwardingEnterRef"] ?? '',
        'ForwardingExitRef': s1.exRef,
        'ForwardingEnterRef2': editData["ForwardingEnterRef2"] ?? '',
        'ForwardingExitRef2': s2.exRef,
        'ForwardingEnterRef3': editData["ForwardingEnterRef3"] ?? '',
        'ForwardingExitRef3': s3.exRef,
        'Forwarding': null,
        'Forwarding2': null,
        'Forwarding3': null,
      };

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      await objfun
          .apiAllinoneSelectArray(
        objfun.apiUpdateForwarding,
        master,
        header,
        context,
      )
          .then((resultData) async {
        if (resultData != '') {
          final ResponseViewModel? value =
          ResponseViewModel.fromJson(resultData);
          if (value?.IsSuccess == true) {
            emit(state.copyWith(
              isLoading: false,
              screenStatus: FWScreenStatus.success,
              successMessage: 'Updated Successfully',
            ));
          } else {
            emit(state.copyWith(
              isLoading: false,
              screenStatus: FWScreenStatus.failure,
              errorMessage: value?.Message ?? 'Update failed',
            ));
          }
        }
      });
    } catch (e, st) {
      emit(state.copyWith(
        isLoading: false,
        screenStatus: FWScreenStatus.failure,
        errorMessage: e.toString(),
      ));
      debugPrint(st.toString());
    }
  }

  // ─── Clear / reset ───────────────────────────────────────────────────────

  void _onCleared(
      FWBreakSealCleared event,
      Emitter<FWBreakSealState> emit,
      ) {
    emit(state.cleared);
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  /// Returns a new state with the given slot replaced.
  FWBreakSealState _applySlot(
      FWBreakSealState s, int type, SmkSlotData slot) {
    switch (type) {
      case 2:
        return s.copyWith(slot2: slot);
      case 3:
        return s.copyWith(slot3: slot);
      default:
        return s.copyWith(slot1: slot);
    }
  }

  /// Updates only the SMK number in a slot without touching other fields.
  FWBreakSealState _updateSlotSmkNo(
      FWBreakSealState s, int type, String smkNo) {
    final updated = s.slotFor(type).copyWith(smkNo: smkNo);
    return _applySlot(s, type, updated);
  }
}