abstract class SalesOrderEvent {}

class LoadInvoiceByTypes extends SalesOrderEvent {
  final int type;
  LoadInvoiceByTypes(this.type);
}

class LoadMonthRanges extends SalesOrderEvent {
  final int months;
  LoadMonthRanges(this.months);
}

class LoadEmployeeInvDatas extends SalesOrderEvent {
  final int type;
  LoadEmployeeInvDatas(this.type);
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