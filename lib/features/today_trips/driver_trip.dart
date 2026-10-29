import 'package:maleva/core/utils/json_read.dart';

/// One stop of a trip (Java `DriverTrip.Stop`, read as it is): PICKUP / DELIVERY of a job, or STOP (seal, break seal,
/// K-form … with the agent).
class TripStop {
  const TripStop({
    required this.kind,
    this.stopId,
    this.time,
    this.place,
    this.jobId,
    this.jobNo,
    this.customer,
    this.quantity,
    this.pic,
    this.activity,
    this.agentName,
    this.agentMobile,
    this.vessel,
  });

  final String kind;
  final int? stopId;
  final String? time;
  final String? place;
  final int? jobId;
  final String? jobNo;
  final String? customer;
  final String? quantity;
  final String? pic;
  final String? activity;
  final String? agentName;
  final String? agentMobile;
  final String? vessel;

  factory TripStop.fromJava(Map<String, dynamic> j) => TripStop(
        kind: j['kind'] as String? ?? '',
        stopId: (j['stopId'] as num?)?.toInt(),
        time: j['time'] as String?,
        place: j['place'] as String?,
        jobId: (j['jobId'] as num?)?.toInt(),
        jobNo: j['jobNo'] as String?,
        customer: j['customer'] as String?,
        quantity: j['quantity'] as String?,
        pic: j['pic'] as String?,
        activity: j['activity'] as String?,
        agentName: j['agentName'] as String?,
        agentMobile: j['agentMobile'] as String?,
        vessel: j['vessel'] as String?,
      );
}

/// One job line of the trip (for the photo status).
class TripJob {
  const TripJob({required this.lineId, required this.jobId, this.jobNo, this.customer});

  final int lineId;
  final int jobId;
  final String? jobNo;
  final String? customer;

  factory TripJob.fromJava(Map<String, dynamic> j) => TripJob(
        lineId: (j['lineId'] as num?)?.toInt() ?? 0,
        jobId: (j['jobId'] as num?)?.toInt() ?? 0,
        jobNo: j['jobNo'] as String?,
        customer: j['customer'] as String?,
      );
}

/// One RTI as the driver's trip (Java `DriverTrip`): its real day is the first stop's date, not the RTI date.
class DriverTrip {
  const DriverTrip({
    required this.rtiId,
    this.rtiNo,
    required this.tripDay,
    this.firstTime,
    this.truckName,
    this.destination,
    this.remarks,
    required this.tripOfDay,
    required this.tripsThatDay,
    required this.stops,
    required this.jobs,
    this.seenAt,
    this.changes = const [],
  });

  final int rtiId;
  final String? rtiNo;
  final String tripDay;
  final String? firstTime;
  final String? truckName;
  final String? destination;
  final String? remarks;
  final int tripOfDay;
  final int tripsThatDay;
  final List<TripStop> stops;
  final List<TripJob> jobs;

  /// When the driver last tapped "Got it" (null = never).
  final String? seenAt;

  /// What the office changed after that (newest last).
  final List<TripChange> changes;

  factory DriverTrip.fromJava(Map<String, dynamic> j) => DriverTrip(
        rtiId: (j['rtiId'] as num?)?.toInt() ?? 0,
        rtiNo: j['rtiNo'] as String?,
        tripDay: (j['tripDay'] as String?) ?? '',
        firstTime: j['firstTime'] as String?,
        truckName: j['truckName'] as String?,
        destination: j['destination'] as String?,
        remarks: j['remarks'] as String?,
        tripOfDay: (j['tripOfDay'] as num?)?.toInt() ?? 1,
        tripsThatDay: (j['tripsThatDay'] as num?)?.toInt() ?? 1,
        stops: JsonRead.listOfMaps(j['stops']).map(TripStop.fromJava).toList(),
        jobs: JsonRead.listOfMaps(j['jobs']).map(TripJob.fromJava).toList(),
        seenAt: j['seenAt'] as String?,
        changes: JsonRead.listOfMaps(j['changes']).map(TripChange.fromJava).toList(),
      );
}

/// A change the office made after the driver's last "Got it" (Java `DriverTrip.Change`).
class TripChange {
  const TripChange({this.at, required this.lines});

  final String? at;
  final List<String> lines;

  factory TripChange.fromJava(Map<String, dynamic> j) => TripChange(
        at: j['at'] as String?,
        lines: (j['lines'] as List?)?.map((e) => '$e').where((e) => e.trim().isNotEmpty).toList() ?? const [],
      );
}

/// The trip needs the driver's "Got it": never seen, or changed after he saw it.
bool needsGotIt(DriverTrip t) => t.seenAt == null || t.changes.isNotEmpty;

/// The next place to go today by time: the first stop (pickup, forwarding, delivery) not more than [grace] behind now.
/// Null when everything is behind or nothing has a time.
({DriverTrip trip, StopGroup group})? nextStop(List<DriverTrip> today, DateTime now, {Duration grace = const Duration(minutes: 30)}) {
  ({DriverTrip trip, StopGroup group})? best;
  DateTime? bestAt;
  for (final t in today) {
    for (final kind in const ['PICKUP', 'STOP', 'DELIVERY']) {
      for (final g in groupStops(t, kind)) {
        final at = g.time == null ? null : DateTime.tryParse(g.time!);
        if (at == null || at.isBefore(now.subtract(grace))) continue;
        if (bestAt == null || at.isBefore(bestAt)) {
          best = (trip: t, group: g);
          bestAt = at;
        }
      }
    }
  }
  return best;
}

/// The stop is behind us (more than [grace] before now): shown grey.
bool isPast(StopGroup g, DateTime now, {Duration grace = const Duration(minutes: 30)}) {
  final at = g.time == null ? null : DateTime.tryParse(g.time!);
  return at != null && at.isBefore(now.subtract(grace));
}

/// "07:00" from "2026-10-29T07:00:00"; "--:--" for no time (00:00 = a date typed without a time).
String tripClock(String? iso) {
  if (iso == null || iso.length < 16) return '--:--';
  final hm = iso.substring(11, 16);
  return hm == '00:00' ? '--:--' : hm;
}

/// The phone numbers written in a PIC text ("Ms. Lew 017-4152233 / Koko 011-26264962", "HP:+60 16-640 1934").
List<String> phonesIn(String? text) {
  if (text == null) return const [];
  final found = RegExp(r'(\+?6?0[\d\s-]{7,13}\d|\+?\d[\d\s-]{8,14}\d)').allMatches(text);
  return found
      .map((m) => m.group(0)!.replaceAll(RegExp(r'[\s-]'), ''))
      .where((p) => p.replaceAll('+', '').length >= 9)
      .toSet()
      .toList();
}

/// "WESTPORT (+1) → KLANG": the first pickup place and the last delivery place, with how many more places there are.
String tripRoute(DriverTrip t) {
  final pick = groupStops(t, 'PICKUP');
  final drop = groupStops(t, 'DELIVERY');
  String? side(List<StopGroup> g, bool last) {
    final places = g.where((x) => x.place.isNotEmpty).toList();
    if (places.isEmpty) return null;
    final shown = last ? places.last.place : places.first.place;
    return places.length > 1 ? '$shown (+${places.length - 1})' : shown;
  }
  return [side(pick, false), side(drop, true)].whereType<String>().join(' → ');
}

/// yyyy-MM-dd of a date.
String isoDay(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// The same place, with the case, spaces and commas removed (two rows "WESTPORT " / "Westport" are one place).
String placeKey(String? place) => (place ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// One place of a trip for one kind (pickup / delivery / forwarding stop), with every job done there.
class StopGroup {
  StopGroup({required this.kind, required this.place});

  final String kind;
  final String place;
  String? time;
  final List<String> jobNos = [];
  final List<String> customers = [];
  final List<String> quantities = [];
  final List<String> pics = [];
  final List<String> activities = [];
  final List<String> agents = [];
  final List<String> phones = [];
  final List<String> vessels = [];

  int get jobs => jobNos.length;

  void _add(List<String> list, String? value) {
    final v = (value ?? '').trim();
    if (v.isNotEmpty && !list.contains(v)) list.add(v);
  }
}

/// The trip's places of one kind ('PICKUP', 'DELIVERY' or 'STOP'), each place once, in time order (earliest time).
List<StopGroup> groupStops(DriverTrip trip, String kind) {
  final groups = <String, StopGroup>{};
  for (final s in trip.stops.where((s) => s.kind == kind)) {
    final key = kind == 'STOP' ? '${placeKey(s.place)}|${s.activity ?? ''}' : placeKey(s.place);
    final g = groups.putIfAbsent(key, () => StopGroup(kind: kind, place: (s.place ?? '').trim()));
    if (tripClock(s.time) != '--:--' && (g.time == null || s.time!.compareTo(g.time!) < 0)) g.time = s.time;
    g._add(g.jobNos, s.jobNo);
    g._add(g.customers, s.customer);
    g._add(g.quantities, s.quantity);
    g._add(g.pics, s.pic);
    g._add(g.activities, s.activity);
    g._add(g.agents, s.agentName);
    g._add(g.vessels, s.vessel);
    for (final p in phonesIn(kind == 'STOP' ? s.agentMobile : s.pic)) {
      g._add(g.phones, p);
    }
  }
  final list = groups.values.toList()
    ..sort((a, b) => (a.time ?? '9999').compareTo(b.time ?? '9999'));
  return list;
}

/// What a trip (or a day) holds: jobs and places to pick up and to deliver, forwarding stops.
class TripCounts {
  const TripCounts({
    required this.trips,
    required this.pickupJobs,
    required this.pickupPlaces,
    required this.deliveryJobs,
    required this.deliveryPlaces,
    required this.stops,
  });

  final int trips;
  final int pickupJobs;
  final int pickupPlaces;
  final int deliveryJobs;
  final int deliveryPlaces;
  final int stops;
}

/// Counted once: a job picked up at two rows of the same place is one job; the same place twice is one place.
TripCounts countTrips(List<DriverTrip> trips) {
  var pj = 0, pp = 0, dj = 0, dp = 0, st = 0;
  for (final t in trips) {
    final pick = groupStops(t, 'PICKUP');
    final drop = groupStops(t, 'DELIVERY');
    pp += pick.length;
    dp += drop.length;
    pj += t.stops.where((s) => s.kind == 'PICKUP').map((s) => s.jobId ?? s.jobNo).toSet().length;
    dj += t.stops.where((s) => s.kind == 'DELIVERY').map((s) => s.jobId ?? s.jobNo).toSet().length;
    st += groupStops(t, 'STOP').length;
  }
  return TripCounts(trips: trips.length, pickupJobs: pj, pickupPlaces: pp, deliveryJobs: dj, deliveryPlaces: dp, stops: st);
}

/// "3 jobs at 2 places" / "1 job at 1 place".
String jobsAtPlaces(int jobs, int places) =>
    '$jobs job${jobs == 1 ? '' : 's'} at $places place${places == 1 ? '' : 's'}';
