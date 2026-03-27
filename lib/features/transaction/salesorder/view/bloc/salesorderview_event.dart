abstract class SalesOrderViewEvent {}

class StartupSalesOrderView extends SalesOrderViewEvent {}

class LoadSalesOrderView extends SalesOrderViewEvent {}

class ExpandRow extends SalesOrderViewEvent {
  final int index;
  ExpandRow(this.index);
}

class CollapseRow extends SalesOrderViewEvent {}

// Filter updates
class ViewUpdateFromDate extends SalesOrderViewEvent {
  final String date;
  ViewUpdateFromDate(this.date);
}

class ViewUpdateToDate extends SalesOrderViewEvent {
  final String date;
  ViewUpdateToDate(this.date);
}

class ViewCustomerSelected extends SalesOrderViewEvent {
  final String name;
  final int id;
  ViewCustomerSelected(this.name, this.id);
}

class ViewCustomerCleared extends SalesOrderViewEvent {}

class ViewEmployeeSelected extends SalesOrderViewEvent {
  final String name;
  final int id;
  ViewEmployeeSelected(this.name, this.id);
}

class ViewEmployeeCleared extends SalesOrderViewEvent {}

class ViewStatusSelected extends SalesOrderViewEvent {
  final String name;
  final int id;
  ViewStatusSelected(this.name, this.id);
}

class ViewStatusCleared extends SalesOrderViewEvent {}

class ViewUpdateTextField extends SalesOrderViewEvent {
  final String field;
  final String value;
  ViewUpdateTextField(this.field, this.value);
}

class ViewUpdateCheckbox extends SalesOrderViewEvent {
  final String field;
  final bool value;
  ViewUpdateCheckbox(this.field, this.value);
}

class ViewUpdateRadio extends SalesOrderViewEvent {
  final String etaVal;
  final String etaRadioVal;
  final bool checkBoxValueETA;
  ViewUpdateRadio(this.etaVal, this.etaRadioVal, this.checkBoxValueETA);
}

class ViewUpdateCls extends SalesOrderViewEvent {
  final String cls;
  ViewUpdateCls(this.cls);
}

class ShareDO extends SalesOrderViewEvent {
  final int id;
  final int billNo;
  ShareDO(this.id, this.billNo);
}