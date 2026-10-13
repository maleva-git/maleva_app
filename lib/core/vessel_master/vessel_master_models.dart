import 'package:maleva/core/utils/json_read.dart';

/// The two sides of a sale order as the vessel APIs name them: `LOADING` (L side:
/// `loadingvesselname`, ETA/ETB/ETD, L SCN, L port) and `OFF` (O side: `offvesselname`,
/// OETA/OETB/OETD, O SCN, O port).
class VesselLeg {
  VesselLeg._();

  static const String loading = 'LOADING';
  static const String off = 'OFF';
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
      );

  final int id;
  final String? port;
  final String vesselName;
  final String? vesselCode;
  final String? lineId;
  final String? voyage;

  /// Null when PTP says None.
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
