
import 'package:equatable/equatable.dart';

abstract class JobStatusUpdateEvent extends Equatable {
  const JobStatusUpdateEvent();

  @override
  List<Object?> get props => [];
}

// ─── Startup ───────────────────────────────────────────────────────────────────
class JobStatusUpdateStarted extends JobStatusUpdateEvent {
  const JobStatusUpdateStarted();
}

// ─── Bill type radio changed (MY=0 / TR=1) ────────────────────────────────────
class JobStatusUpdateBillTypeChanged extends JobStatusUpdateEvent {
  final String billType;
  const JobStatusUpdateBillTypeChanged(this.billType);

  @override
  List<Object?> get props => [billType];
}

// ─── Job No text changed (autocomplete trigger) ───────────────────────────────
class JobStatusUpdateJobNoChanged extends JobStatusUpdateEvent {
  final String value;
  const JobStatusUpdateJobNoChanged(this.value);

  @override
  List<Object?> get props => [value];
}

// ─── Autocomplete suggestion tapped ──────────────────────────────────────────
class JobStatusUpdateSuggestionSelected extends JobStatusUpdateEvent {
  final String jobNo;
  final int saleOrderId;
  const JobStatusUpdateSuggestionSelected({
    required this.jobNo,
    required this.saleOrderId,
  });

  @override
  List<Object?> get props => [jobNo, saleOrderId];
}

// ─── Load job data after selecting a job ──────────────────────────────────────
class JobStatusUpdateLoadData extends JobStatusUpdateEvent {
  const JobStatusUpdateLoadData();
}

// ─── Status field: picked from search screen ──────────────────────────────────
class JobStatusUpdateStatusSelected extends JobStatusUpdateEvent {
  final String statusName;
  final int statusId;
  const JobStatusUpdateStatusSelected({
    required this.statusName,
    required this.statusId,
  });

  @override
  List<Object?> get props => [statusName, statusId];
}

// ─── Status field cleared ─────────────────────────────────────────────────────
class JobStatusUpdateStatusCleared extends JobStatusUpdateEvent {
  const JobStatusUpdateStatusCleared();
}

// ─── Checkbox toggles ─────────────────────────────────────────────────────────
class JobStatusUpdateStartTimeToggled extends JobStatusUpdateEvent {
  final bool value;
  const JobStatusUpdateStartTimeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class JobStatusUpdateEndTimeToggled extends JobStatusUpdateEvent {
  final bool value;
  const JobStatusUpdateEndTimeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class JobStatusUpdateImageUploadToggled extends JobStatusUpdateEvent {
  final bool value;
  const JobStatusUpdateImageUploadToggled(this.value);

  @override
  List<Object?> get props => [value];
}

// ─── Date/time pickers ────────────────────────────────────────────────────────
class JobStatusUpdateStartTimePicked extends JobStatusUpdateEvent {
  final String dateTime;
  const JobStatusUpdateStartTimePicked(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

class JobStatusUpdateEndTimePicked extends JobStatusUpdateEvent {
  final String dateTime;
  const JobStatusUpdateEndTimePicked(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

// ─── Image actions ────────────────────────────────────────────────────────────
class JobStatusUpdateImagePicked extends JobStatusUpdateEvent {
  final String imageName;
  const JobStatusUpdateImagePicked(this.imageName);

  @override
  List<Object?> get props => [imageName];
}

class JobStatusUpdateImageDeleted extends JobStatusUpdateEvent {
  final int index;
  const JobStatusUpdateImageDeleted(this.index);

  @override
  List<Object?> get props => [index];
}

// ─── Submit update ────────────────────────────────────────────────────────────
class JobStatusUpdateSubmitted extends JobStatusUpdateEvent {
  const JobStatusUpdateSubmitted();
}

// ─── Send status mail ─────────────────────────────────────────────────────────
class JobStatusUpdateMailSent extends JobStatusUpdateEvent {
  const JobStatusUpdateMailSent();
}

// ─── Clear / Reset form ───────────────────────────────────────────────────────
class JobStatusUpdateFormCleared extends JobStatusUpdateEvent {
  const JobStatusUpdateFormCleared();
}

// ─── Overlay / autocomplete visibility ───────────────────────────────────────
class JobStatusUpdateOverlayCleared extends JobStatusUpdateEvent {
  const JobStatusUpdateOverlayCleared();
}