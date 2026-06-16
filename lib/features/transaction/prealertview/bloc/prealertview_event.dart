import 'package:flutter/material.dart';

abstract class PreAlertEvent {}

class PreAlertStarted extends PreAlertEvent {
  final BuildContext context;
  PreAlertStarted(this.context);
}

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
  final String field;
  final bool value;
  PreAlertCheckboxChanged({required this.field, required this.value});
}

class PreAlertETAChanged extends PreAlertEvent {
  final String etaVal;
  final String etaRadio;
  final bool etaEnabled;
  PreAlertETAChanged({required this.etaVal, required this.etaRadio, required this.etaEnabled});
}