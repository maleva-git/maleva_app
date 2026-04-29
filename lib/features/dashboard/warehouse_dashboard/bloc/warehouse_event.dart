// admin_tab_event.dart
abstract class WareHouseEvent {}

class WarehouseTabChanged extends WareHouseEvent {
  final int index;
  WarehouseTabChanged(this.index);
}
