// admin_tab_event.dart
abstract class AdminTabEvent {}

class TabChanged extends AdminTabEvent {
  final int index;
  TabChanged(this.index);
}
