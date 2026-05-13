// admin_tab_event.dart
abstract class OperationTabEvent {}

class OperationTabChanged extends OperationTabEvent {
  final int index;
  OperationTabChanged(this.index);
}
