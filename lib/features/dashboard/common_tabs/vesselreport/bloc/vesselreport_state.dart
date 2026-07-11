abstract class VesselState {
  const VesselState();

  @override
  List<Object?> get props => [];
}

class VesselInitial extends VesselState {
  const VesselInitial();
}

class VesselLoadingState extends VesselState {
  const VesselLoadingState();
}

class VesselLoadedState extends VesselState {
  final List<Map<String, dynamic>> vesselList;
  final bool isPlanToday;
  final String portName;
  final String searchText;

  const VesselLoadedState({
    required this.vesselList,
    required this.isPlanToday,
    required this.portName,
    required this.searchText,
  });

  // Helper to copy state with changed fields only
  VesselLoadedState copyWith({
    List<Map<String, dynamic>>? vesselList,
    bool? isPlanToday,
    String? portName,
    String? searchText,
  }) {
    return VesselLoadedState(
      vesselList: vesselList ?? this.vesselList,
      isPlanToday: isPlanToday ?? this.isPlanToday,
      portName: portName ?? this.portName,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [vesselList, isPlanToday, portName, searchText];
}


class VesselErrorState extends VesselState {
  final String errorMessage;

  const VesselErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class VesselFieldUpdatedState extends VesselState {
  final String portName;
  final String searchText;

  const VesselFieldUpdatedState({
    required this.portName,
    required this.searchText,
  });

  @override
  List<Object?> get props => [portName, searchText];
}

