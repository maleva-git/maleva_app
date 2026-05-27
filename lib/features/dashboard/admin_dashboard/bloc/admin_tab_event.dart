// admin_tab_event.dart
abstract class AdminTabEvent {}

class AdminTabChanged extends AdminTabEvent {
  final int index;
  AdminTabChanged(this.index);
}
