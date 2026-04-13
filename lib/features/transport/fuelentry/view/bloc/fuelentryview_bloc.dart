import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'fuelentryview_event.dart';
import 'fuelentryview_state.dart';

class FuelEntryViewBloc
    extends Bloc<FuelEntryViewEvent, FuelEntryViewState> {
  FuelEntryViewBloc() : super(FuelEntryViewInitial()) {
    on<FuelEntryViewStarted>(_onStarted);
    on<FuelEntryViewFromDateChanged>(_onFromDate);
    on<FuelEntryViewToDateChanged>(_onToDate);
    on<FuelEntryViewLoadRequested>(_onLoadRequested);
    on<FuelEntryViewDeleteRequested>(_onDeleteRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      FuelEntryViewStarted event,
      Emitter<FuelEntryViewState> emit) async {
    emit(FuelEntryViewLoading());
    try {
      final items = await _fetchItems(
        fromDate: FuelEntryViewLoaded.today(),
        toDate:   FuelEntryViewLoaded.today(),
      );
      emit(FuelEntryViewLoaded(
        fromDate: FuelEntryViewLoaded.today(),
        toDate:   FuelEntryViewLoaded.today(),
        items:    items,
      ));
    } catch (e) {
      emit(FuelEntryViewError(e.toString()));
    }
  }

  // ── Date filters ─────────────────────────────────────────────────────────────
  void _onFromDate(
      FuelEntryViewFromDateChanged event,
      Emitter<FuelEntryViewState> emit) {
    if (state is FuelEntryViewLoaded) {
      emit((state as FuelEntryViewLoaded)
          .copyWith(fromDate: event.date));
    }
  }

  void _onToDate(
      FuelEntryViewToDateChanged event,
      Emitter<FuelEntryViewState> emit) {
    if (state is FuelEntryViewLoaded) {
      emit((state as FuelEntryViewLoaded)
          .copyWith(toDate: event.date));
    }
  }

  // ── Load ─────────────────────────────────────────────────────────────────────
  Future<void> _onLoadRequested(
      FuelEntryViewLoadRequested event,
      Emitter<FuelEntryViewState> emit) async {
    if (state is! FuelEntryViewLoaded) return;
    final s = state as FuelEntryViewLoaded;

    emit(FuelEntryViewLoading());
    try {
      final items =
      await _fetchItems(fromDate: s.fromDate, toDate: s.toDate);
      emit(s.copyWith(items: items));
    } catch (e) {
      emit(FuelEntryViewError(e.toString()));
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────────
  Future<void> _onDeleteRequested(
      FuelEntryViewDeleteRequested event,
      Emitter<FuelEntryViewState> emit) async {
    if (state is! FuelEntryViewLoaded) return;
    final s = state as FuelEntryViewLoaded;

    emit(FuelEntryViewLoading());
    try {
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      await objfun.apiAllinoneSelectArray(
          '${objfun.apiDeleteFuelEntry}${event.item['Id']}'
              '&Comid=${event.item['CompanyRefId']}&Mobile=1',
          {},
          header,
          null);

      // Reload after delete
      final items =
      await _fetchItems(fromDate: s.fromDate, toDate: s.toDate);
      emit(s.copyWith(items: items));
    } catch (e) {
      emit(FuelEntryViewError(e.toString()));
    }
  }

  // ── API helper ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> _fetchItems({
    required String fromDate,
    required String toDate,
  }) async {
    final comId = objfun.storagenew.getInt('Comid') ?? 0;
    final master = {
      'Comid':      comId,
      'Fromdate':   fromDate,
      'Todate':     toDate,
      'Employeeid': 0,
      'DId':        objfun.DriverTruckRefId,
      'TId':        objfun.EmpRefId,
      'Search':     '',
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final result = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry, master, header, null);

    if (result != '' && result.length != 0) {
      return List<dynamic>.from(result as List);
    }
    return [];
  }
}