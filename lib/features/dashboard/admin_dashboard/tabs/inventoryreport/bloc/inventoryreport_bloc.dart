import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/inventoryreport_repository.dart';
import 'inventoryreport_event.dart';
import 'inventoryreport_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  // ❌ REMOVED: final BuildContext context;
  final InventoryReportRepository repository; // ✅ Injected Repository

  InventoryBloc({
    required this.repository,
    DateTime? fromDate,
    DateTime? toDate,
  }) : super(InventoryLoaded(
    // ✅ Defaults applied seamlessly
    fromDate: fromDate ?? DateTime.now(),
    toDate: toDate ?? DateTime.now().add(const Duration(days: 6)),
  )) {
    on<LoadInventoryListsEvent>(_onLoadLists);
    on<SelectPortFilterEvent>(_onPortFilter);
    on<SelectInventoryFromDateEvent>(_onFromDate);
    on<SelectInventoryToDateEvent>(_onToDate);
    on<SearchInventoryByDateEvent>(_onSearchByDate);
    on<SelectInventoryCustomerEvent>(_onCustomer);
    on<ToggleInventoryStatusEvent>(_onToggle);
    on<SelectInventoryItemEvent>(_onSelectItem);

    // Auto-load on init
    add(const LoadInventoryListsEvent());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  InventoryLoaded get _s => state is InventoryLoaded
      ? state as InventoryLoaded
      : InventoryLoaded(
    fromDate: DateTime.now(),
    toDate: DateTime.now(),
  );

  void _onSelectItem(
      SelectInventoryItemEvent event,
      Emitter<InventoryState> emit,
      ) {
    if (state is InventoryLoaded) {
      emit((state as InventoryLoaded).copyWith(selectedItem: event.item));
    }
  }

  // ── Load Customer list ────────────────────────────────────────────────────
  Future<void> _onLoadLists(
      LoadInventoryListsEvent e, Emitter<InventoryState> emit) async {
    if (objfun.CustomerList.isEmpty) {
      try {
        final comId = objfun.storagenew.getInt('Comid') ?? 0;

        // ✅ REFACTORED: Using the injected repository
        final result = await repository.fetchCustomers(comId);
        if (result != null && result is List && result.isNotEmpty) {
          objfun.CustomerList =
              result.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }
    // Auto-load default data
    await _fetch(emit, _s);
  }

  // ── Port chip tap → reload ────────────────────────────────────────────────
  Future<void> _onPortFilter(
      SelectPortFilterEvent e, Emitter<InventoryState> emit) async {
    final next = _s.copyWith(selectedPortId: e.portId, isLoading: true);
    emit(next);
    await _fetch(emit, next);
  }

  // ── Date pickers (just update, no reload) ─────────────────────────────────
  void _onFromDate(SelectInventoryFromDateEvent e, Emitter<InventoryState> emit) {
    emit(_s.copyWith(fromDate: e.date));
  }

  void _onToDate(SelectInventoryToDateEvent e, Emitter<InventoryState> emit) {
    emit(_s.copyWith(toDate: e.date));
  }

  // ── Search button → reload with dates ─────────────────────────────────────
  Future<void> _onSearchByDate(
      SearchInventoryByDateEvent e, Emitter<InventoryState> emit) async {
    final next = _s.copyWith(isLoading: true);
    emit(next);
    await _fetch(emit, next, isDateSearch: true);
  }

  // ── Customer select ───────────────────────────────────────────────────────
  void _onCustomer(SelectInventoryCustomerEvent e, Emitter<InventoryState> emit) {
    emit(_s.copyWith(selectedCustomerId: e.customerId, clearCustomer: e.customerId == null));
  }

  // ── Checkbox toggle ───────────────────────────────────────────────────────
  void _onToggle(ToggleInventoryStatusEvent e, Emitter<InventoryState> emit) {
    emit(_s.copyWith(
      isChecked: e.isChecked,
      status: e.isChecked ? 1 : 0,
    ));
  }

  // ── API Fetch ─────────────────────────────────────────────────────────────
  Future<void> _fetch(
      Emitter<InventoryState> emit,
      InventoryLoaded s, {
        bool isDateSearch = false,
      }) async {
    emit(s.copyWith(isLoading: true));

    try {
      final String fromStr;
      final String toStr;

      if (isDateSearch) {
        fromStr = DateFormat('yyyy-MM-dd').format(s.fromDate);
        toStr   = DateFormat('yyyy-MM-dd').format(s.toDate);
      } else {
        final next6 = DateTime.now().add(const Duration(days: 6));
        fromStr = DateFormat('yyyy-MM-dd').format(next6);
        toStr   = DateFormat('yyyy-MM-dd').format(next6);
      }

      final body = {
        'Comid':      objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate':   fromStr,
        'Todate':     toStr,
        'PortType':   s.selectedPortId,
        'CustomerId': s.selectedCustomerId ?? 0,
        'Status':     s.status,
      };

      // ✅ REFACTORED: Using the injected repository
      final result = await repository.fetchInventoryReport(body);

      final records = (result != null && result is List && result.isNotEmpty)
          ? result.map<InventoryModel>((e) => InventoryModel.fromJson(e as Map<String, dynamic>)).toList()
          : <InventoryModel>[];

      emit(s.copyWith(records: records, isLoading: false));
    } catch (err) {
      emit(InventoryError(
        message:            err.toString(),
        selectedPortId:     s.selectedPortId,
        fromDate:           s.fromDate,
        toDate:             s.toDate,
        selectedCustomerId: s.selectedCustomerId,
        isChecked:          s.isChecked,
        status:             s.status,
      ));
    }
  }
}