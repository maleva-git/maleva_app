

import 'package:equatable/equatable.dart';

enum VesselPlanningDetailsStatus { initial, loading, success, failure }

class VesselPlanningDetailsState extends Equatable {
  const VesselPlanningDetailsState({
    this.status           = VesselPlanningDetailsStatus.initial,
    this.vesselPlanningList = const [],
    this.errorMessage     = '',
  });

  final VesselPlanningDetailsStatus status;
  final List<dynamic> vesselPlanningList;
  final String errorMessage;

  // ── Derived ───────────────────────────────────────────────
  bool get isLoading => status == VesselPlanningDetailsStatus.loading;
  bool get hasData =>
      status == VesselPlanningDetailsStatus.success &&
          vesselPlanningList.isNotEmpty;
  bool get isEmpty =>
      status == VesselPlanningDetailsStatus.success &&
          vesselPlanningList.isEmpty;

  VesselPlanningDetailsState copyWith({
    VesselPlanningDetailsStatus? status,
    List<dynamic>? vesselPlanningList,
    String? errorMessage,
  }) {
    return VesselPlanningDetailsState(
      status:             status             ?? this.status,
      vesselPlanningList: vesselPlanningList ?? this.vesselPlanningList,
      errorMessage:       errorMessage       ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, vesselPlanningList, errorMessage];
}