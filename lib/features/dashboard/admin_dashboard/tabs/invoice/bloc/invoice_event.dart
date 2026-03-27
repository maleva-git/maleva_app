abstract class InvoiceEvent {}

class LoadInvoiceByType extends InvoiceEvent {
  final int type;
  LoadInvoiceByType(this.type);
}

class LoadMonthRange extends InvoiceEvent {
  final int months;
  LoadMonthRange(this.months);
}

class LoadWaitingBills extends InvoiceEvent {
  final int type;
  LoadWaitingBills(this.type);
}

class LoadEmployeeInvData extends InvoiceEvent {
  final int type;
  LoadEmployeeInvData(this.type);
}

// Manual refresh — tab-ல் pull to refresh பண்ணும்போது
class RefreshInvoice extends InvoiceEvent {}