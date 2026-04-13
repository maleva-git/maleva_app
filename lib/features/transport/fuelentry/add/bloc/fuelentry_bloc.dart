import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'fuelentry_event.dart';
import 'fuelentry_state.dart';




class FuelEntryBloc extends Bloc<FuelEntryEvent, FuelEntryState> {
  FuelEntryBloc() : super(FuelEntryInitial()) {
    on<FuelEntryStarted>(_onStarted);
    on<FuelEntryDateChanged>(_onDateChanged);
    on<FuelEntryLiterChanged>(_onLiterChanged);
    on<FuelEntryAmountChanged>(_onAmountChanged);
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

    emit(FuelEntryLoading());
    try {
      final master = [
        {
          'SaleDate':       DateTime.parse(s.date).toIso8601String(),
          'CNumberDisplay': '0',
          'CNumber':        0,
          'Id':             0,
          'CompanyRefId':   objfun.Comid,
          'UserRefId':      null,
          'EmployeeRefId':  null,
          'TruckRefid':     objfun.DriverTruckRefId,
          'DriverRefId':    objfun.EmpRefId,
          'FilePath':       '',
          'Remarks':        '',
          'Aliter':         s.liter,
          'AAmount':        s.amount,
          'Pliter':         0,
          'PRate':          0,
          'PAmount':        0,
          'Gliter':         0,
          'GAmount':        0,
          'DPliter':        0,
          'DPAmount':       0,
          'DGliter':        0,
          'DGAmount':       0,
          'FStatus':        1,
        }
      ];

      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': objfun.Comid.toString(),
      };

      final result = await objfun.apiAllinoneSelectArray(
          objfun.apiInsertFuelEntry, master, header, null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          // Reload with new fuelNo
          final newFuelNo = await _fetchMaxFuelNo();
          emit(FuelEntrySaveSuccess());
          emit(FuelEntryLoaded.empty(fuelNo: newFuelNo));
          return;
        }
      }
      // revert on failure
      emit(s);
    } catch (e) {
      emit(FuelEntryError(e.toString()));
    }
  }

  // ── Helper: fetch max fuel no ─────────────────────────────────────────────────
  Future<String> _fetchMaxFuelNo() async {
    try {
      final comId = objfun.storagenew.getInt('Comid') ?? 0;
      final result = await objfun.apiGetString(
          '${objfun.apiMaxFuelEntryNo}$comId');
      return result.isNotEmpty ? result : '';
    } catch (_) {
      return '';
    }
  }
}