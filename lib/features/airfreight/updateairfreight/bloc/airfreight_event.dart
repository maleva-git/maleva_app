import 'package:flutter/material.dart';

abstract class AirFreightEvent {}

class AirFreightStarted extends AirFreightEvent {
  final String? jobNo;
  final int? jobId;
  final BuildContext context;
  AirFreightStarted({this.jobNo, this.jobId, required this.context});
}

class AirFreightBillTypeChanged extends AirFreightEvent {
  final String billType;
  final BuildContext context;
  AirFreightBillTypeChanged(this.billType, this.context);
}

class AirFreightJobNoTextChanged extends AirFreightEvent {
  final String text;
  AirFreightJobNoTextChanged(this.text);
}

class AirFreightJobNoSelected extends AirFreightEvent {
  final int saleOrderId;
  final String jobNo;
  final BuildContext context;
  AirFreightJobNoSelected({required this.saleOrderId, required this.jobNo, required this.context});
}

class AirFreightOverlayDismissed extends AirFreightEvent {}

class AirFreightStatusSelected extends AirFreightEvent {
  final int statusId;
  final String statusName;
  AirFreightStatusSelected({required this.statusId, required this.statusName});
}

class AirFreightStatusCleared extends AirFreightEvent {}

class AirFreightAwbNoChanged extends AirFreightEvent {
  final String value;
  AirFreightAwbNoChanged(this.value);
}

class AirFreightImageUploadToggled extends AirFreightEvent {
  final bool value;
  AirFreightImageUploadToggled(this.value);
}

class AirFreightImagePicked extends AirFreightEvent {
  final String imageUrl;
  AirFreightImagePicked(this.imageUrl);
}

class AirFreightImageDeleted extends AirFreightEvent {
  final int index;
  final BuildContext context;
  AirFreightImageDeleted(this.index, this.context);
}

class AirFreightSaveRequested extends AirFreightEvent {
  final BuildContext context;
  AirFreightSaveRequested(this.context);
}

class AirFreightClearRequested extends AirFreightEvent {}