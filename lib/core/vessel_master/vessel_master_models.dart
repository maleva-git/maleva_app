import 'package:maleva/core/utils/json_read.dart';

/// The two sides of a sale order as the vessel APIs name them: `LOADING` (L side:
/// `loadingvesselname`, ETA/ETB/ETD, L SCN, L port) and `OFF` (O side: `offvesselname`,
/// OETA/OETB/OETD, O SCN, O port).
class VesselLeg {
  VesselLeg._();

  static const String loading = 'LOADING';
  static const String off = 'OFF';
}

/// The schedule sources of a vessel call (`PtpCall.port`, `VesselAlert.port`) and their text labels.
class VesselSource {
  VesselSource._();

  static const String ptp = 'PTP';
  static const String westports = 'WESTPORTS';

  /// MMSW (Northport, Southport and the other Port Klang terminals; backend change mmsw-vessel-schedule).
  static const String mmsw = 'MMSW';
  static const String ptpLabel = 'PTP';
  static const String westportsLabel = 'Westports';
  static const String mmswLabel = 'MMSW';

  /// The label of a source code ([ptp] / [westports] / [mmsw]); "PTP" for none or an unknown one.
  static String labelOf(String? port, {String? label}) {
    final given = label?.trim() ?? '';
    if (given.isNotEmpty) return given;
    switch (port?.toUpperCase()) {
      case westports:
        return westportsLabel;
      case mmsw:
        return mmswLabel;
      default:
        return ptpLabel;
    }
  }

  /// "MMSW · Northport KCT": the label and, when given, the terminal(s) of an MMSW call; the label alone otherwise.
  static String withTerminal(String label, String? terminal) {
    final t = terminal?.trim() ?? '';
    return t.isEmpty ? label : '$label · $t';
  }

  /// "PTP's", "Westports'".
  static String possessive(String label) => label.endsWith('s') ? "$label'" : "$label's";
}

/// A Java date-time of the vessel APIs (`yyyy-MM-dd'T'HH:mm`, no offset) as the wall clock it
/// names; null for null or an unreadable value.
DateTime? vesselTime(String? value) => value == null ? null : DateTime.tryParse(value);

/// One vessel call on PTP's schedule (`PtpCall` of backend change vessel-master-and-ptp-schedule).
///
/// The times are kept as the Java strings ([arriveAt], [departAt], ...) so they can be sent back
/// unchanged; [arrive] / [depart] read them as local wall-clock times.
class PtpCall {
  const PtpCall({
    required this.id,
    this.port,
    required this.vesselName,
    this.vesselCode,
    this.lineId,
    this.voyage,
    this.scn,
    this.arriveAt,
    this.arriveEstimated = false,
    this.departAt,
    this.departEstimated = false,
    this.dryCutoff,
    this.reeferCutoff,
    this.cfsCutoff,
    this.hazardCutoff,
    this.listed = true,
    this.lastSeenAt,
    this.portLabel,
    this.voyageOut,
    this.status,
    this.omitted = false,
    this.yardOpening,
    this.berth,
    this.actualArriveAt,
    this.actualDepartAt,
    this.terminal,
    this.callSign,
    this.lastPort,
    this.shippingAgent,
  });

  factory PtpCall.fromJava(Map<String, dynamic> m) => PtpCall(
        id: JsonRead.integer(m['id']),
        port: JsonRead.stringOrNull(m['port']),
        vesselName: JsonRead.string(m['vesselName']),
        vesselCode: JsonRead.stringOrNull(m['vesselCode']),
        lineId: JsonRead.stringOrNull(m['lineId']),
        voyage: JsonRead.stringOrNull(m['voyage']),
        scn: JsonRead.stringOrNull(m['scn']),
        arriveAt: JsonRead.stringOrNull(m['arriveAt']),
        arriveEstimated: JsonRead.boolean(m['arriveEstimated']),
        departAt: JsonRead.stringOrNull(m['departAt']),
        departEstimated: JsonRead.boolean(m['departEstimated']),
        dryCutoff: JsonRead.stringOrNull(m['dryCutoff']),
        reeferCutoff: JsonRead.stringOrNull(m['reeferCutoff']),
        cfsCutoff: JsonRead.stringOrNull(m['cfsCutoff']),
        hazardCutoff: JsonRead.stringOrNull(m['hazardCutoff']),
        listed: m['listed'] == null ? true : JsonRead.boolean(m['listed']),
        lastSeenAt: JsonRead.stringOrNull(m['lastSeenAt']),
        portLabel: JsonRead.stringOrNull(m['portLabel']),
        voyageOut: JsonRead.stringOrNull(m['voyageOut']),
        status: JsonRead.stringOrNull(m['status']),
        omitted: JsonRead.boolean(m['omitted']),
        yardOpening: JsonRead.stringOrNull(m['yardOpening']),
        berth: JsonRead.stringOrNull(m['berth']),
        actualArriveAt: JsonRead.stringOrNull(m['actualArriveAt']),
        actualDepartAt: JsonRead.stringOrNull(m['actualDepartAt']),
        terminal: JsonRead.stringOrNull(m['terminal']),
        callSign: JsonRead.stringOrNull(m['callSign']),
        lastPort: JsonRead.stringOrNull(m['lastPort']),
        shippingAgent: JsonRead.stringOrNull(m['shippingAgent']),
      );

  final int id;

  /// The schedule source: [VesselSource.ptp], [VesselSource.westports] or [VesselSource.mmsw] (null in
  /// older answers: PTP).
  final String? port;
  final String vesselName;
  final String? vesselCode;
  final String? lineId;

  /// Null for an MMSW call (MMSW has no voyage; [voyageText] shows its SCN instead).
  final String? voyage;

  /// Null when PTP says None. MMSW's key of the call.
  final String? scn;
  final String? arriveAt;

  /// PTP's asterisk: the time is an estimate.
  final bool arriveEstimated;
  final String? departAt;
  final bool departEstimated;
  final String? dryCutoff;
  final String? reeferCutoff;
  final String? cfsCutoff;
  final String? hazardCutoff;

  /// False once PTP no longer lists the call.
  final bool listed;
  final String? lastSeenAt;

  /// "PTP" or "Westports", for texts (change westports-vessel-schedule); null in older answers.
  final String? portLabel;

  /// Westports' Voyage Out; null for PTP.
  final String? voyageOut;

  /// Westports' Status as written ("Not Arrived", "Arrived", "Omitted", ...); null for PTP.
  final String? status;

  /// Westports lists the call as Omitted: the vessel skips Westports.
  final bool omitted;
  final String? yardOpening;

  /// The berth Westports assigned to the call ("B19").
  final String? berth;

  /// Westports' ATA / ATD (shown, never compared); null for PTP.
  final String? actualArriveAt;
  final String? actualDepartAt;

  /// MMSW's terminal(s) ("Northport KCT", or a list "Northport KCT, Southport BST"); null for PTP / Westports
  /// and in older answers.
  final String? terminal;

  /// MMSW's call sign, last port ("SGSIN-SINGAPORE") and shipping agent; null for PTP / Westports.
  final String? callSign;
  final String? lastPort;
  final String? shippingAgent;

  bool get isWestports => port?.toUpperCase() == VesselSource.westports;

  bool get isMmsw => port?.toUpperCase() == VesselSource.mmsw;

  /// The source as texts name it: [portLabel], else "Westports" / "MMSW" by [port], else "PTP".
  String get sourceLabel => VesselSource.labelOf(port, label: portLabel);

  /// The source with an MMSW call's terminal: "MMSW · Northport KCT"; [sourceLabel] otherwise.
  String get sourceText => isMmsw ? VesselSource.withTerminal(sourceLabel, terminal) : sourceLabel;

  /// What stands after the vessel name: the voyage, else "SCN 267DF4" (an MMSW call has no voyage); null for neither.
  String? get voyageText {
    final v = voyage?.trim() ?? '';
    if (v.isNotEmpty) return v;
    final s = scn?.trim() ?? '';
    return s.isEmpty ? null : 'SCN $s';
  }

  DateTime? get arrive => vesselTime(arriveAt);
  DateTime? get depart => vesselTime(departAt);
}

/// One row of `GET /api/vessel-masters/suggest`: a vessel and, for a PTP port (or no port), its calls.
class VesselSuggestion {
  const VesselSuggestion({
    this.vesselMasterId,
    required this.vesselName,
    this.vesselCode,
    this.lineId,
    this.matchedAlias,
    this.calls = const [],
  });

  factory VesselSuggestion.fromJava(Map<String, dynamic> m) => VesselSuggestion(
        vesselMasterId: JsonRead.intOrNull(m['vesselMasterId']),
        vesselName: JsonRead.string(m['vesselName']),
        vesselCode: JsonRead.stringOrNull(m['vesselCode']),
        lineId: JsonRead.stringOrNull(m['lineId']),
        matchedAlias: JsonRead.stringOrNull(m['matchedAlias']),
        calls: JsonRead.listOfMaps(m['calls']).map(PtpCall.fromJava).toList(),
      );

  /// Null for a PTP vessel this company has not used yet.
  final int? vesselMasterId;
  final String vesselName;
  final String? vesselCode;
  final String? lineId;

  /// The old spelling that matched, if any.
  final String? matchedAlias;
  final List<PtpCall> calls;
}

/// `GET /api/vessel-masters/similar`: [match] is `SAME`, `CLOSE` or `NONE` (then id and name are null).
class SimilarVessel {
  const SimilarVessel({required this.match, this.vesselMasterId, this.vesselName});

  factory SimilarVessel.fromJava(Map<String, dynamic> m) => SimilarVessel(
        match: JsonRead.stringOrNull(m['match']) ?? none,
        vesselMasterId: JsonRead.intOrNull(m['vesselMasterId']),
        vesselName: JsonRead.stringOrNull(m['vesselName']),
      );

  static const String same = 'SAME';
  static const String close = 'CLOSE';
  static const String none = 'NONE';

  final String match;
  final int? vesselMasterId;
  final String? vesselName;
}

/// One leg of `PUT /api/sale-orders/{id}/vessel-links`. An empty [vesselName] removes that leg's link.
class VesselLinkRequest {
  const VesselLinkRequest({required this.leg, required this.vesselName, this.vesselMasterId, this.ptpVesselCallId});

  final String leg;
  final String vesselName;
  final int? vesselMasterId;
  final int? ptpVesselCallId;

  Map<String, dynamic> toJava() => {
        'leg': leg,
        'vesselName': vesselName,
        'vesselMasterId': vesselMasterId,
        'ptpVesselCallId': ptpVesselCallId,
      };
}

/// A leg the links answer says is now linked; [linkedBy] is `PICKED`, `TYPED` or `MATCHED`.
class VesselLink {
  const VesselLink({required this.leg, this.vesselMasterId, this.vesselName, this.ptpVesselCallId, this.linkedBy, this.call});

  factory VesselLink.fromJava(Map<String, dynamic> m) => VesselLink(
        leg: JsonRead.string(m['leg']),
        vesselMasterId: JsonRead.intOrNull(m['vesselMasterId']),
        vesselName: JsonRead.stringOrNull(m['vesselName']),
        ptpVesselCallId: JsonRead.intOrNull(m['ptpVesselCallId']),
        linkedBy: JsonRead.stringOrNull(m['linkedBy']),
        call: m['call'] is Map ? PtpCall.fromJava(JsonRead.map(m['call'])) : null,
      );

  final String leg;
  final int? vesselMasterId;
  final String? vesselName;
  final int? ptpVesselCallId;
  final String? linkedBy;

  /// The linked PTP call as PTP lists it now, or null.
  final PtpCall? call;
}
