

import 'package:equatable/equatable.dart';

abstract class SaleOrderEvent extends Equatable {
  const SaleOrderEvent();
  @override
  List<Object?> get props => [];
}

/// App boot — loads dropdowns then list data
class SaleOrderStartupRequested extends SaleOrderEvent {
  const SaleOrderStartupRequested();
}

/// Reload list with current filter values stored in state
class SaleOrderDataRequested extends SaleOrderEvent {
  const SaleOrderDataRequested();
}

/// Pull-to-refresh
class SaleOrderRefreshRequested extends SaleOrderEvent {
  const SaleOrderRefreshRequested();
}

/// Expand / collapse a card row
class SaleOrderCardToggled extends SaleOrderEvent {
  final int index;
  const SaleOrderCardToggled(this.index);
  @override
  List<Object?> get props => [index];
}

/// Individual row ETA checkbox toggled
class SaleOrderItemChecked extends SaleOrderEvent {
  final int index;
  final bool value;
  const SaleOrderItemChecked(this.index, this.value);
  @override
  List<Object?> get props => [index, value];
}

/// Filter: from-date changed
class SaleOrderFromDateChanged extends SaleOrderEvent {
  final String date; // yyyy-MM-dd
  const SaleOrderFromDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

/// Filter: to-date changed
class SaleOrderToDateChanged extends SaleOrderEvent {
  final String date;
  const SaleOrderToDateChanged(this.date);
  @override
  List<Object?> get props => [date];
}

/// Filter: customer selected / cleared
class SaleOrderCustomerChanged extends SaleOrderEvent {
  final int custId;
  final String custName;
  const SaleOrderCustomerChanged(this.custId, this.custName);
  @override
  List<Object?> get props => [custId, custName];
}

/// Filter: employee selected / cleared
class SaleOrderEmployeeChanged extends SaleOrderEvent {
  final int empId;
  final String empName;
  const SaleOrderEmployeeChanged(this.empId, this.empName);
  @override
  List<Object?> get props => [empId, empName];
}

/// Filter: job status selected / cleared
class SaleOrderStatusChanged extends SaleOrderEvent {
  final int statusId;
  final String statusName;
  const SaleOrderStatusChanged(this.statusId, this.statusName);
  @override
  List<Object?> get props => [statusId, statusName];
}

/// Filter: L.Emp checkbox toggled
class SaleOrderLEmpToggled extends SaleOrderEvent {
  final bool value;
  const SaleOrderLEmpToggled(this.value);
  @override
  List<Object?> get props => [value];
}

/// Filter: PickUp checkbox toggled
class SaleOrderPickUpToggled extends SaleOrderEvent {
  final bool value;
  const SaleOrderPickUpToggled(this.value);
  @override
  List<Object?> get props => [value];
}

/// Filter: cls radio changed (1=With / 2=WithOut / 3=All)
class SaleOrderClsChanged extends SaleOrderEvent {
  final String cls;
  const SaleOrderClsChanged(this.cls);
  @override
  List<Object?> get props => [cls];
}

/// Filter: ETA radio changed
class SaleOrderETARadioChanged extends SaleOrderEvent {
  final String etaVal;
  final String etaRadioVal;
  final bool etaEnabled;
  const SaleOrderETARadioChanged(this.etaVal, this.etaRadioVal, this.etaEnabled);
  @override
  List<Object?> get props => [etaVal, etaRadioVal, etaEnabled];
}

/// Filter: completestatusnotshow toggled
class SaleOrderCompleteStatusToggled extends SaleOrderEvent {
  final bool value;
  const SaleOrderCompleteStatusToggled(this.value);
  @override
  List<Object?> get props => [value];
}

/// ETA date-picker popup confirmed
class SaleOrderETADatesSet extends SaleOrderEvent {
  final DateTime? leta;
  final DateTime? letb;
  final DateTime? oeta;
  final DateTime? oetb;
  const SaleOrderETADatesSet({this.leta, this.letb, this.oeta, this.oetb});
  @override
  List<Object?> get props => [leta, letb, oeta, oetb];
}

/// Update button tapped — persist ETA dates to API
class SaleOrderUpdateRequested extends SaleOrderEvent {
  const SaleOrderUpdateRequested();
}

/// Free-text search fields changed
class SaleOrderSearchTextChanged extends SaleOrderEvent {
  final String? jobNo;
  final String? loadingVessel;
  final String? offVessel;
  const SaleOrderSearchTextChanged({this.jobNo, this.loadingVessel, this.offVessel});
  @override
  List<Object?> get props => [jobNo, loadingVessel, offVessel];
}