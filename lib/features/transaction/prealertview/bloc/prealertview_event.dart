
abstract class PreAlertEvent {}

// Initial load
class PreAlertStarted extends PreAlertEvent {}

// Filter field changes
class PreAlertFromDateChanged extends PreAlertEvent {
  final String date;
  PreAlertFromDateChanged(this.date);
}

class PreAlertToDateChanged extends PreAlertEvent {
  final String date;
  PreAlertToDateChanged(this.date);
}

class PreAlertCustomerChanged extends PreAlertEvent {
  final int custId;
  final String custName;
  PreAlertCustomerChanged({required this.custId, required this.custName});
}

class PreAlertCustomerCleared extends PreAlertEvent {}

class PreAlertJobTypeChanged extends PreAlertEvent {
  final int jobId;
  final String jobName;
  PreAlertJobTypeChanged({required this.jobId, required this.jobName});
}

class PreAlertJobTypeCleared extends PreAlertEvent {}

class PreAlertPortChanged extends PreAlertEvent {
  final int portId;
  final String portName;
  PreAlertPortChanged({required this.portId, required this.portName});
}

class PreAlertPortCleared extends PreAlertEvent {}

class PreAlertVesselChanged extends PreAlertEvent {
  final String vessel;
  PreAlertVesselChanged(this.vessel);
}

class PreAlertCheckboxChanged extends PreAlertEvent {
  final String field; // 'pickup','port','vesselName','consolidated','delivery','lEmp','completeStatus'
  final bool value;
  PreAlertCheckboxChanged({required this.field, required this.value});
}

class PreAlertETAChanged extends PreAlertEvent {
  final String etaVal;     // "0","1","2","3"
  final String etaRadio;   // "O","1","2"
  final bool etaEnabled;
  PreAlertETAChanged({
    required this.etaVal,
    required this.etaRadio,
    required this.etaEnabled,
  });
}

// Trigger API calls
class PreAlertViewRequested extends PreAlertEvent {}

class PreAlertRowToggled extends PreAlertEvent {
  final int index;
  PreAlertRowToggled(this.index);
}

class PreAlertEditRequested extends PreAlertEvent {
  final int Id;
  final int SaleOrderNo;

  PreAlertEditRequested({
    required this.Id,
    required this.SaleOrderNo,
  });
}