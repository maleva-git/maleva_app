import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/fuel/fuel_vehicle.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import 'fuel_entry_validation.dart';
import 'fuelentry_event.dart';
import 'fuelentry_state.dart';

/// The fuel entry form, on the shared Java `/api/fuel-entries`
/// (change `fuel-entry-on-shared-java-api`). A driver fills the truck on their
/// record; an employee (boarding officer or anyone with a company vehicle)
/// picks one of the vehicles the office gave them (change `employee-fuel-vehicles`).
class FuelEntryBloc extends Bloc<FuelEntryEvent, FuelEntryState> {
  final FuelEntryApi _api;
  final bool Function() _isDriver;

  FuelEntryBloc({FuelEntryApi? api, bool Function()? isDriver})
      : _api = api ?? GetIt.instance<FuelEntryApi>(),
        _isDriver = isDriver ?? (() => AppPreferences.getDriverId() == 1),
        super(FuelEntryInitial()) {
    on<FuelEntryVehicleChanged>((event, emit) {
      if (state is FuelEntryLoaded) emit((state as FuelEntryLoaded).copyWith(truckRefId: event.truckRefId));
    });
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
      final driver = _isDriver();
      final vehicles = driver ? const <FuelVehicle>[] : await _api.myVehicles();
      emit(FuelEntryLoaded.empty(
        fuelNo: fuelNo,
        isDriver: driver,
        vehicles: vehicles,
        // one vehicle needs no picking
        truckRefId: vehicles.length == 1 ? vehicles.single.truckRefId : 0,
      ));
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

    // A driver needs the truck on their record; an employee needs a picked vehicle.
    final truckRefId = s.isDriver ? AppGlobals.DriverTruckRefId : s.truckRefId;
    if (truckRefId == 0) {
      emit(FuelEntryError(s.isDriver
          ? "No Truck Assigned! Please select or assign a truck first."
          : s.vehicles.isEmpty
              ? "No vehicle is given to you for fuel entry. Ask the office to add it."
              : "Select the vehicle you filled."));
      emit(s);
      return;
    }

    final problem = FuelEntryValidation.form(liter: s.liter, amount: s.amount);
    if (problem != null) {
      emit(FuelEntryError(problem));
      emit(s);
      return;
    }

    emit(FuelEntryLoading());
    try {
      // the server stamps a driver's own truck, driver and app flag on the row,
      // and checks an employee's vehicle against their list
      await _api.save({
        'id': 0,
        'truckRefId': truckRefId,
        'driverRefId': s.isDriver && AppGlobals.EmpRefId != 0 ? AppGlobals.EmpRefId : null,
        'saleDate': s.date,
        'aliter': FuelEntryValidation.parse(s.liter),
        'aAmount': FuelEntryValidation.parse(s.amount),
        'pliter': 0,
        'gliter': 0,
        'pRate': 0,
        'remarks': '',
        'filePath': '',
        'fStatus': 1,
      });
      final newFuelNo = await _fetchMaxFuelNo();
      emit(FuelEntrySaveSuccess());
      emit(FuelEntryLoaded.empty(
        fuelNo: newFuelNo,
        isDriver: s.isDriver,
        vehicles: s.vehicles,
        truckRefId: s.truckRefId,
      ));
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
