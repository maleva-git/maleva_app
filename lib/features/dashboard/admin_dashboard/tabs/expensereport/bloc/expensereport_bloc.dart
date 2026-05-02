import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/expensereport_repository.dart';
import 'expensereport_event.dart';
import 'expensereport_state.dart';

class ExpenseReportBloc extends Bloc<ExpenseReportEvent, ExpenseReportState> {
  final ExpenseReportRepository _repository;

  ExpenseReportBloc({required ExpenseReportRepository repository})
      : _repository = repository,
        super(const ExpenseReportState()) {

    // droppable() stops users from spamming the load button / triggering multiple concurrent API calls
    on<LoadExpenseReportEvent>(_onLoadExpenseReport, transformer: droppable());
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
  }

  void _onSelectFromDate(SelectFromDateEvent event, Emitter<ExpenseReportState> emit) {
    emit(state.copyWith(fromDate: event.date, clearError: true));
    // Automatically trigger fetch when date changes
    add(const LoadExpenseReportEvent(isDateSearch: true));
  }

  void _onSelectToDate(SelectToDateEvent event, Emitter<ExpenseReportState> emit) {
    emit(state.copyWith(toDate: event.date, clearError: true));
    // Automatically trigger fetch when date changes
    add(const LoadExpenseReportEvent(isDateSearch: true));
  }

  Future<void> _onLoadExpenseReport(
      LoadExpenseReportEvent event,
      Emitter<ExpenseReportState> emit,
      ) async {
    emit(state.copyWith(status: ExpenseReportStatus.loading, clearError: true));

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
      final result = await _repository.getExpenseReport(
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (result == null) {
        // Return loaded with empty lists if no data found
        emit(state.copyWith(status: ExpenseReportStatus.loaded));
        return;
      }

      emit(state.copyWith(
        status: ExpenseReportStatus.loaded,
        saleExpReport: result.data1,
        saleExpReport2: result.data2,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseReportStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}