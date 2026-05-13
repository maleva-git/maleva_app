import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../../../../../../core/models/model.dart'; // library prefix

part 'salary_event.dart';
part 'salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  // No objfun instance needed — accessed directly via the library prefix.
  final BuildContext context;

  SalaryBloc({required this.context}) : super(SalaryState(
    fromDate: DateFormat("yyyy-MM-dd")
        .format(DateTime(DateTime.now().year, DateTime.now().month, 1)),
    toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
  )) {
    on<SalaryInitialLoad>(_onInitialLoad);
    on<LoadSalaryData>(_onLoadSalaryData);
    on<UpdateFromDate>(_onUpdateFromDate);
    on<UpdateToDate>(_onUpdateToDate);
  }

  // ─────────────────────────────────────────────────────────
  // Initial load — uses the default date range in state
  // ─────────────────────────────────────────────────────────
  Future<void> _onInitialLoad(
      SalaryInitialLoad event,
      Emitter<SalaryState> emit,
      ) async {
    add(LoadSalaryData(fromDate: state.fromDate, toDate: state.toDate));
  }

  // ─────────────────────────────────────────────────────────
  // Fetch salary list from API
  // ─────────────────────────────────────────────────────────
  Future<void> _onLoadSalaryData(
      LoadSalaryData event,
      Emitter<SalaryState> emit,
      ) async {
    emit(state.copyWith(
      status: SalaryStatus.loading,
      fromDate: event.fromDate,
      toDate: event.toDate,
    ));

    try {
      final Map<String, dynamic> master = {
        'Comid': objfun.Comid,
        'Employeeid': objfun.EmpRefId,
        'FromDate': event.fromDate,
        'ToDate': event.toDate,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArrayWithOutAuth(
        objfun.apiSelectBoardingSalary,
        master,
        headers,
        context,
      );

      if (resultData != "") {
        final ResponseViewModel value = ResponseViewModel.fromJson(resultData);

        if (value.IsSuccess == true &&
            value.data1 != null &&
            (value.data1 as List).isNotEmpty) {
          final List<Map<String, dynamic>> list =
          (value.data1 as List).cast<Map<String, dynamic>>();

          final double total = list.fold(
            0.0,
                (sum, item) => sum + (item["NetAmt"] as num).toDouble(),
          );

          emit(state.copyWith(
            status: SalaryStatus.success,
            salaryList: list,
            salaryAmount: total,
          ));
        } else {
          emit(state.copyWith(
            status: SalaryStatus.success,
            salaryList: [],
            salaryAmount: 0.0,
          ));
        }
      } else {
        emit(state.copyWith(
          status: SalaryStatus.success,
          salaryList: [],
          salaryAmount: 0.0,
        ));
      }
    } catch (e, st) {
      _handleError(e, st);
      emit(state.copyWith(
        status: SalaryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─────────────────────────────────────────────────────────
  // Date picker — from-date changed → update state & reload
  // ─────────────────────────────────────────────────────────
  Future<void> _onUpdateFromDate(
      UpdateFromDate event,
      Emitter<SalaryState> emit,
      ) async {
    // Update date in state first, then trigger fetch
    emit(state.copyWith(fromDate: event.fromDate));
    add(LoadSalaryData(fromDate: event.fromDate, toDate: state.toDate));
  }

  // ─────────────────────────────────────────────────────────
  // Date picker — to-date changed → update state & reload
  // ─────────────────────────────────────────────────────────
  Future<void> _onUpdateToDate(
      UpdateToDate event,
      Emitter<SalaryState> emit,
      ) async {
    emit(state.copyWith(toDate: event.toDate));
    add(LoadSalaryData(fromDate: state.fromDate, toDate: event.toDate));
  }

  // ─────────────────────────────────────────────────────────
  // Error handler — delegates to your existing msgshow helper
  // ─────────────────────────────────────────────────────────
  void _handleError(Object e, StackTrace st) {
    objfun.msgshow(
      e.toString(),
      st.toString(),
      const Color(0xFFFFFFFF),
      const Color(0xFFE53935),
      null,
      18.00 - objfun.reducesize,
      objfun.tll,
      objfun.tgc,
      context,
      2,
    );
  }
}