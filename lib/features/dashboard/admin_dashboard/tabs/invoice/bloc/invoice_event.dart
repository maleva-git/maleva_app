abstract class InvoiceEvent {}

class LoadInvoiceByType extends InvoiceEvent {
  final int type;
  LoadInvoiceByType(this.type);
}

class LoadMonthRange extends InvoiceEvent {
  final int months; // 6 or 12
  LoadMonthRange(this.months);
}
class LoadEmployeeInvData extends InvoiceEvent {
  final int type;
  LoadEmployeeInvData(this.type);
}
class LoadWaitingBills extends InvoiceEvent {
  final int type;
  LoadWaitingBills(this.type);
}

class ShowWaitingBilling extends InvoiceEvent {}
