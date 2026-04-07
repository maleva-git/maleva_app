

abstract class UpdateRTIState {}

class UpdateRTIInitial extends UpdateRTIState {}

class UpdateRTILoading extends UpdateRTIState {}

class UpdateRTILoaded extends UpdateRTIState {
  // ── Filter values ─────────────────────────────────────────────────────────
  final String fromDate;
  final String toDate;
  final int    driverId;
  final String driverName;
  final int    truckId;
  final String truckName;
  final String rtiNo;

  // ── UI flags ──────────────────────────────────────────────────────────────
  final bool visibleDriverTruck; // hidden for driver login

  // ── List data ─────────────────────────────────────────────────────────────
  final List<dynamic> masterList; // RTIViewMasterModel list
  final List<dynamic> detailList; // RTIViewDetailModel list (all, filtered in UI)
  final int expandedIndex;        // -1 = none expanded

   UpdateRTILoaded({
    required this.fromDate,
    required this.toDate,
    required this.driverId,
    required this.driverName,
    required this.truckId,
    required this.truckName,
    required this.rtiNo,
    required this.visibleDriverTruck,
    required this.masterList,
    required this.detailList,
    required this.expandedIndex,
  });

  UpdateRTILoaded copyWith({
    String? fromDate,
    String? toDate,
    int?    driverId,
    String? driverName,
    int?    truckId,
    String? truckName,
    String? rtiNo,
    bool?   visibleDriverTruck,
    List<dynamic>? masterList,
    List<dynamic>? detailList,
    int?    expandedIndex,
  }) {
    return UpdateRTILoaded(
      fromDate:          fromDate          ?? this.fromDate,
      toDate:            toDate            ?? this.toDate,
      driverId:          driverId          ?? this.driverId,
      driverName:        driverName        ?? this.driverName,
      truckId:           truckId           ?? this.truckId,
      truckName:         truckName         ?? this.truckName,
      rtiNo:             rtiNo             ?? this.rtiNo,
      visibleDriverTruck: visibleDriverTruck ?? this.visibleDriverTruck,
      masterList:        masterList        ?? this.masterList,
      detailList:        detailList        ?? this.detailList,
      expandedIndex:     expandedIndex     ?? this.expandedIndex,
    );
  }
}

class UpdateRTIError extends UpdateRTIState {
  final String message;
  UpdateRTIError(this.message);
}