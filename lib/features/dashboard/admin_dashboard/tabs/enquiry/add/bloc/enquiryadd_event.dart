

import 'package:flutter/Material.dart';

abstract class AddEnquiryEvent {}

// Page load — edit mode la data fill பண்ண
class InitAddEnquiryEvent extends AddEnquiryEvent {
  final Map<String, dynamic>? saleMaster;
  InitAddEnquiryEvent(this.saleMaster);
}

// Customer select
class CustomerSelectedEvent extends AddEnquiryEvent {
  final String name;
  final int id;
  CustomerSelectedEvent(this.name, this.id);
}

class CustomerClearedEvent extends AddEnquiryEvent {}

// Job Type select
class JobTypeSelectedEvent extends AddEnquiryEvent {
  final String name;
  final int id;
  JobTypeSelectedEvent(this.name, this.id);
}

class JobTypeClearedEvent extends AddEnquiryEvent {}

// L Port
class LPortSelectedEvent extends AddEnquiryEvent {
  final String name;
  LPortSelectedEvent(this.name);
}

class LPortClearedEvent extends AddEnquiryEvent {}

// O Port
class OPortSelectedEvent extends AddEnquiryEvent {
  final String name;
  OPortSelectedEvent(this.name);
}

class OPortClearedEvent extends AddEnquiryEvent {}

// L Vessel / O Vessel text change
class LVesselChangedEvent extends AddEnquiryEvent {
  final String value;
  LVesselChangedEvent(this.value);
}

class OVesselChangedEvent extends AddEnquiryEvent {
  final String value;
  OVesselChangedEvent(this.value);
}

// Notify Date
class NotifyDateChangedEvent extends AddEnquiryEvent {
  final DateTime date;
  NotifyDateChangedEvent(this.date);
}

// Collection Date + Checkbox
class CollectionCheckboxChangedEvent extends AddEnquiryEvent {
  final bool value;
  CollectionCheckboxChangedEvent(this.value);
}

class CollectionDateChangedEvent extends AddEnquiryEvent {
  final DateTime date;
  final TimeOfDay time;
  CollectionDateChangedEvent(this.date, this.time);
}

// L ETA + Checkbox
class LETACheckboxChangedEvent extends AddEnquiryEvent {
  final bool value;
  LETACheckboxChangedEvent(this.value);
}

class LETADateChangedEvent extends AddEnquiryEvent {
  final DateTime date;
  final TimeOfDay time;
  LETADateChangedEvent(this.date, this.time);
}

// O ETA + Checkbox
class OETACheckboxChangedEvent extends AddEnquiryEvent {
  final bool value;
  OETACheckboxChangedEvent(this.value);
}

class OETADateChangedEvent extends AddEnquiryEvent {
  final DateTime date;
  final TimeOfDay time;
  OETADateChangedEvent(this.date, this.time);
}

// Save
class SaveEnquiryEvent extends AddEnquiryEvent {}