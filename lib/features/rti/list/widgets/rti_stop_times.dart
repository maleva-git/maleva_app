import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// "09:12" from "2026-10-01T09:12:00"; "" when empty.
String siteVisitClock(String? iso) => iso == null || iso.length < 16 ? '' : iso.substring(11, 16);

/// 150 → "2 h 30", 45 → "45 min".
String siteVisitDuration(int? minutes) {
  if (minutes == null) return '';
  if (minutes < 60) return '$minutes min';
  final m = minutes % 60;
  return m == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h ${m.toString().padLeft(2, '0')}';
}

/// One line for a stop, as on the web: "Arrived 09:12 · Left 11:40 · 2 h 28 · waited 50 min", or why there is no time.
String siteVisitLine(SiteVisit v) {
  switch (v.status) {
    case 'MATCHED':
      final parts = ['Arrived ${siteVisitClock(v.arrived)}', v.left == null ? 'Still there' : 'Left ${siteVisitClock(v.left)}'];
      if (v.minutes != null) parts.add(siteVisitDuration(v.minutes));
      if (v.waitingMinutes != null) parts.add('waited ${siteVisitDuration(v.waitingMinutes)}');
      return parts.join(' · ');
    case 'NO_PIN':
      return 'Address not pinned';
    case 'NO_GPS':
      return 'No GPS for the truck';
    case 'NOT_SEEN':
      return 'Truck not seen there yet';
    default:
      return 'Not measured yet';
  }
}

/// The driver's next tap at a stop, in order: check in at the gate → start loading / unloading → done. Null = nothing
/// left to tap (or the truck has already left).
({String action, String label})? siteVisitNextTap(SiteVisit v) {
  if (v.left != null && v.checkIn == null) return null;
  if (v.checkIn == null) return (action: 'check-in', label: 'Check in at gate');
  if (v.workStart == null) return (action: 'work-start', label: v.kind == 'PICKUP' ? 'Start loading' : 'Start unloading');
  if (v.done == null) return (action: 'done', label: 'Done');
  return null;
}

/// Fleet W5 waiting-time proof on the RTI preview: each pickup / delivery with when the truck arrived and left (GPS), and,
/// for the driver, the next tap: "Check in at gate" (the server checks the truck's GPS), then "Start loading" /
/// "Start unloading", then "Done". The customer is billed for waiting from check-in (or the appointment) to start, so
/// tap each one at the moment it happens. Shows nothing when the server has no stops (w5-01 not run).
class RtiStopTimes extends StatefulWidget {
  const RtiStopTimes({super.key, required this.rtiId, required this.canTap});

  final int rtiId;

  /// The driver's own RTI: the start button is shown.
  final bool canTap;

  @override
  State<RtiStopTimes> createState() => _RtiStopTimesState();
}

class _RtiStopTimesState extends State<RtiStopTimes> {
  late Future<List<SiteVisit>> _visits;
  bool _tapsOn = false;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _visits = _load();
    // the buttons appear only when the office has switched the driver taps on (until then GPS alone measures waiting)
    if (widget.canTap) {
      sl<RtiApi>().siteVisitTapsOn().then((on) {
        if (mounted && on) setState(() => _tapsOn = true);
      });
    }
  }

  Future<List<SiteVisit>> _load() async {
    try {
      return await sl<RtiApi>().siteVisits(widget.rtiId);
    } catch (_) {
      return const [];   // time on site is extra information: the preview works without it
    }
  }

  Future<void> _tap(SiteVisit v, String action) async {
    final key = '${v.kind}-${v.stopId}';
    setState(() => _busy.add(key));
    try {
      final result = await sl<RtiApi>().siteVisitTap(action, v.kind, v.stopId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      setState(() => _visits = _load());
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return FutureBuilder<List<SiteVisit>>(
      future: _visits,
      builder: (context, snap) {
        final visits = snap.data ?? const <SiteVisit>[];
        if (visits.isEmpty) return const SizedBox.shrink();
        final label = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          Text('STOPS (${visits.length})', style: label),
          const SizedBox(height: 8),
          for (final v in visits)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: mc.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: mc.outline),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${v.kind == 'PICKUP' ? 'Pickup' : 'Delivery'}${v.jobNo == null ? '' : ' · ${v.jobNo}'}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: context.cs.primary)),
                    if ((v.place ?? '').isNotEmpty) Text(v.place!, style: TextStyle(color: mc.muted)),
                    Text(siteVisitLine(v), style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (v.checkIn != null)
                      Text('Checked in ${siteVisitClock(v.checkIn)}${v.checkInVerified == false ? ' (not at the gate)' : ''}',
                          style: TextStyle(color: v.checkInVerified == false ? Colors.red.shade700 : mc.muted)),
                    if (v.workStart != null) Text('Started ${siteVisitClock(v.workStart)}', style: TextStyle(color: mc.muted)),
                    if (v.done != null) Text('Done ${siteVisitClock(v.done)}', style: TextStyle(color: mc.muted)),
                  ]),
                ),
                if (widget.canTap && _tapsOn && siteVisitNextTap(v) != null)
                  FilledButton(
                    onPressed: _busy.contains('${v.kind}-${v.stopId}') ? null : () => _tap(v, siteVisitNextTap(v)!.action),
                    child: Text(siteVisitNextTap(v)!.label),
                  ),
              ]),
            ),
        ]);
      },
    );
  }
}
