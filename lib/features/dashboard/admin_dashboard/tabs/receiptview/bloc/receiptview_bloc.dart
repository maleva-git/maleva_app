// lib/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_bloc.dart
//
// ── Changes from original ──────────────────────────────────────────────────────
//  BEFORE                              AFTER
//  objfun.Comid in master map          AppPreferences.getComid() via repository
//  pickDate(BuildContext context)      REMOVED — date picker now in view layer
//  No Equatable on state/events        sealed events + Equatable state
//  progress bool (inverted logic)      ReceiptStatus enum — clear and readable
//  No transformer on LoadReceipt       droppable() — no duplicate API calls
//  Direct ReportsApi call in BLoC      ReceiptRepository.getReceipts()

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_state.dart';
import '../data/receipt_repository.dart';


class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ReceiptRepository _receiptRepo;

  ReceiptBloc({required ReceiptRepository receiptRepo})
      : _receiptRepo = receiptRepo,
        super(const ReceiptState()) {
    // droppable: user taps search rapidly — only first fires, rest dropped
    on<LoadReceiptEvent>(_onLoadReceipt, transformer: droppable());

    // Date selection — instant local, no API
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
  }

  void _onSelectFromDate(SelectFromDateEvent event, Emitter<ReceiptState> emit) {
    emit(state.copyWith(fromDate: event.date, clearError: true));
  }

  void _onSelectToDate(SelectToDateEvent event, Emitter<ReceiptState> emit) {
    emit(state.copyWith(toDate: event.date, clearError: true));
  }

  Future<void> _onLoadReceipt(
      LoadReceiptEvent event,
      Emitter<ReceiptState> emit,
      ) async {
    emit(state.copyWith(status: ReceiptStatus.loading, clearError: true));

    // Date range logic — same as original
    final String fromDateStr;
    final String toDateStr;

    if (event.isDateSearch && state.fromDate != null && state.toDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(state.fromDate!);
      toDateStr   = DateFormat('yyyy-MM-dd').format(state.toDate!);
    } else {
      final now     = DateTime.now();
      final before  = now.subtract(const Duration(days: 900));
      fromDateStr   = DateFormat('yyyy-MM-dd').format(before);
      toDateStr     = DateFormat('yyyy-MM-dd').format(now);
    }

    try {
      final result = await _receiptRepo.getReceipts(
        fromDate: fromDateStr,
        toDate:   toDateStr,
      );

      if (result == null) {
        // No data — show loaded with empty list (not error)
        emit(state.copyWith(status: ReceiptStatus.loaded));
        return;
      }

      final masterList  = List<Map<String, dynamic>>.from(result.masterList);
      final detailList  = List<Map<String, dynamic>>.from(result.detailList);

      // Totals — same calculation as original
      double totalAmount  = 0;
      double totalBalance = 0;
      for (final item in masterList) {
        totalAmount  += double.tryParse(item['BillAmount'].toString()) ?? 0;
        totalBalance += double.tryParse(item['Balance'].toString())    ?? 0;
      }

      emit(state.copyWith(
        status:         ReceiptStatus.loaded,
        receiptMaster:  masterList,
        receiptDetails: detailList,
        totalAmount:    double.parse(totalAmount.toStringAsFixed(2)),
        totalBalance:   double.parse(totalBalance.toStringAsFixed(2)),
      ));
    } catch (e) {
      emit(state.copyWith(
        status:       ReceiptStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}