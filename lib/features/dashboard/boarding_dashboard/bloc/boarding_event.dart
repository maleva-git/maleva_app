// admin_tab_event.dart
abstract class BoardingTabEvent {}

class BoardingTabChanged extends BoardingTabEvent {
  final int index;
  BoardingTabChanged(this.index);
}
