import '../../../../../../core/models/model.dart';

abstract class PaymentPendingEvent {
  const PaymentPendingEvent();
}

// ── Initial Load ──────────────────────────────────────────────────────────────
class LoadPaymentPendingEvent extends PaymentPendingEvent {
  const LoadPaymentPendingEvent();
}

// ── Category Filter (Expense type) ────────────────────────────────────────────
class SelectExpenseFilterEvent extends PaymentPendingEvent {
  final String filter;
  const SelectExpenseFilterEvent(this.filter);
}

// ── Payment Filter (Paid / Not Paid) ─────────────────────────────────────────
class SelectPaidFilterEvent extends PaymentPendingEvent {
  final String filter;
  const SelectPaidFilterEvent(this.filter);
}
class SelectPaymentItemEvent extends PaymentPendingEvent {
  final PaymentPendingModel item;
  const SelectPaymentItemEvent(this.item);
}
// ── Date Filter ───────────────────────────────────────────────────────────────
class SelectFromDateEvent extends PaymentPendingEvent {
  final DateTime date;
  const SelectFromDateEvent(this.date);
}

class SelectToDateEvent extends PaymentPendingEvent {
  final DateTime date;
  const SelectToDateEvent(this.date);
}

class SearchByDateEvent extends PaymentPendingEvent {
  const SearchByDateEvent();
}