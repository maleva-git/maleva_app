// admin_tab_event.dart
abstract class PayableTabEvent {}

class PTabChanged extends PayableTabEvent {
  final int index;
  PTabChanged(this.index);
}
