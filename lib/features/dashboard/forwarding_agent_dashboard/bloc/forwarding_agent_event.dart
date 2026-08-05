abstract class ForwardingAgentTabEvent {}

class ForwardingAgentTabChanged extends ForwardingAgentTabEvent {
  final int index;
  ForwardingAgentTabChanged(this.index);
}
