abstract class SalesOrderEvent {}

class LoadInvoiceByTypes extends SalesOrderEvent {
  final int type;

  /// Reload even when [type] is the tab already shown (pull-to-refresh).
  final bool force;
  LoadInvoiceByTypes(this.type, {this.force = false});
}

class LoadMonthRanges extends SalesOrderEvent {
  final int months;
  LoadMonthRanges(this.months);
}

class LoadEmployeeInvDatas extends SalesOrderEvent {
  final int type;
  LoadEmployeeInvDatas(this.type);
}

class LoadEmployeeSalesData extends SalesOrderEvent {
  final int type;
   LoadEmployeeSalesData(this.type);
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