import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;


import 'bocheck_event.dart';
import 'bocheck_state.dart';

class BocBloc extends Bloc<BocEvent, BocState> {
  final BuildContext context;

  BocBloc(this.context) : super(BocInitial()) {
    on<LoadBocReport>(_onLoadBocReport);
  }

  Future<void> _onLoadBocReport(
      LoadBocReport event,
      Emitter<BocState> emit,
      ) async {
    emit(BocLoading());

    try {
      final Map<String, dynamic> requestBody = {
        "Comid": objfun.Comid,
        "Fromdate": "",
        "Todate": "",
        "Id": 0,
        "Employeeid": 0,
        "Search": event.searchValue,
        "Remarks": 0,
        "status": "",
        "TId": 0,
        "DId": 0,
        "Offvesselname": "",
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiselectBillordercheck,
        requestBody,
        headers,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final data1 = resultData['Data1'] as List?;

        if (data1 != null && data1.isNotEmpty) {
          final List<BoDetailResponse> records = data1
              .map((e) => BoDetailResponse.fromJson(e))
              .toList()
              .cast<BoDetailResponse>();
          emit(BocLoaded(records));
        } else {
          emit(BocEmpty());
        }
      } else {
        emit(BocEmpty());
      }
    } catch (error) {
      emit(BocError(error.toString()));
    }
  }
}