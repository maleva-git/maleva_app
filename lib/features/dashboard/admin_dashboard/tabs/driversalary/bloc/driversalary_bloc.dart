import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'driversalary_event.dart';
import 'driversalary_state.dart';



class DriverSalaryBloc
    extends Bloc<DriverSalaryEvent, DriverSalaryState> {
  DriverSalaryBloc() : super(DriverSalaryInitial()) {
    on<DriverSalaryStarted>(_onStarted);
    on<DriverSalaryFromDateChanged>(_onFromDateChanged);
    on<DriverSalaryToDateChanged>(_onToDateChanged);
    on<DriverSalaryDetailRequested>(_onDetailRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      DriverSalaryStarted event,
      Emitter<DriverSalaryState> emit) async {
    emit(DriverSalaryLoading());
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final result = await _fetchSalary(
          fromDate: today, toDate: today);
      emit(result);
    } catch (e) {
      emit(DriverSalaryError(e.toString()));
    }
  }

  // ── From date changed — auto reload ─────────────────────────────────────────
  Future<void> _onFromDateChanged(
      DriverSalaryFromDateChanged event,
      Emitter<DriverSalaryState> emit) async {
    if (state is! DriverSalaryLoaded) return;
    final s = state as DriverSalaryLoaded;

    emit(DriverSalaryLoading());
    try {
      final result = await _fetchSalary(
          fromDate: event.date, toDate: s.toDate);
      emit(result);
    } catch (e) {
      emit(DriverSalaryError(e.toString()));
    }
  }

  // ── To date changed — auto reload ────────────────────────────────────────────
  Future<void> _onToDateChanged(
      DriverSalaryToDateChanged event,
      Emitter<DriverSalaryState> emit) async {
    if (state is! DriverSalaryLoaded) return;
    final s = state as DriverSalaryLoaded;

    emit(DriverSalaryLoading());
    try {
      final result = await _fetchSalary(
          fromDate: s.fromDate, toDate: event.date);
      emit(result);
    } catch (e) {
      emit(DriverSalaryError(e.toString()));
    }
  }

  // ── Show detail dialog ────────────────────────────────────────────────────────
  void _onDetailRequested(
      DriverSalaryDetailRequested event,
      Emitter<DriverSalaryState> emit) {
    emit(DriverSalaryShowDetail(event.item));
    // Restore loaded state so UI doesn't blank out
    if (state is DriverSalaryLoaded) {
      emit(state as DriverSalaryLoaded);
    }
  }

  // ── API fetch helper ──────────────────────────────────────────────────────────
  Future<DriverSalaryLoaded> _fetchSalary({
    required String fromDate,
    required String toDate,
  }) async {
    final master = {
      'Comid':      objfun.Comid,
      'DriverId':   objfun.EmpRefId,
      'TruckId':    0,
      'FromDate':   fromDate,
      'ToDate':     toDate,
      'DriverName': '',
      'TruckName':  '',
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final resultData = await objfun.apiAllinoneSelectArrayWithOutAuth(
        objfun.apiSelectDriverSalary, master, header, null);

    List<dynamic> salaryList   = [];
    double        salaryAmount = 0.0;

    if (resultData != '') {
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true &&
          value.data1 != null &&
          value.data1.length != 0) {
        salaryList = List<dynamic>.from(value.data1 as List);
        for (final item in salaryList) {
          salaryAmount += (item['Amount'] as num?)?.toDouble() ?? 0.0;
        }
      }
    }

    return DriverSalaryLoaded(
      fromDate:     fromDate,
      toDate:       toDate,
      salaryList:   salaryList,
      salaryAmount: salaryAmount,
    );
  }
}