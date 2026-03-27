import 'package:maleva/core/models/model.dart';

abstract class SalesOrderAddEvent {}

// ── Startup ──────────────────────────────────────────────
class StartupSalesOrderAdd extends SalesOrderAddEvent {
  final List<SaleEditDetailModel>? saleDetails;
  final List<dynamic>? saleMaster;
  final bool isEnquiry;
  StartupSalesOrderAdd({this.saleDetails, this.saleMaster, this.isEnquiry = false});
}

// ── Save ─────────────────────────────────────────────────
class SaveSalesOrderEvent extends SalesOrderAddEvent {}

// ── Field updates ─────────────────────────────────────────
class UpdateTextField extends SalesOrderAddEvent {
  final String field;
  final String value;
  UpdateTextField(this.field, this.value);
}

class UpdateDropdown extends SalesOrderAddEvent {
  final String field;
  final String? value;
  UpdateDropdown(this.field, this.value);
}

class UpdateCheckbox extends SalesOrderAddEvent {
  final String field;
  final bool value;
  UpdateCheckbox(this.field, this.value);
}

class UpdateDate extends SalesOrderAddEvent {
  final String field;
  final String value;
  UpdateDate(this.field, this.value);
}

// ── Master search results ─────────────────────────────────
class CustomerSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  CustomerSelected(this.name, this.id);
}

class JobTypeSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  JobTypeSelected(this.name, this.id);
}

class JobStatusSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  JobStatusSelected(this.name, this.id);
}

class LAgentCompanySelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  LAgentCompanySelected(this.name, this.id);
}

class LAgentSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  LAgentSelected(this.name, this.id);
}

class OAgentCompanySelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  OAgentCompanySelected(this.name, this.id);
}

class OAgentSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  OAgentSelected(this.name, this.id);
}

class SealEmp1Selected extends SalesOrderAddEvent {
  final String name;
  final int id;
  final bool isBreak;
  SealEmp1Selected(this.name, this.id, {this.isBreak = false});
}

class SealEmp2Selected extends SalesOrderAddEvent {
  final String name;
  final int id;
  final bool isBreak;
  SealEmp2Selected(this.name, this.id, {this.isBreak = false});
}

class SealEmp3Selected extends SalesOrderAddEvent {
  final String name;
  final int id;
  final bool isBreak;
  SealEmp3Selected(this.name, this.id, {this.isBreak = false});
}

class BoardingOfficer1Selected extends SalesOrderAddEvent {
  final String name;
  final int id;
  BoardingOfficer1Selected(this.name, this.id);
}

class BoardingOfficer2Selected extends SalesOrderAddEvent {
  final String name;
  final int id;
  BoardingOfficer2Selected(this.name, this.id);
}

class CommoditySelected extends SalesOrderAddEvent {
  final String name;
  CommoditySelected(this.name);
}

class CargoSelected extends SalesOrderAddEvent {
  final String name;
  CargoSelected(this.name);
}

class LPortSelected extends SalesOrderAddEvent {
  final String name;
  LPortSelected(this.name);
}

class OPortSelected extends SalesOrderAddEvent {
  final String name;
  OPortSelected(this.name);
}

class LVesselTypeSelected extends SalesOrderAddEvent {
  final String name;
  LVesselTypeSelected(this.name);
}

class OVesselTypeSelected extends SalesOrderAddEvent {
  final String name;
  OVesselTypeSelected(this.name);
}

class OriginSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  OriginSelected(this.name, this.id);
}

class DestinationSelected extends SalesOrderAddEvent {
  final String name;
  final int id;
  DestinationSelected(this.name, this.id);
}

class PickUpAddressSelected extends SalesOrderAddEvent {
  final String address;
  PickUpAddressSelected(this.address);
}

class DeliveryAddressSelected extends SalesOrderAddEvent {
  final String address;
  DeliveryAddressSelected(this.address);
}

class WarehouseAddressSelected extends SalesOrderAddEvent {
  final String address;
  WarehouseAddressSelected(this.address);
}

// ── Product operations ────────────────────────────────────
class AddProduct extends SalesOrderAddEvent {}

class UpdateProduct extends SalesOrderAddEvent {
  final int index;
  UpdateProduct(this.index);
}

class RemoveProduct extends SalesOrderAddEvent {
  final int index;
  RemoveProduct(this.index);
}

class PrepareProductEdit extends SalesOrderAddEvent {
  final int index;
  PrepareProductEdit(this.index);
}

class ProductSelected extends SalesOrderAddEvent {
  final String name;
  final String code;
  final int id;
  ProductSelected(this.name, this.code, this.id);
}

class ClearProduct extends SalesOrderAddEvent {}

class KeyPress extends SalesOrderAddEvent {
  final String key;
  final String activeField; // 'qty' | 'saleRate' | 'gst'
  KeyPress(this.key, this.activeField);
}

// ── Address list operations ───────────────────────────────
class AddPickUpAddress extends SalesOrderAddEvent {}
class AddDeliveryAddress extends SalesOrderAddEvent {}
class RemovePickUpAddress extends SalesOrderAddEvent {
  final int index;
  RemovePickUpAddress(this.index);
}
class RemoveDeliveryAddress extends SalesOrderAddEvent {
  final int index;
  RemoveDeliveryAddress(this.index);
}
class SelectPickUpFromList extends SalesOrderAddEvent {
  final int index;
  SelectPickUpFromList(this.index);
}
class SelectDeliveryFromList extends SalesOrderAddEvent {
  final int index;
  SelectDeliveryFromList(this.index);
}

// ── Toggle visibility ─────────────────────────────────────
class ToggleProductView extends SalesOrderAddEvent {}
class ToggleFW1 extends SalesOrderAddEvent {}
class ToggleFW2 extends SalesOrderAddEvent {}
class ToggleFW3 extends SalesOrderAddEvent {}

// ── Bill type change ──────────────────────────────────────
class BillTypeChanged extends SalesOrderAddEvent {
  final String value;
  BillTypeChanged(this.value);
}