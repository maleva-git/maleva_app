import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// A vessel the user picked (or the master's spelling taken) for one leg of the sales form. Kept in
/// the bloc state only - never in the save body - and dropped when the field text changes after it.
/// Sent with the vessel links after a successful save.
class VesselPick {
  const VesselPick({required this.name, this.vesselMasterId, this.ptpVesselCallId, this.call});

  final String name;
  final int? vesselMasterId;
  final int? ptpVesselCallId;

  /// The picked PTP call's times, kept to warn when the user later types another ETA.
  final PtpCall? call;
}

/// A picked PTP call would replace dates or the SCN the leg already has: the form asks first.
/// [differing] names what would change (`ETA`, `ETD`, `SCN`) with the current and PTP values.
class VesselFillQuestion {
  const VesselFillQuestion({required this.leg, required this.call, required this.differing});

  final String leg;
  final PtpCall call;
  final List<VesselFillChange> differing;
}

class VesselFillChange {
  const VesselFillChange(this.field, this.current, this.ptp);

  /// `ETA`, `ETD` or `SCN`.
  final String field;
  final String current;
  final String ptp;
}

/// The backend thinks the typed name is close to a known vessel: "Use <name>" or "Keep my spelling".
class DidYouMean {
  const DidYouMean({required this.leg, required this.typed, required this.name, this.vesselMasterId});

  final String leg;
  final String typed;
  final String name;
  final int? vesselMasterId;
}

/// A Java vessel time (`yyyy-MM-dd'T'HH:mm`) as the form's date string (`yyyy-MM-dd HH:mm:ss`).
String formDateOf(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
}
