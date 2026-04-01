import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';

import 'forwardingsmk_event.dart';
import 'forwardingsmk_state.dart';


class FWSmkBloc extends Bloc<FWSmkEvent, FWSmkState> {
  FWSmkBloc() : super(FWSmkInitial()) {
    on<FWSmkStarted>(_onStarted);
    on<FWSmkTabChanged>(_onTabChanged);
    on<FWSmkBillTypeChanged>(_onBillTypeChanged);
    on<FWSmkJobNoTextChanged>(_onJobNoTextChanged);
    on<FWSmkJobNoSelected>(_onJobNoSelected);
    on<FWSmkOverlayDismissed>(_onOverlayDismissed);
    on<FWSmkFieldChanged>(_onFieldChanged);
    on<FWSmkDateChanged>(_onDateChanged);
    on<FWSmkCheckboxChanged>(_onCheckboxChanged);
    on<FWSmkSaveRequested>(_onSaveRequested);
  }

  // ── Default state ──────────────────────────────────────────────────────────
  FWSmkLoaded _defaultLoaded() => FWSmkLoaded(
    currentTab:       0,
    billType:         '0',
    jobNoText:        '',
    saleOrderId:      0,
    jobNoSuggestions: [],
    tab1:             FWSmkTabData.empty(),
    tab2:             FWSmkTabData.empty(),
    tab3:             FWSmkTabData.empty(),
  );

  // ── Startup ────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      FWSmkStarted event, Emitter<FWSmkState> emit) async {
    emit(FWSmkLoading());
    try {
      await OnlineApi.GetJobNoForwarding(null, 0);
      await OnlineApi.loadComboS1(null, 0);
      emit(_defaultLoaded());
    } catch (e) {
      emit(FWSmkError(e.toString()));
    }
  }

  // ── Tab ────────────────────────────────────────────────────────────────────
  void _onTabChanged(FWSmkTabChanged event, Emitter<FWSmkState> emit) {
    if (state is FWSmkLoaded) {
      emit((state as FWSmkLoaded).copyWith(currentTab: event.index));
    }
  }

  // ── BillType radio ─────────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(
      FWSmkBillTypeChanged event, Emitter<FWSmkState> emit) async {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;
    try {
      await OnlineApi.GetJobNoForwarding(null, int.parse(event.billType));
    } catch (_) {}
    emit(s.copyWith(
      billType:         event.billType,
      jobNoText:        '',
      saleOrderId:      0,
      jobNoSuggestions: [],
    ));
  }

  // ── Job No text typed ──────────────────────────────────────────────────────
  void _onJobNoTextChanged(
      FWSmkJobNoTextChanged event, Emitter<FWSmkState> emit) {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;
    final q = event.text.trim();

    List<dynamic> filtered = [];
    if (q.isNotEmpty) {
      filtered = objfun.JobNoList
          .where((e) => e['CNumber'].toString().contains(q))
          .toList();
    }
    emit(s.copyWith(
      jobNoText:        q,
      jobNoSuggestions: filtered,
      saleOrderId:      0,
    ));
  }

  // ── Job No suggestion selected ─────────────────────────────────────────────
  Future<void> _onJobNoSelected(
      FWSmkJobNoSelected event, Emitter<FWSmkState> emit) async {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;

    emit(FWSmkLoading());
    try {
      await OnlineApi.EditSalesOrder(null, event.saleOrderId, 0);
      await OnlineApi.SelectEmployee(null, '', 'Operation');

      final m = objfun.SaleEditMasterList;
      if (m.isEmpty) {
        emit(s.copyWith(
          jobNoText:        event.jobNo,
          saleOrderId:      event.saleOrderId,
          jobNoSuggestions: [],
        ));
        return;
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String _parseDate(dynamic raw) {
        if (raw == null) return today;
        try {
          return DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(raw.toString()));
        } catch (_) {
          return today;
        }
      }

      final tab1 = FWSmkTabData(
        smkNo:       m[0]['ForwardingSMKNo'] ?? '',
        enRef:       m[0]['ForwardingEnterRef'] ?? '',
        s1:          m[0]['Forwarding1S1'] ?? '',
        s2:          m[0]['Forwarding1S2'] ?? '',
        fwDropdown:  (m[0]['Forwarding'] == null || m[0]['Forwarding'] == '')
            ? null
            : m[0]['Forwarding'],
        date:        _parseDate(m[0]['ForwardingDate']),
        dateEnabled: m[0]['ForwardingDate'] != null,
      );
      final tab2 = FWSmkTabData(
        smkNo:       m[0]['ForwardingSMKNo2'] ?? '',
        enRef:       m[0]['ForwardingEnterRef2'] ?? '',
        s1:          m[0]['Forwarding2S1'] ?? '',
        s2:          m[0]['Forwarding2S2'] ?? '',
        fwDropdown:  (m[0]['Forwarding2'] == null || m[0]['Forwarding2'] == '')
            ? null
            : m[0]['Forwarding2'],
        date:        _parseDate(m[0]['Forwarding2Date']),
        dateEnabled: m[0]['Forwarding2Date'] != null,
      );
      final tab3 = FWSmkTabData(
        smkNo:       m[0]['ForwardingSMKNo3'] ?? '',
        enRef:       m[0]['ForwardingEnterRef3'] ?? '',
        s1:          m[0]['Forwarding3S1'] ?? '',
        s2:          m[0]['Forwarding3S2'] ?? '',
        fwDropdown:  (m[0]['Forwarding3'] == null || m[0]['Forwarding3'] == '')
            ? null
            : m[0]['Forwarding3'],
        date:        _parseDate(m[0]['Forwarding3Date']),
        dateEnabled: m[0]['Forwarding3Date'] != null,
      );

      emit(s.copyWith(
        jobNoText:        event.jobNo,
        saleOrderId:      event.saleOrderId,
        jobNoSuggestions: [],
        tab1:             tab1,
        tab2:             tab2,
        tab3:             tab3,
      ));
    } catch (e) {
      emit(FWSmkError(e.toString()));
    }
  }

  // ── Overlay dismissed ──────────────────────────────────────────────────────
  void _onOverlayDismissed(
      FWSmkOverlayDismissed event, Emitter<FWSmkState> emit) {
    if (state is FWSmkLoaded) {
      emit((state as FWSmkLoaded).copyWith(jobNoSuggestions: []));
    }
  }

  // ── Generic field change ───────────────────────────────────────────────────
  void _onFieldChanged(FWSmkFieldChanged event, Emitter<FWSmkState> emit) {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;
    final tab = s.tabByIndex(event.tab);

    FWSmkTabData updated;
    switch (event.field) {
      case 'smkNo':
        updated = tab.copyWith(smkNo: event.value);
        break;
      case 'enRef':
        updated = tab.copyWith(enRef: event.value);
        break;
      case 's1':
        updated = tab.copyWith(s1: event.value);
        break;
      case 's2':
        updated = tab.copyWith(s2: event.value);
        break;
      case 'fwDropdown':
        updated = tab.copyWith(fwDropdown: event.value);
        break;
      default:
        return;
    }
    emit(s.withTab(event.tab, updated));
  }

  // ── Date ───────────────────────────────────────────────────────────────────
  void _onDateChanged(FWSmkDateChanged event, Emitter<FWSmkState> emit) {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;
    final updated = s.tabByIndex(event.tab).copyWith(date: event.date);
    emit(s.withTab(event.tab, updated));
  }

  // ── Checkbox ───────────────────────────────────────────────────────────────
  void _onCheckboxChanged(
      FWSmkCheckboxChanged event, Emitter<FWSmkState> emit) {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;
    final updated =
    s.tabByIndex(event.tab).copyWith(dateEnabled: event.value);
    emit(s.withTab(event.tab, updated));
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      FWSmkSaveRequested event, Emitter<FWSmkState> emit) async {
    if (state is! FWSmkLoaded) return;
    final s = state as FWSmkLoaded;

    emit(FWSmkLoading());
    try {
      final master = {
        'Id':                s.saleOrderId,
        'Comid':             objfun.Comid,
        'Jobid':             s.jobNoText,
        'EmployeeRefId':     objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'ForwardingSMKNo':   s.tab1.smkNo,
        'ForwardingSMKNo2':  s.tab2.smkNo,
        'ForwardingSMKNo3':  s.tab3.smkNo,
        'Forwarding':        s.tab1.fwDropdown,
        'Forwarding2':       s.tab2.fwDropdown,
        'Forwarding3':       s.tab3.fwDropdown,
        'ForwardingEnterRef':  s.tab1.enRef,
        'ForwardingEnterRef2': s.tab2.enRef,
        'ForwardingEnterRef3': s.tab3.enRef,
        'Forwarding1S1':     s.tab1.s1,
        'Forwarding1S2':     s.tab1.s2,
        'Forwarding2S1':     s.tab2.s1,
        'Forwarding2S2':     s.tab2.s2,
        'Forwarding3S1':     s.tab3.s1,
        'Forwarding3S2':     s.tab3.s2,
        'ForwardingDate':  s.tab1.dateEnabled
            ? DateTime.parse(s.tab1.date).toIso8601String()
            : null,
        'Forwarding2Date': s.tab2.dateEnabled
            ? DateTime.parse(s.tab2.date).toIso8601String()
            : null,
        'Forwarding3Date': s.tab3.dateEnabled
            ? DateTime.parse(s.tab3.date).toIso8601String()
            : null,
      };

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiUpdateForwarding, master, header, null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          emit(FWSmkSaveSuccess());
          emit(_defaultLoaded());
          return;
        }
      }
      emit(s); // revert on failure
    } catch (e) {
      emit(FWSmkError(e.toString()));
    }
  }
}