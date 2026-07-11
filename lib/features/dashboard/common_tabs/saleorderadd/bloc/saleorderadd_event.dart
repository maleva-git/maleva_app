

import 'package:equatable/equatable.dart';

import '../../../../../core/models/model.dart';

abstract class SalesOrderEvent extends Equatable {
  const SalesOrderEvent();

  @override
  List<Object?> get props => [];
}

// ─── Initialization ───────────────────────────────────────────────────────────

class SalesOrderInitialized extends SalesOrderEvent {
  final List<SaleEditDetailModel>? saleDetails;
  final List<dynamic>? saleMaster;
  const SalesOrderInitialized({this.saleDetails, this.saleMaster});

  @override
  List<Object?> get props => [saleDetails, saleMaster];
}

// ─── Tab ─────────────────────────────────────────────────────────────────────

class SalesOrderTabChanged extends SalesOrderEvent {
  final int index;
  const SalesOrderTabChanged({required this.index});

  @override
  List<Object?> get props => [index];
}

// ─── Bill Type ────────────────────────────────────────────────────────────────

class SalesOrderBillTypeChanged extends SalesOrderEvent {
  final String value;
  const SalesOrderBillTypeChanged({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── Customer ─────────────────────────────────────────────────────────────────

class SalesOrderCustomerSelected extends SalesOrderEvent {
  final int custId;
  final String custName;
  const SalesOrderCustomerSelected({required this.custId, required this.custName});

  @override
  List<Object?> get props => [custId, custName];
}

class SalesOrderCustomerCleared extends SalesOrderEvent {
  const SalesOrderCustomerCleared();
}

// ─── Job Type ─────────────────────────────────────────────────────────────────

class SalesOrderJobTypeSelected extends SalesOrderEvent {
  final int jobTypeId;
  final String jobTypeName;
  const SalesOrderJobTypeSelected({required this.jobTypeId, required this.jobTypeName});

  @override
  List<Object?> get props => [jobTypeId, jobTypeName];
}

class SalesOrderJobTypeCleared extends SalesOrderEvent {
  const SalesOrderJobTypeCleared();
}

// ─── Job Status ───────────────────────────────────────────────────────────────

class SalesOrderJobStatusSelected extends SalesOrderEvent {
  final int statusId;
  final String statusName;
  const SalesOrderJobStatusSelected({required this.statusId, required this.statusName});

  @override
  List<Object?> get props => [statusId, statusName];
}

// ─── Sale Date ────────────────────────────────────────────────────────────────

class SalesOrderDateChanged extends SalesOrderEvent {
  final String date; // yyyy-MM-dd
  const SalesOrderDateChanged({required this.date});

  @override
  List<Object?> get props => [date];
}

// ─── Truck Size ───────────────────────────────────────────────────────────────

class SalesOrderTruckSizeChanged extends SalesOrderEvent {
  final String? value;
  const SalesOrderTruckSizeChanged({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── Forwarding Dropdowns ─────────────────────────────────────────────────────

class SalesOrderFW1Changed extends SalesOrderEvent {
  final String? value;
  const SalesOrderFW1Changed({required this.value});

  @override
  List<Object?> get props => [value];
}

class SalesOrderFW2Changed extends SalesOrderEvent {
  final String? value;
  const SalesOrderFW2Changed({required this.value});

  @override
  List<Object?> get props => [value];
}

class SalesOrderFW3Changed extends SalesOrderEvent {
  final String? value;
  const SalesOrderFW3Changed({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── ZB Dropdowns ────────────────────────────────────────────────────────────

class SalesOrderZB1Changed extends SalesOrderEvent {
  final String? value;
  const SalesOrderZB1Changed({required this.value});

  @override
  List<Object?> get props => [value];
}

class SalesOrderZB2Changed extends SalesOrderEvent {
  final String? value;
  const SalesOrderZB2Changed({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── Date/Time checkboxes ─────────────────────────────────────────────────────

class SalesOrderDateTimeToggled extends SalesOrderEvent {
  final String field; // e.g. 'LETA', 'LETB', 'OETA', 'FW1', 'PickUp' etc.
  final bool value;
  const SalesOrderDateTimeToggled({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

class SalesOrderDateTimeChanged extends SalesOrderEvent {
  final String field;
  final String dateTime; // yyyy-MM-dd HH:mm:ss
  const SalesOrderDateTimeChanged({required this.field, required this.dateTime});

  @override
  List<Object?> get props => [field, dateTime];
}

// ─── Origin / Destination ─────────────────────────────────────────────────────

class SalesOrderOriginSelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderOriginSelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SalesOrderDestinationSelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderDestinationSelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

// ─── Agent (Loading) ──────────────────────────────────────────────────────────

class SalesOrderLAgentCompanySelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderLAgentCompanySelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SalesOrderLAgentSelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderLAgentSelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

// ─── Agent (Off) ──────────────────────────────────────────────────────────────

class SalesOrderOAgentCompanySelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderOAgentCompanySelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SalesOrderOAgentSelected extends SalesOrderEvent {
  final int id;
  final String name;
  const SalesOrderOAgentSelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

// ─── Employee: Seal / BreakSeal / Boarding ────────────────────────────────────

class SalesOrderSealEmpSelected extends SalesOrderEvent {
  final int slot; // 1, 2, 3
  final int id;
  final String name;
  const SalesOrderSealEmpSelected({required this.slot, required this.id, required this.name});

  @override
  List<Object?> get props => [slot, id, name];
}

class SalesOrderSealEmpCleared extends SalesOrderEvent {
  final int slot;
  const SalesOrderSealEmpCleared({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class SalesOrderBreakSealEmpSelected extends SalesOrderEvent {
  final int slot;
  final int id;
  final String name;
  const SalesOrderBreakSealEmpSelected({required this.slot, required this.id, required this.name});

  @override
  List<Object?> get props => [slot, id, name];
}

class SalesOrderBreakSealEmpCleared extends SalesOrderEvent {
  final int slot;
  const SalesOrderBreakSealEmpCleared({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class SalesOrderBoardingOfficerSelected extends SalesOrderEvent {
  final int slot; // 1, 2
  final int id;
  final String name;
  const SalesOrderBoardingOfficerSelected({required this.slot, required this.id, required this.name});

  @override
  List<Object?> get props => [slot, id, name];
}

class SalesOrderBoardingOfficerCleared extends SalesOrderEvent {
  final int slot;
  const SalesOrderBoardingOfficerCleared({required this.slot});

  @override
  List<Object?> get props => [slot];
}

// ─── Autocomplete S1 (Forwarding S1/S2) ──────────────────────────────────────

class SalesOrderAutoCompleteS1Changed extends SalesOrderEvent {
  final String query;
  final int type; // 1-6
  const SalesOrderAutoCompleteS1Changed({required this.query, required this.type});

  @override
  List<Object?> get props => [query, type];
}

class SalesOrderAutoCompleteS1Selected extends SalesOrderEvent {
  final int type;
  final String value;
  const SalesOrderAutoCompleteS1Selected({required this.type, required this.value});

  @override
  List<Object?> get props => [type, value];
}

class SalesOrderOverlayCleared extends SalesOrderEvent {
  const SalesOrderOverlayCleared();
}

// ─── Product ──────────────────────────────────────────────────────────────────

class SalesOrderProductAdded extends SalesOrderEvent {
  final SaleEditDetailModel product;
  final int? updateIndex;
  const SalesOrderProductAdded({required this.product, this.updateIndex});

  @override
  List<Object?> get props => [product, updateIndex];
}

class SalesOrderProductRemoved extends SalesOrderEvent {
  final int index;
  const SalesOrderProductRemoved({required this.index});

  @override
  List<Object?> get props => [index];
}

class SalesOrderProductCalculationRequested extends SalesOrderEvent {
  final double qty;
  final double saleRate;
  final double gst;
  final double currencyValue;
  const SalesOrderProductCalculationRequested({
    required this.qty,
    required this.saleRate,
    required this.gst,
    required this.currencyValue,
  });

  @override
  List<Object?> get props => [qty, saleRate, gst, currencyValue];
}

// ─── Currency ─────────────────────────────────────────────────────────────────

class SalesOrderCurrencyValueChanged extends SalesOrderEvent {
  final double value;
  const SalesOrderCurrencyValueChanged({required this.value});

  @override
  List<Object?> get props => [value];
}

// ─── Pickup / Delivery address list management ────────────────────────────────

class SalesOrderPickupAddressListUpdated extends SalesOrderEvent {
  final List<dynamic> list;
  final String displayText;
  const SalesOrderPickupAddressListUpdated({required this.list, required this.displayText});

  @override
  List<Object?> get props => [list, displayText];
}

class SalesOrderDeliveryAddressListUpdated extends SalesOrderEvent {
  final List<dynamic> list;
  final String displayText;
  const SalesOrderDeliveryAddressListUpdated({required this.list, required this.displayText});

  @override
  List<Object?> get props => [list, displayText];
}

// ─── Visibility (EnableVisibility after JobType selected) ────────────────────

class SalesOrderVisibilityRefreshed extends SalesOrderEvent {
  const SalesOrderVisibilityRefreshed();
}

// ─── Field permission ─────────────────────────────────────────────────────────

class SalesOrderFieldPermissionsApplied extends SalesOrderEvent {
  const SalesOrderFieldPermissionsApplied();
}

// ─── Save ─────────────────────────────────────────────────────────────────────

class SalesOrderSaveRequested extends SalesOrderEvent {
  /// All text-field values passed from the UI layer
  final Map<String, String> fields;
  const SalesOrderSaveRequested({required this.fields});

  @override
  List<Object?> get props => [fields];
}

// ─── Clear ────────────────────────────────────────────────────────────────────

class SalesOrderClearRequested extends SalesOrderEvent {
  const SalesOrderClearRequested();
}