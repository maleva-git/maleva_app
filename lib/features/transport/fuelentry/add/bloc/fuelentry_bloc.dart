import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import 'fuelentry_event.dart';
import 'fuelentry_state.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';

class FuelEntryBloc extends Bloc<FuelEntryEvent, FuelEntryState> {
  FuelEntryBloc() : super(FuelEntryInitial()) {
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
      final master = [
        {
          'SaleDate':       DateTime.parse(s.date).toIso8601String(),
          'CNumberDisplay': '',
          'CNumber':        0,
          'Id':             0,
          'CompanyRefId':   AppGlobals.Comid,
          'UserRefId':      0,
          'EmployeeRefId':  0,
          'TruckRefid':     AppGlobals.DriverTruckRefId,
          'DriverRefId':    AppGlobals.EmpRefId,
          'FilePath':       '',
          'Remarks':        '',
          'Aliter':         double.tryParse(s.liter.replaceAll(',', '.')) ?? 0,
          'AAmount':        double.tryParse(s.amount.replaceAll(',', '.')) ?? 0,
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
        'Comid': AppGlobals.Comid.toString(),
      };

      final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
          ApiConstants.apiInsertFuelEntry, master, header, null);

      if (resultData != null && resultData.toString().isNotEmpty) {
        try {
          Map<String, dynamic> responseMap = {};

          if (resultData is List) {
            if (resultData.isNotEmpty && resultData.first is Map) {
              responseMap = Map<String, dynamic>.from(resultData.first);
            }
          } else if (resultData is Map) {
            responseMap = Map<String, dynamic>.from(resultData);
          } else if (resultData is String) {
            var decoded = jsonDecode(resultData);
            if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
              responseMap = Map<String, dynamic>.from(decoded.first);
            } else if (decoded is Map) {
              responseMap = Map<String, dynamic>.from(decoded);
            }
          }

          final value = ResponseViewModel.fromJson(responseMap);
          if (value.IsSuccess == true) {
            final newFuelNo = await _fetchMaxFuelNo();
            emit(FuelEntrySaveSuccess());
            emit(FuelEntryLoaded.empty(fuelNo: newFuelNo));
          } else {
            emit(FuelEntryError(value.Message ?? "Save Failed. Backend rejected the data format."));
            emit(s);
          }
        } catch (jsonErr) {
          emit(FuelEntryError('Data Parse Error: ${jsonErr.toString()}'));
          emit(s);
        }
      } else {
        emit(s);
      }
    } catch (e) {
      emit(FuelEntryError(e.toString()));
      emit(s);
    }
  }
  // ── Helper: fetch max fuel no ─────────────────────────────────────────────────
  Future<String> _fetchMaxFuelNo() async {
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final result = await sl<LegacyApiRepository>().apiGetString('');
      return result.isNotEmpty ? result : '';
    } catch (_) {
      return '';
    }
  }
}