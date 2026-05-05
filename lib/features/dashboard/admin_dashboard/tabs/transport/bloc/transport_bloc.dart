import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/transport_repository.dart';
import 'transport_event.dart';
import 'transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final TransportRepository repository; // ✅ Injected Repository

  TransportBloc({required this.repository}) : super(const TransportInitial()) {
    on<LoadTransportDataEvent>(_onLoadData);
    on<TapTransportItemEvent>(_onTapItem);
    on<LongPressTransportItemEvent>(_onLongPressItem);
  }

  // ── 1. Load Data ─────────────────────────────────────────────────────────────
  Future<void> _onLoadData(
      LoadTransportDataEvent event,
      Emitter<TransportState> emit,
      ) async {
    bool isPlanToday = event.type == 0;

    emit(const TransportLoadingState());

    try {
      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: event.type));
      String fromDate = DateFormat('yyyy-MM-dd').format(newDate);
      String toDate   = DateFormat('yyyy-MM-dd').format(newDate);

      final Map<String, dynamic> body = {
        'Comid':      objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate':   fromDate,
        'Todate':     toDate,
        'Search':     '',
        'Employeeid': null,
        'ETAType':    0,
      };

      // ✅ REFACTORED: Calling repo without context
      final resultData = await repository.fetchTransportData(
        type: event.type,
        body: body,
      );

      // No data → empty list, no error
      if (resultData == null || resultData == "" || (resultData is List && resultData.isEmpty)) {
        emit(TransportLoadedState(
          transportList: const [],
          isPlanToday:   isPlanToday,
        ));
        return;
      }

      // Has data
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(resultData);

      emit(TransportLoadedState(
        transportList: list,
        isPlanToday:   isPlanToday,
      ));
    } catch (error) {
      emit(TransportErrorState(errorMessage: error.toString()));
    }
  }

  // ── 2. Tap Item ─────────────────────────────
  void _onTapItem(
      TapTransportItemEvent event,
      Emitter<TransportState> emit,
      ) {
    // Keep current list state — dialog is shown via BlocListener in UI
  }

  // ── 3. Long Press ──────────────────────
  Future<void> _onLongPressItem(
      LongPressTransportItemEvent event,
      Emitter<TransportState> emit,
      ) async {
    // ✅ REFACTORED: The BLoC just emits the intent to navigate.
    // The UI listener will handle the context-heavy OnlineApi call.
    emit(TransportNavigateToEditState(id: event.id));
  }
}