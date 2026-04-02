// admin_tab_event.dart
abstract class OperationAdminTabEvent {}

class TabChanged extends OperationAdminTabEvent {
  final int index;
  TabChanged(this.index);
}
