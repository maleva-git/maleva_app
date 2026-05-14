// admin_tab_event.dart
abstract class AirfreightTabEvent {}

class AirfreightTabChanged extends AirfreightTabEvent {
  final int index;
  AirfreightTabChanged(this.index);
}
