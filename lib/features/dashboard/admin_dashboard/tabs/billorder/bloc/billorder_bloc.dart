import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'billorder_event.dart';
import 'billorder_state.dart';

class BillOrderBloc extends Bloc<BillOrderEvent, BillOrderState> {
  final BuildContext context;

  BillOrderBloc(this.context) : super(BillOrderInitial()) {
    on<LoadBillOrderEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadBillOrderEvent event,
      Emitter<BillOrderState> emit,
      ) async {
    emit(BillOrderLoading());

    try {
      final int comid = objfun.storagenew.getInt('Comid') ?? 0;

      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final apiUrl =
          "${objfun.apiBillorderview}$comid"
          "&Fromdate=${event.fromDate}"
          "&Todate=${event.toDate}";

      final resultData = await objfun.apiAllinoneSelectArray(
        apiUrl, '', header, context,
      );

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty) {
        final List<BillViewModel> list = resultData
            .map((e) => BillViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(BillOrderLoaded(list));
      } else {
        emit(BillOrderLoaded([]));
      }
    } catch (error) {
      emit(BillOrderError(error.toString()));
    }
  }
}