import 'package:maleva/features/rti/models/planning_transfer_item.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

sealed class RtiEntryEvent {
  const RtiEntryEvent();
}

/// Opens the form: a saved RTI ([rtiId]), straight into revise ([revise]), or a new one,
/// pre-filled from Planning when [fromPlanning] is not empty.
class RtiEntryStarted extends RtiEntryEvent {
  const RtiEntryStarted({this.rtiId, this.revise = false, this.fromPlanning = const []});

  final int? rtiId;
  final bool revise;
  final List<PlanningTransferItem> fromPlanning;
}

/// Reloads the pickers after they failed.
class RtiReferencesRetried extends RtiEntryEvent {
  const RtiReferencesRetried();
}

/// Any form value; the driver and truck have their own events.
class RtiFormChanged extends RtiEntryEvent {
  const RtiFormChanged(this.change);

  final RtiForm Function(RtiForm) change;
}

class RtiDriverPicked extends RtiEntryEvent {
  const RtiDriverPicked(this.driverId);

  final String driverId;
}

class RtiTruckPicked extends RtiEntryEvent {
  const RtiTruckPicked(this.truckId);

  final String truckId;
}

/// One editable job cell (`JobNo`, `Salary`, `PPIC`, `DPIC`, `PWDType`).
class RtiJobCellEdited extends RtiEntryEvent {
  const RtiJobCellEdited(this.row, this.column, this.value);

  final int row;
  final String column;
  final String value;
}

/// Job No lookup for a row (Enter in the cell / "Look up"); a [row] of -1 uses the first
/// blank row or a new one (the phone's Job No field).
class RtiJobLookupRequested extends RtiEntryEvent {
  const RtiJobLookupRequested(this.row, this.jobNo);

  final int row;
  final String jobNo;
}

class RtiJobRowAdded extends RtiEntryEvent {
  const RtiJobRowAdded();
}

class RtiJobRowDeleted extends RtiEntryEvent {
  const RtiJobRowDeleted(this.row);

  final int row;
}

class RtiJobCellsPasted extends RtiEntryEvent {
  const RtiJobCellsPasted(this.row, this.column, this.text);

  final int row;
  final String column;
  final String text;
}

class RtiStopAdded extends RtiEntryEvent {
  const RtiStopAdded();
}

class RtiStopEdited extends RtiEntryEvent {
  const RtiStopEdited(this.index, this.change);

  final int index;
  final RtiStop Function(RtiStop) change;
}

/// The agent of a stop: an employee, a typed name, or neither (cleared).
class RtiStopAgentPicked extends RtiEntryEvent {
  const RtiStopAgentPicked(this.index, {this.employee, this.typed});

  final int index;
  final RtiEmployee? employee;
  final String? typed;
}

class RtiStopDeleted extends RtiEntryEvent {
  const RtiStopDeleted(this.index);

  final int index;
}

/// Save (F1). The screen asks first when the form holds a revise.
class RtiSaveRequested extends RtiEntryEvent {
  const RtiSaveRequested();
}

/// Delete, after the screen's confirm.
class RtiDeleteRequested extends RtiEntryEvent {
  const RtiDeleteRequested();
}

/// Revise from the sales orders, after the screen's confirm.
class RtiReviseRequested extends RtiEntryEvent {
  const RtiReviseRequested();
}

/// Clear (F10): a new RTI with the next number.
class RtiClearRequested extends RtiEntryEvent {
  const RtiClearRequested();
}

class RtiStepChanged extends RtiEntryEvent {
  const RtiStepChanged(this.step);

  final int step;
}

/// A one-time message the screen raises itself (share, report).
class RtiNoticeRaised extends RtiEntryEvent {
  const RtiNoticeRaised(this.text, {this.error = false});

  final String text;
  final bool error;
}
