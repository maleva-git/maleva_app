import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/forwardingreport_repository.dart';
import 'forwardingreport_event.dart';
import 'forwardingreport_state.dart';

class ForwardingReportBloc extends Bloc<ForwardingReportEvent, ForwardingReportState> {
  final ForwardingReportRepository _repository;

  ForwardingReportBloc({required ForwardingReportRepository repository})
      : _repository = repository,
        super(const ForwardingReportState()) {

    // droppable() stops users from spamming the load button / triggering multiple concurrent API calls
    on<LoadForwardingReportEvent>(_onLoadForwardingReport, transformer: droppable());
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
  }

  void _onSelectFromDate(SelectFromDateEvent event, Emitter<ForwardingReportState> emit) {
    emit(state.copyWith(fromDate: event.date, clearError: true));
    // If you want to auto-load data when date is selected, uncomment the line below:
    add(const LoadForwardingReportEvent(isDateSearch: true));
  }

  void _onSelectToDate(SelectToDateEvent event, Emitter<ForwardingReportState> emit) {
    emit(state.copyWith(toDate: event.date, clearError: true));
    // If you want to auto-load data when date is selected, uncomment the line below:
     add(const LoadForwardingReportEvent(isDateSearch: true));
  }

  Future<void> _onLoadForwardingReport(
      LoadForwardingReportEvent event,
      Emitter<ForwardingReportState> emit,
      ) async {
    emit(state.copyWith(status: ForwardingReportStatus.loading, clearError: true));

    String fromDateStr = '';
    String toDateStr = '';

    // Date formatting Logic
    if (event.isDateSearch && state.fromDate != null && state.toDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(state.fromDate!);
      toDateStr = DateFormat('yyyy-MM-dd').format(state.toDate!);
    } else {
      final now = DateTime.now();
      fromDateStr = DateFormat('yyyy-MM-dd').format(now);
      toDateStr = DateFormat('yyyy-MM-dd').format(now);

      // Update state with default dates if they are null
      if (state.fromDate == null || state.toDate == null) {
        emit(state.copyWith(fromDate: now, toDate: now));
      }
    }

    try {
      final result = await _repository.getForwardingReport(
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (result == null) {
        // Return loaded with empty lists if no data found
        emit(state.copyWith(status: ForwardingReportStatus.loaded));
        return;
      }

      emit(state.copyWith(
        status: ForwardingReportStatus.loaded,
        saleFWReport: result.data1,
        saleFWReport2: result.data2,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ForwardingReportStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}