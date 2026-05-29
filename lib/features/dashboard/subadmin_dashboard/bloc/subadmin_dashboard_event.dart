// admin_tab_event.dart
abstract class SubAdminTabEvent {}

class SATabChanged extends SubAdminTabEvent {
  final int index;
  SATabChanged(this.index);
}
