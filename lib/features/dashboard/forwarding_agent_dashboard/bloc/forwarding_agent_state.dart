class ForwardingAgentTabState {
  final int index;
  const ForwardingAgentTabState({this.index = 0});

  ForwardingAgentTabState copyWith({int? index}) {
    return ForwardingAgentTabState(index: index ?? this.index);
  }
}
