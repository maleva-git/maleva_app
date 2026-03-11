import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/pettycash/bloc/pettycash_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/pettycash/bloc/pettycash_state.dart';



class PettyCashBloc extends Bloc<PettyCashEvent, PettyCashState> {
  final BuildContext context;

  PettyCashBloc(this.context)
      : super(PettyCashInitial(
    fromDate: DateTime.now(),
    toDate: DateTime.now(),
  )) {
    on<SelectFromDateEvent>(_onFromDate);
    on<SelectToDateEvent>(_onToDate);
    on<LoadPettyCashEvent>(_onLoad);
  }

  // ── From Date ───────────────────────────────────────────────────────────────
  void _onFromDate(SelectFromDateEvent event, Emitter<PettyCashState> emit) {
    final toDate = _currentToDate();
    emit(PettyCashInitial(fromDate: event.date, toDate: toDate));
  }

  // ── To Date ─────────────────────────────────────────────────────────────────
  void _onToDate(SelectToDateEvent event, Emitter<PettyCashState> emit) {
    final fromDate = _currentFromDate();
    emit(PettyCashInitial(fromDate: fromDate, toDate: event.date));
  }

  // ── Load Petty Cash ─────────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadPettyCashEvent event,
      Emitter<PettyCashState> emit,
      ) async {
    final fromDate = _currentFromDate();
    final toDate = _currentToDate();

    emit(PettyCashLoading(fromDate: fromDate, toDate: toDate));

    try {
      final String fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
      final String toStr = DateFormat('yyyy-MM-dd').format(toDate);

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiGetpettycash}${objfun.Comid}"
            "&Fromdate=$fromStr"
            "&Todate=$toStr"
            "&Employeeid=0&Search=&PaymentStatus=&PaymentTo",
        null,
        header,
        context,
      );

      List<PattycashMasterModel> masters = [];
      List<PattyCashDetailsModel> details = [];

      if (resultData != null && resultData.isNotEmpty) {
        final data = resultData[0];
        if (data != null) {
          if (data['PattycashMasterModel'] != null) {
            masters = (data['PattycashMasterModel'] as List)
                .map((e) => PattycashMasterModel.fromJson(e))
                .toList();
          }
          if (data['PattyCashDetailsModel'] != null) {
            details = (data['PattyCashDetailsModel'] as List)
                .map((e) => PattyCashDetailsModel.fromJson(e))
                .toList();
          }
        }
      }

      emit(PettyCashLoaded(
        masterRecords: masters,
        detailRecords: details,
        fromDate: fromDate,
        toDate: toDate,
      ));
    } catch (e) {
      emit(PettyCashError(
        message: e.toString(),
        fromDate: fromDate,
        toDate: toDate,
      ));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  DateTime _currentFromDate() {
    final s = state;
    if (s is PettyCashInitial) return s.fromDate;
    if (s is PettyCashLoading) return s.fromDate;
    if (s is PettyCashLoaded) return s.fromDate;
    if (s is PettyCashError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _currentToDate() {
    final s = state;
    if (s is PettyCashInitial) return s.toDate;
    if (s is PettyCashLoading) return s.toDate;
    if (s is PettyCashLoaded) return s.toDate;
    if (s is PettyCashError) return s.toDate;
    return DateTime.now();
  }
}