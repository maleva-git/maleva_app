// admin_tab_event.dart
abstract class SubAdminTabEvent {}

class TabChanged extends SubAdminTabEvent {
  final int index;
  TabChanged(this.index);
}
