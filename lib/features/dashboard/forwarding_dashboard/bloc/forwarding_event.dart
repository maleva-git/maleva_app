// admin_tab_event.dart
abstract class ForwardingTabEvent {}

class ForwardingTabChanged extends ForwardingTabEvent {
  final int index;
  ForwardingTabChanged(this.index);
}
