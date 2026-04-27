// lib/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_event.dart

import 'package:equatable/equatable.dart';

sealed class ReceiptEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial load + date search — one event handles both
class LoadReceiptEvent extends ReceiptEvent {
  final bool isDateSearch;
   LoadReceiptEvent({this.isDateSearch = false});

  @override
  List<Object?> get props => [isDateSearch];
}

/// From date selected in view — no BuildContext in BLoC
class SelectFromDateEvent extends ReceiptEvent {
  final DateTime date;
   SelectFromDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// To date selected in view — no BuildContext in BLoC
class SelectToDateEvent extends ReceiptEvent {
  final DateTime date;
   SelectToDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}