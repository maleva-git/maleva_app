import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/vessel_pick.dart';

// The question asked when the user saves (change vessel-master-and-ptp-schedule, the same rule as the
// web page): a leg linked to a PTP call whose typed ETA or ETD is an hour or more away from PTP's:
// "Use PTP's times" or "Keep my times". It is asked once: a loaded order only after its ETA/ETD
// changed, and never again for the values the user answered. The user's answer is final and the save
// continues either way; an empty ETA is allowed. (Pickup and delivery do not follow the ETA: the
// owner removed that question on 2026-10-13.)

const int ptpTimeThresholdMinutes = 60;

/// The PTP call a leg is linked to: the one picked on this visit, else the one it was saved with.
class LegCall {
  const LegCall(this.vesselName, this.call);

  final String vesselName;
  final PtpCall call;
}

class PtpTimeLine {
  const PtpTimeLine({required this.legLabel, required this.label, required this.dateField, required this.checkField,
      required this.current, required this.ptp, required this.estimated, this.source = 'PTP'});

  final String legLabel;

  /// The schedule the leg's call is from: "PTP", "Westports" or "MMSW".
  final String source;

  /// `ETA` or `ETD`.
  final String label;

  /// The state fields written by "Use PTP's times" (e.g. `dtpOETAdate`, `checkBoxValueOETA`).
  final String dateField;
  final String checkField;
  final DateTime current;
  final DateTime ptp;
  final bool estimated;
}

/// The question the form asks before saving; the view shows it, then sends SaveDateQuestionAnswered.
class PtpTimeQuestion {
  const PtpTimeQuestion({required this.vessels, required this.lines});

  /// `FM NAMTHONG EXCELLENCE 2653`, joined with "and" for two legs.
  final String vessels;
  final List<PtpTimeLine> lines;

  /// The schedules asked about, once each: `[PTP]`, `[PTP, MMSW]`.
  List<String> get sources => lines.map((l) => l.source).toSet().toList();

  bool get _single => sources.length == 1;

  /// "PTP's schedule shows another time", "Westports' schedule …"; two schedules: "The schedules show …".
  String get title => _single ? "${ownerForm(sources.first)} schedule shows another time" : 'The schedules show another time';

  /// "PTP lists FM NAMTHONG EXCELLENCE 2653 at other times than you entered. Use PTP's times, or keep yours?"
  String get message => '${sources.join(' and ')} ${_single ? 'lists' : 'list'} $vessels at other times than you entered. '
      'Use $_theirs times, or keep yours?';

  /// "Use PTP's times", "Use Westports' times", "Use the schedules' times".
  String get useText => 'Use $_theirs times';

  String get _theirs => _single ? ownerForm(sources.first) : "the schedules'";
}

/// "PTP's", "MMSW's", but "Westports'".
String ownerForm(String source) => source.endsWith('s') ? "$source'" : "$source's";

DateTime? _ticked(bool ticked, String value) => ticked ? DateTime.tryParse(value) : null;

String _minute(DateTime? d) => d == null ? '' : '${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}';

/// Equal keys: no ETA or ETD changed to the minute since the last answer, load or save.
String ptpTimeKey(SalesOrderAddLoaded s) => [
      _ticked(s.checkBoxValueLETA, s.dtpLETAdate),
      _ticked(s.checkBoxValueLETD, s.dtpLETDdate),
      _ticked(s.checkBoxValueOETA, s.dtpOETAdate),
      _ticked(s.checkBoxValueOETD, s.dtpOETDdate),
    ].map(_minute).join('|');

bool _sameVessel(String a, String b) =>
    a.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase() == b.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();

/// The legs whose typed ETA or ETD is an hour or more from their PTP call; null when none.
PtpTimeQuestion? planPtpTimes(SalesOrderAddLoaded s, Map<String, LegCall> calls) {
  final lines = <PtpTimeLine>[];
  final names = <String>[];
  for (final leg in [VesselLeg.loading, VesselLeg.off]) {
    final linked = calls[leg];
    final loading = leg == VesselLeg.loading;
    if (linked == null || !(loading ? s.visibleLoadingVessel : s.visibleOffVessel)) continue;
    final name = loading ? s.txtLoadingVessel : s.txtOffVessel;
    if (name.trim().isEmpty || !_sameVessel(name, linked.vesselName)) continue;
    final legLabel = loading ? 'Loading vessel' : 'Off vessel';
    final candidates = [
      ('ETA', loading ? 'dtpLETAdate' : 'dtpOETAdate', loading ? 'checkBoxValueLETA' : 'checkBoxValueOETA',
          _ticked(loading ? s.checkBoxValueLETA : s.checkBoxValueOETA, loading ? s.dtpLETAdate : s.dtpOETAdate),
          linked.call.arrive, linked.call.arriveEstimated),
      ('ETD', loading ? 'dtpLETDdate' : 'dtpOETDdate', loading ? 'checkBoxValueLETD' : 'checkBoxValueOETD',
          _ticked(loading ? s.checkBoxValueLETD : s.checkBoxValueOETD, loading ? s.dtpLETDdate : s.dtpOETDdate),
          linked.call.depart, linked.call.departEstimated),
    ];
    final before = lines.length;
    for (final (label, dateField, checkField, current, ptp, estimated) in candidates) {
      if (current == null || ptp == null) continue;
      if (current.difference(ptp).inMinutes.abs() < ptpTimeThresholdMinutes) continue;
      lines.add(PtpTimeLine(legLabel: legLabel, label: label, dateField: dateField, checkField: checkField,
          current: current, ptp: ptp, estimated: estimated, source: linked.call.sourceLabel));
    }
    if (lines.length > before) {
      final voyage = linked.call.voyageText; // "SCN 267DF4" for an MMSW call
      names.add('${name.trim().toUpperCase()}${voyage == null ? '' : ' $voyage'}');
    }
  }
  return lines.isEmpty ? null : PtpTimeQuestion(vessels: names.join(' and '), lines: lines);
}

/// "Use PTP's times": PTP's ETA / ETD on the lines asked about, each ticked so it is saved.
SalesOrderAddLoaded applyPtpTimes(SalesOrderAddLoaded s, PtpTimeQuestion q) {
  var next = s;
  for (final line in q.lines) {
    next = _setDate(next, line.dateField, formDateOf(line.ptp));
  }
  return next;
}

SalesOrderAddLoaded _setDate(SalesOrderAddLoaded s, String field, String value) => switch (field) {
      'dtpLETAdate' => s.copyWith(dtpLETAdate: value, checkBoxValueLETA: true),
      'dtpLETDdate' => s.copyWith(dtpLETDdate: value, checkBoxValueLETD: true),
      'dtpOETAdate' => s.copyWith(dtpOETAdate: value, checkBoxValueOETA: true),
      'dtpOETDdate' => s.copyWith(dtpOETDdate: value, checkBoxValueOETD: true),
      _ => s,
    };

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// `14 Oct 2026 09:00`; `empty` for null.
String saveDateText(DateTime? d) {
  if (d == null) return 'empty';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)} ${_months[d.month - 1]} ${d.year} ${two(d.hour)}:${two(d.minute)}';
}
