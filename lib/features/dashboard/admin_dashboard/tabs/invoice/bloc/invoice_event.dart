// lib/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_event.dart

import 'package:equatable/equatable.dart';

sealed class InvoiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial load — called from initState
/// type 0 = all, 1–N = specific sales type
class LoadInvoiceByType extends InvoiceEvent {
  final int type;
   LoadInvoiceByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Toggle 6M / 12M — local only, no API call
class LoadMonthRange extends InvoiceEvent {
  final int months; // 6 or 12
   LoadMonthRange(this.months);

  @override
  List<Object?> get props => [months];
}

/// Waiting bills sheet — load if empty, show if cached
class LoadWaitingBills extends InvoiceEvent {
   LoadWaitingBills();
}

/// Employee breakdown — API call per month index
class LoadEmployeeInvData extends InvoiceEvent {
  final int type;
   LoadEmployeeInvData(this.type);

  @override
  List<Object?> get props => [type];
}

/// Pull-to-refresh — keeps existing data visible while reloading
class RefreshInvoice extends InvoiceEvent {
   RefreshInvoice();
}

/// Dismiss waiting sheet without clearing data
class DismissWaitingSheet extends InvoiceEvent {
   DismissWaitingSheet();
}