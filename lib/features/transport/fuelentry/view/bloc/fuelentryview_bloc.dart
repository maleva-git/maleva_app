import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'fuelentryview_event.dart';
import 'fuelentryview_state.dart';

/// The driver's fuel list, on the shared Java `/api/fuel-entries` (change
/// `fuel-entry-on-shared-java-api`); [FuelEntryViewLoaded.items] are the Java rows.
class FuelEntryViewBloc
    extends Bloc<FuelEntryViewEvent, FuelEntryViewState> {
  final FuelEntryApi _api;

  FuelEntryViewBloc({FuelEntryApi? api})
      : _api = api ?? GetIt.instance<FuelEntryApi>(),
        super(FuelEntryViewInitial()) {
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
      await _api.delete(JsonRead.integer(JsonRead.field(event.item, 'id')), mobile: true);

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
  }) =>
      // the server also keeps a driver token to the driver's own entries
      _api.list(
        fromDate: fromDate,
        toDate: toDate,
        truckId: AppGlobals.DriverTruckRefId,
        driverId: AppGlobals.EmpRefId,
      );
}
