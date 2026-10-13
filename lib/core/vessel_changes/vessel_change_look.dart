import 'package:intl/intl.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// Texts of the Vessel changes screen ("current system ETA → PTP changed to this → update or dismiss"),
/// kept the same as the web's vessel changes page. Pure functions, tested on their own.

/// A Java vessel time (`yyyy-MM-dd'T'HH:mm`) on one line: "12 Oct 20:15"; "—" for none, the value as it
/// is when unreadable.
String vesselClock(String? value) {
  if (value == null || value.trim().isEmpty) return '—';
  final at = vesselTime(value.trim());
  return at == null ? value : DateFormat('d MMM HH:mm').format(at);
}

/// The card title: "TOCONAO MAERSK 636N".
String vesselCallTitle(PtpCall call) {
  final voyage = call.voyage?.trim() ?? '';
  return voyage.isEmpty ? call.vesselName : '${call.vesselName} $voyage';
}

/// The card's sub-line: "PTP: arrives 12 Oct 20:15 · departs 14 Oct 00:00 (est.)", then
/// "· changed 13 Oct 16:05" only when the call's last change is known, and "· no longer listed by PTP".
String vesselCallSubline(VesselChangeGroup group) {
  final call = group.call;
  String at(String? value, bool estimated) {
    final text = vesselClock(value);
    return estimated && text != '—' ? '$text (est.)' : text;
  }

  final parts = [
    'PTP: arrives ${at(call.arriveAt, call.arriveEstimated)}',
    'departs ${at(call.departAt, call.departEstimated)}',
    if (vesselTime(group.lastChangedAt) != null) 'changed ${vesselClock(group.lastChangedAt)}',
    if (!call.listed) 'no longer listed by PTP',
  ];
  return parts.join(' · ');
}

/// The card's button: "Update all 3 jobs to PTP", "Update this job to PTP" for one.
String updateAllLabel(int jobs) => jobs == 1 ? 'Update this job to PTP' : 'Update all $jobs jobs to PTP';

/// The job as the screen names it: its number, or "#id" when it has none.
String vesselJobName(VesselChangeJob job) => job.jobNo.isEmpty ? '#${job.saleOrderId}' : job.jobNo;

/// The snackbar after an update: "MY002605808 updated to PTP's times", "3 jobs updated to PTP's times".
String updatedText(List<VesselChangeJob> updated) => updated.length == 1
    ? "${vesselJobName(updated.single)} updated to PTP's times"
    : "${updated.length} jobs updated to PTP's times";

/// How Maleva's time stands against PTP's on one row of the comparison.
enum TimeMatch {
  /// PTP's time differs (the server's `etaDiffers` / `etdDiffers`, at least the threshold apart).
  differs,

  /// Maleva has no time and PTP has one: "not set", "to fill".
  notSet,

  /// Within the threshold: "✓ same".
  same,

  /// PTP gives no time: "—".
  noPtp,
}

/// [differs] is the server's flag for this time (it applies the threshold).
TimeMatch timeMatch({String? current, String? ptp, required bool differs}) {
  if (ptp == null || ptp.trim().isEmpty) return TimeMatch.noPtp;
  if (current == null || current.trim().isEmpty) return TimeMatch.notSet;
  return differs ? TimeMatch.differs : TimeMatch.same;
}

/// The row is highlighted: PTP's time is a change to make.
bool timeMatchHighlighted(TimeMatch m) => m == TimeMatch.differs || m == TimeMatch.notSet;

/// How far PTP's time is from Maleva's: "+8 h later", "−2 d 3 h earlier", "+45 min later"; "to fill"
/// when Maleva has none; '' when PTP has none or a time cannot be read. Rounded to hours; days and hours
/// from 24 h; minutes only under 1 h.
String timeDeltaText(String? current, String? ptp) {
  final to = _wallClock(ptp);
  if (to == null) return '';
  if (current == null || current.trim().isEmpty) return 'to fill';
  final from = _wallClock(current);
  if (from == null) return '';
  final minutes = to.difference(from).inMinutes;
  if (minutes == 0) return '';
  final sign = minutes > 0 ? '+' : '−';
  final word = minutes > 0 ? 'later' : 'earlier';
  final abs = minutes.abs();
  if (abs < 60) return '$sign$abs min $word';
  final hours = (abs / 60).round();
  final days = hours ~/ 24;
  final rest = hours % 24;
  final size = days == 0 ? '$rest h' : (rest == 0 ? '$days d' : '$days d $rest h');
  return '$sign$size $word';
}

/// The wall clock a vessel time names, as UTC so a daylight-saving change on the test machine never
/// shifts the difference.
DateTime? _wallClock(String? value) {
  final at = value == null ? null : vesselTime(value.trim());
  return at == null ? null : DateTime.utc(at.year, at.month, at.day, at.hour, at.minute);
}
