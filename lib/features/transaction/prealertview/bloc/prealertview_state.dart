

abstract class PreAlertState {}

class PreAlertInitial extends PreAlertState {}

class PreAlertLoading extends PreAlertState {}

class PreAlertLoaded extends PreAlertState {
  // ── Filter values ────────────────────────────────────────────────────
  final String fromDate;
  final String toDate;
  final int custId;
  final String custName;
  final int jobId;
  final String jobName;
  final int portId;
  final String portName;
  final String vessel;

  // ── Checkboxes ───────────────────────────────────────────────────────
  final bool checkPickUp;
  final bool checkPort;
  final bool checkVesselName;
  final bool checkConsolidated;
  final bool checkDelivery;
  final bool checkLEmp;
  final bool completeStatusNotShow;

  // ── ETA radio ────────────────────────────────────────────────────────
  final String etaVal;
  final String etaRadioVal;
  final bool etaEnabled;

  // ── List data ────────────────────────────────────────────────────────
  final List<dynamic> masterList;
  final int expandedIndex;

   PreAlertLoaded({
    required this.fromDate,
    required this.toDate,
    required this.custId,
    required this.custName,
    required this.jobId,
    required this.jobName,
    required this.portId,
    required this.portName,
    required this.vessel,
    required this.checkPickUp,
    required this.checkPort,
    required this.checkVesselName,
    required this.checkConsolidated,
    required this.checkDelivery,
    required this.checkLEmp,
    required this.completeStatusNotShow,
    required this.etaVal,
    required this.etaRadioVal,
    required this.etaEnabled,
    required this.masterList,
    required this.expandedIndex,
  });

  PreAlertLoaded copyWith({
    String? fromDate,
    String? toDate,
    int? custId,
    String? custName,
    int? jobId,
    String? jobName,
    int? portId,
    String? portName,
    String? vessel,
    bool? checkPickUp,
    bool? checkPort,
    bool? checkVesselName,
    bool? checkConsolidated,
    bool? checkDelivery,
    bool? checkLEmp,
    bool? completeStatusNotShow,
    String? etaVal,
    String? etaRadioVal,
    bool? etaEnabled,
    List<dynamic>? masterList,
    int? expandedIndex,
  }) {
    return PreAlertLoaded(
      fromDate:            fromDate            ?? this.fromDate,
      toDate:              toDate              ?? this.toDate,
      custId:              custId              ?? this.custId,
      custName:            custName            ?? this.custName,
      jobId:               jobId               ?? this.jobId,
      jobName:             jobName             ?? this.jobName,
      portId:              portId              ?? this.portId,
      portName:            portName            ?? this.portName,
      vessel:              vessel              ?? this.vessel,
      checkPickUp:         checkPickUp         ?? this.checkPickUp,
      checkPort:           checkPort           ?? this.checkPort,
      checkVesselName:     checkVesselName     ?? this.checkVesselName,
      checkConsolidated:   checkConsolidated   ?? this.checkConsolidated,
      checkDelivery:       checkDelivery       ?? this.checkDelivery,
      checkLEmp:           checkLEmp           ?? this.checkLEmp,
      completeStatusNotShow: completeStatusNotShow ?? this.completeStatusNotShow,
      etaVal:              etaVal              ?? this.etaVal,
      etaRadioVal:         etaRadioVal         ?? this.etaRadioVal,
      etaEnabled:          etaEnabled          ?? this.etaEnabled,
      masterList:          masterList          ?? this.masterList,
      expandedIndex:       expandedIndex       ?? this.expandedIndex,
    );
  }
}

class PreAlertError extends PreAlertState {
  final String message;
  PreAlertError(this.message);
}

class PreAlertNavigateToEdit extends PreAlertState {
  final int id;
  final int saleOrderNo;
  PreAlertNavigateToEdit({required this.id, required this.saleOrderNo});
}