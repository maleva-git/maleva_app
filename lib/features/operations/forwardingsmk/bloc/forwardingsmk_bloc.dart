import 'package:flutter/foundation.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


import 'forwardingsmk_event.dart';
import 'forwardingsmk_state.dart';


/// Forwarding SMK numbers, references, S1/S2 and dates of a job, on the shared
/// Java sale order API (`/job-numbers`, `/edit`, `PUT /{id}/forwarding`).
class FWSmkBloc extends Bloc<FWSmkEvent, FWSmkState> {
  final SaleOrderApi _saleOrders;
  List<Map<String, dynamic>> _jobs = const [];

  FWSmkBloc({SaleOrderApi? saleOrders})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        super(FWSmkInitial()) {
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
    // Show UI instantly
    emit(_defaultLoaded());
    try {
      _jobs = await _saleOrders.jobNumbers(0);
    } catch (e) {
      // Background load failed, ignore
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
      _jobs = await _saleOrders.jobNumbers(int.parse(event.billType));
    } catch (e, stack) { debugPrint("Error caught globally: $e\n$stack"); }
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
      filtered = _jobs
          .where((e) => '${e['cNumber'] ?? ''}'.contains(q))
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
      final m = (await _saleOrders.edit(id: event.saleOrderId)).master;
      await sl<LegacyApiRepository>().SelectEmployee(null, '', 'Operation');

      if (m.isEmpty) {
        emit(s.copyWith(
          jobNoText:        event.jobNo,
          saleOrderId:      event.saleOrderId,
          jobNoSuggestions: [],
        ));
        return;
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String parseDate(dynamic raw) {
        if (raw == null) return today;
        try {
          return DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(raw.toString()));
        } catch (_) {
          return today;
        }
      }

      final tab1 = FWSmkTabData(
        smkNo:       m['forwardingSMKNo'] ?? '',
        enRef:       m['forwardingEnterRef'] ?? '',
        s1:          m['forwarding1S1'] ?? '',
        s2:          m['forwarding1S2'] ?? '',
        fwDropdown:  (m['forwarding'] == null || m['forwarding'] == '')
            ? null
            : m['forwarding'],
        date:        parseDate(m['forwardingDate']),
        dateEnabled: m['forwardingDate'] != null,
        original:    (m['original'] != null && (m['original'] == 1 || m['original'] == true)), // 🔥 Fix: Add null check

      );
      final tab2 = FWSmkTabData(
        smkNo:       m['forwardingSMKNo2'] ?? '',
        enRef:       m['forwardingEnterRef2'] ?? '',
        s1:          m['forwarding2S1'] ?? '',
        s2:          m['forwarding2S2'] ?? '',
        fwDropdown:  (m['forwarding2'] == null || m['forwarding2'] == '')
            ? null
            : m['forwarding2'],
        date:        parseDate(m['forwarding2Date']),
        dateEnabled: m['forwarding2Date'] != null,
        original:    (m['original'] != null && (m['original'] == 1 || m['original'] == true)), // 🔥 Fix: Add null check
      );
      final tab3 = FWSmkTabData(
        smkNo:       m['forwardingSMKNo3'] ?? '',
        enRef:       m['forwardingEnterRef3'] ?? '',
        s1:          m['forwarding3S1'] ?? '',
        s2:          m['forwarding3S2'] ?? '',
        fwDropdown:  (m['forwarding3'] == null || m['forwarding3'] == '')
            ? null
            : m['forwarding3'],
        date:        parseDate(m['forwarding3Date']),
        dateEnabled: m['forwarding3Date'] != null,
        original:    (m['original'] != null && (m['original'] == 1 || m['original'] == true)), // 🔥 Fix: Add null check
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
      case 'original':

        updated = tab.copyWith(original: event.value == 'true');
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
      String? at(FWSmkTabData t) => t.dateEnabled ? DateTime.parse(t.date).toIso8601String() : null;
      await _saleOrders.updateForwarding(s.saleOrderId, {
        'forwardingSMKNo':     s.tab1.smkNo,
        'forwardingSMKNo2':    s.tab2.smkNo,
        'forwardingSMKNo3':    s.tab3.smkNo,
        'forwarding':          s.tab1.fwDropdown,
        'forwarding2':         s.tab2.fwDropdown,
        'forwarding3':         s.tab3.fwDropdown,
        'forwardingEnterRef':  s.tab1.enRef,
        'forwardingEnterRef2': s.tab2.enRef,
        'forwardingEnterRef3': s.tab3.enRef,
        'forwarding1S1':       s.tab1.s1,
        'forwarding1S2':       s.tab1.s2,
        'forwarding2S1':       s.tab2.s1,
        'forwarding2S2':       s.tab2.s2,
        'forwarding3S1':       s.tab3.s1,
        'forwarding3S2':       s.tab3.s2,
        'forwardingDate':      at(s.tab1),
        'forwarding2Date':     at(s.tab2),
        'forwarding3Date':     at(s.tab3),
        'original':            s.tab1.original || s.tab2.original || s.tab3.original,
      });
      emit(FWSmkSaveSuccess());
      emit(_defaultLoaded());
    } catch (e) {
      emit(FWSmkError(e.toString()));
    }
  }
}