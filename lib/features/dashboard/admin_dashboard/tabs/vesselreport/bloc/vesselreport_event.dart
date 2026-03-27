abstract class VesselEvent {
  const VesselEvent();
  @override
  List<Object?> get props => [];
}

class LoadVesselDataEvent extends VesselEvent {
  final int type;
  const LoadVesselDataEvent({required this.type});
  @override
  List<Object?> get props => [type];
}

class UpdatePortEvent extends VesselEvent {
  final String portName;
  const UpdatePortEvent({required this.portName});
  @override
  List<Object?> get props => [portName];
}

class ClearPortEvent extends VesselEvent {
  const ClearPortEvent();
}

class AddPortToSearchEvent extends VesselEvent {
  final String portName;
  final String currentSearch;

  const AddPortToSearchEvent({
    required this.portName,
    required this.currentSearch,
  });

  @override
  List<Object?> get props => [portName, currentSearch];
}
class ClearSearchEvent extends VesselEvent {
  const ClearSearchEvent();
}