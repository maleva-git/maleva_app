// admin_tab_event.dart
abstract class HrAdminTabEvent {}

class HrAdminTabChanged extends HrAdminTabEvent {
  final int index;
  HrAdminTabChanged(this.index);
}
