import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/transport/bloc/transport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/transport/bloc/transport_state.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;


class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final BuildContext context;

  TransportBloc({required this.context}) : super(const TransportInitial()) {
    on<LoadTransportDataEvent>(_onLoadData);
    on<TapTransportItemEvent>(_onTapItem);
    on<LongPressTransportItemEvent>(_onLongPressItem);
  }

  // ── 1. Load Data ─────────────────────────────────────────────────────────────
  Future<void> _onLoadData(
      LoadTransportDataEvent event,
      Emitter<TransportState> emit,
      ) async {
    // Preserve isPlanToday if already loaded
    bool isPlanToday = event.type == 0;

    emit(const TransportLoadingState());

    try {
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: event.type));
      String fromDate = DateFormat('yyyy-MM-dd').format(newDate);
      String toDate   = DateFormat('yyyy-MM-dd').format(newDate);

      // type 0 = PLANINGSearchDB, type 1 = PLANINGSearch
      String url = event.type == 0
          ? objfun.PLANINGSearchDB
          : objfun.PLANINGSearch;

      final Map<String, dynamic> body = {
        'Comid':      objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate':   fromDate,
        'Todate':     toDate,
        'Search':     '',
        'Employeeid': null,
        'ETAType':    0,
      };

      final resultData = await objfun.apiAllinoneSelectArray(
          url, body, header, context);

      // No data → empty list, no error
      if (resultData == null ||
          resultData == "" ||
          (resultData is List && resultData.isEmpty)) {
        emit(TransportLoadedState(
          transportList: const [],
          isPlanToday:   isPlanToday,
        ));
        return;
      }

      // Has data
      final List<Map<String, dynamic>> list =
      List<Map<String, dynamic>>.from(resultData);

      emit(TransportLoadedState(
        transportList: list,
        isPlanToday:   isPlanToday,
      ));
    } catch (error, stackTrace) {
      emit(TransportErrorState(errorMessage: '$error\n$stackTrace'));
    }
  }

  // ── 2. Tap Item → UI handles dialog via listener ─────────────────────────────
  void _onTapItem(
      TapTransportItemEvent event,
      Emitter<TransportState> emit,
      ) {
    // Keep current list state — dialog is shown via BlocListener in UI
    // No state change needed; listener will detect this event via a dedicated state if needed
    // For simplicity: re-emit loaded state with same data (dialog opened in listener)
  }

  // ── 3. Long Press → fetch sale edit data, then navigate ──────────────────────
  Future<void> _onLongPressItem(
      LongPressTransportItemEvent event,
      Emitter<TransportState> emit,
      ) async {
    try {
      await OnlineApi.EditSalesOrder(context, event.id, 0);
      emit(const TransportNavigateToEditState());
    } catch (error, stackTrace) {
      emit(TransportErrorState(errorMessage: '$error\n$stackTrace'));
    }
  }
}