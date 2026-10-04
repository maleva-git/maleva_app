import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/utils/app_globals.dart';

import 'fuelentry_event.dart';
import 'fuelentry_state.dart';

/// The driver's fuel entry form, on the shared Java `/api/fuel-entries`
/// (change `fuel-entry-on-shared-java-api`).
class FuelEntryBloc extends Bloc<FuelEntryEvent, FuelEntryState> {
  final FuelEntryApi _api;

  FuelEntryBloc({FuelEntryApi? api})
      : _api = api ?? GetIt.instance<FuelEntryApi>(),
        super(FuelEntryInitial()) {
    on<FuelEntryStarted>(_onStarted);
    on<FuelEntryDateChanged>(_onDateChanged);
    on<FuelEntryLiterChanged>(_onLiterChanged);
    on<FuelEntryAmountChanged>(_onAmountChanged);
    on<FuelEntryRemarksChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(remarks: event.value)); });
    on<FuelEntryPLiterChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(pLiter: event.value)); });
    on<FuelEntryPRateChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(pRate: event.value)); });
    on<FuelEntryPAmountChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(pAmount: event.value)); });
    on<FuelEntryGLiterChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(gLiter: event.value)); });
    on<FuelEntryGAmountChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(gAmount: event.value)); });
    on<FuelEntryDPLiterChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(dpLiter: event.value)); });
    on<FuelEntryDPAmountChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(dpAmount: event.value)); });
    on<FuelEntryDGLiterChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(dgLiter: event.value)); });
    on<FuelEntryDGAmountChanged>((event, emit) { if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(dgAmount: event.value)); });
    on<FuelEntrySaveRequested>(_onSaveRequested);
  }

  // ── Load max fuel no ─────────────────────────────────────────────────────────
  Future<void> _onStarted(
      FuelEntryStarted event,
      Emitter<FuelEntryState> emit) async {
    emit(FuelEntryLoading());
    try {
      final fuelNo = await _fetchMaxFuelNo();
      emit(FuelEntryLoaded.empty(fuelNo: fuelNo));
    } catch (e) {
      emit(FuelEntryError(e.toString()));
    }
  }

  // ── Date ─────────────────────────────────────────────────────────────────────
  void _onDateChanged(
      FuelEntryDateChanged event,
      Emitter<FuelEntryState> emit) {
    if (state is FuelEntryLoaded) {
      emit((state as FuelEntryLoaded).copyWith(date: event.date));
    }
  }

  // ── Liter ────────────────────────────────────────────────────────────────────
  void _onLiterChanged(
      FuelEntryLiterChanged event,
      Emitter<FuelEntryState> emit) {
    if (state is FuelEntryLoaded) {
      emit((state as FuelEntryLoaded).copyWith(liter: event.value));
    }
  }

  // ── Amount ────────────────────────────────────────────────────────────────────
  void _onAmountChanged(
      FuelEntryAmountChanged event,
      Emitter<FuelEntryState> emit) {
    if (state is FuelEntryLoaded) {
      emit((state as FuelEntryLoaded).copyWith(amount: event.value));
    }
  }
  // ── Save ──────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      FuelEntrySaveRequested event,
      Emitter<FuelEntryState> emit) async {
    if (state is! FuelEntryLoaded) return;
    final s = state as FuelEntryLoaded;

    // 🚨 Prevent saving if no truck is assigned
    if (AppGlobals.DriverTruckRefId == 0) {
      emit(FuelEntryError("No Truck Assigned! Please select or assign a truck first."));
      emit(s);
      return;
    }

    emit(FuelEntryLoading());
    try {
      // the server stamps a driver's own truck, driver and app flag on the row
      await _api.save({
        'id': 0,
        'truckRefId': AppGlobals.DriverTruckRefId,
        'driverRefId': AppGlobals.EmpRefId == 0 ? null : AppGlobals.EmpRefId,
        'saleDate': s.date,
        'aliter': double.tryParse(s.liter.replaceAll(',', '.')) ?? 0,
        'aAmount': double.tryParse(s.amount.replaceAll(',', '.')) ?? 0,
        'pliter': 0,
        'gliter': 0,
        'pRate': 0,
        'remarks': '',
        'filePath': '',
        'fStatus': 1,
      });
      final newFuelNo = await _fetchMaxFuelNo();
      emit(FuelEntrySaveSuccess());
      emit(FuelEntryLoaded.empty(fuelNo: newFuelNo));
    } catch (e) {
      emit(FuelEntryError(e.toString()));
      emit(s);
    }
  }
  // ── Helper: fetch max fuel no ─────────────────────────────────────────────────
  Future<String> _fetchMaxFuelNo() async {
    try {
      return await _api.nextNumber();
    } catch (_) {
      return '';
    }
  }
}
