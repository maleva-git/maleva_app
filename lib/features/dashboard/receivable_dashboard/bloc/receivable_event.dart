// admin_tab_event.dart
abstract class ReceivableTabEvent {}

class ReceivableTabChanged extends ReceivableTabEvent {
  final int index;
  ReceivableTabChanged(this.index);
}
