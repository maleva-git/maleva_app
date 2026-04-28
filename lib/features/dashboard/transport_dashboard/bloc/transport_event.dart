
abstract class TransportTabEvent {}

class TransportTabEvents extends TransportTabEvent {
  final int index;
  TransportTabEvents(this.index);
}
