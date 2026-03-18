abstract class SalesOrderEvent {}

class LoadInvoiceByType extends SalesOrderEvent {
  final int type;
  LoadInvoiceByType(this.type);
}

class LoadMonthRange extends SalesOrderEvent {
  final int months;
  LoadMonthRange(this.months);
}

class LoadEmployeeInvData extends SalesOrderEvent {
  final int type;
  LoadEmployeeInvData(this.type);
}

class LoadWaitingBills extends SalesOrderEvent {
  final int type;
  LoadWaitingBills(this.type);
}

class ShowWaitingBilling extends SalesOrderEvent {}

class TabChanged extends SalesOrderEvent {
  final int index;
  TabChanged(this.index);
}

class RefreshSalesOrder extends SalesOrderEvent {}