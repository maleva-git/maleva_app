// admin_tab_event.dart
abstract class MaintenanceTabEvent {}

class MaintenanceTabChanged extends MaintenanceTabEvent {
  final int index;
  MaintenanceTabChanged(this.index);
}
