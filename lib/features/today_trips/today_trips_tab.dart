import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/ui/premium.dart';
import 'package:maleva/features/dashboard/common_tabs/rtistatus/view/rtistatus_tab.dart';
import 'package:maleva/features/rti/list/widgets/rti_stop_times.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'driver_trip.dart';
import 'today_trips_text.dart';

const _cacheKey = 'today_trips_cache_v1';
const _cacheAtKey = 'today_trips_cache_at_v1';
const _malayKey = 'today_trips_malay_v1';

/// The driver's Today tab (owner 2026-10-28). Trips on their REAL day (the first stop's date, from the server), Yesterday ·
/// Today · Tomorrow; the day summary; the NEXT stop by time; each trip with its pickups, forwarding stops and deliveries
/// (each place once); what the office changed since the driver's last "Got it", and the Got it button; the last trips kept
/// on the phone for no signal; English or Bahasa Malaysia.
class TodayTripsTab extends StatefulWidget {
  const TodayTripsTab({super.key});

  @override
  State<TodayTripsTab> createState() => _TodayTripsTabState();
}

class _TodayTripsTabState extends State<TodayTripsTab> {
  /// -1 yesterday, 0 today, 1 tomorrow.
  int _offset = 0;
  bool _loading = true;
  String? _error;
  String? _offlineAt;
  bool _malay = false;
  List<DriverTrip> _trips = const [];

  TripText get _t => TripText(_malay);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _malay = prefs.getBool(_malayKey) ?? false);
    await _load();
  }

  /// Reads yesterday–tomorrow; keeps the answer on the phone; with no signal shows the last kept answer.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    try {
      final now = DateTime.now();
      final rows =
          await sl<RtiApi>().trips(isoDay(now.subtract(const Duration(days: 1))), isoDay(now.add(const Duration(days: 1))));
      await prefs.setString(_cacheKey, jsonEncode(rows));
      await prefs.setString(_cacheAtKey, now.toIso8601String());
      if (!mounted) return;
      setState(() {
        _trips = rows.map(DriverTrip.fromJava).toList();
        _offlineAt = null;
        _loading = false;
      });
    } catch (e) {
      final kept = prefs.getString(_cacheKey);
      final at = prefs.getString(_cacheAtKey);
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (kept != null) {
          _trips =
              (jsonDecode(kept) as List).whereType<Map>().map((m) => DriverTrip.fromJava(Map<String, dynamic>.from(m))).toList();
          _offlineAt = at == null || at.length < 16 ? '' : '${at.substring(8, 10)}/${at.substring(5, 7)} ${at.substring(11, 16)}';
        } else {
          _error = e is ApiFailure ? e.message : _t.loadFailed;
        }
      });
    }
  }

  Future<void> _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _malay = !_malay);
    await prefs.setBool(_malayKey, _malay);
  }

  Future<void> _gotIt(DriverTrip trip) async {
    try {
      await sl<RtiApi>().tripSeen(trip.rtiId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t.gotItSaved)));
      await _load();
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  String _dayOf(int offset) => isoDay(DateTime.now().add(Duration(days: offset)));

  @override
  Widget build(BuildContext context) {
    final t = _t;
    int count(int o) => _trips.where((x) => x.tripDay == _dayOf(o)).length;
    final day = _trips.where((x) => x.tripDay == _dayOf(_offset)).toList();
    final now = DateTime.now();
    final next = _offset == 0 ? nextStop(day, now) : null;
    return ColoredBox(
      color: Px.page,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            Row(children: [
              Expanded(
                child: PSegments(
                  labels: [
                    for (final o in const [-1, 0, 1])
                      '${o == -1 ? t.yesterday : o == 0 ? t.today : t.tomorrow} (${count(o)})'
                  ],
                  selected: _offset + 1,
                  onSelect: (i) => setState(() => _offset = i - 1),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Px.card,
                shape: const CircleBorder(side: BorderSide(color: Px.line)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleLanguage,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: Text(t.languageButton, style: Px.t(13, weight: FontWeight.w800, color: Px.brand))),
                  ),
                ),
              ),
            ]),
            if (_offlineAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: PCard(
                  color: Px.amberSoft,
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Icon(Icons.signal_wifi_off_rounded, size: 18, color: Px.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t.offline(_offlineAt!), style: Px.t(13, weight: FontWeight.w600, color: Px.amber))),
                  ]),
                ),
              ),
            const SizedBox(height: 14),
            if (_loading && _trips.isEmpty)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Px.brand))),
            if (_error != null)
              PCard(color: Px.redSoft, child: Text(_error!, style: Px.t(14, weight: FontWeight.w600, color: Px.red))),
            if (_offset == 0 && day.isNotEmpty) _NextBanner(next: next, text: t, onOpen: _openUri),
            if (day.isNotEmpty) _DaySummary(counts: countTrips(day), text: t),
            if (!_loading && _error == null && day.isEmpty)
              PCard(
                child: PEmpty(
                  icon: Icons.event_available_rounded,
                  title: _offset == 1 ? t.noTripTomorrow : t.noTripDay,
                ),
              ),
            for (final trip in day)
              _TripCard(trip: trip, text: t, today: _offset == 0, onGotIt: () => _gotIt(trip), onOpen: _openUri),
          ],
        ),
      ),
    );
  }

  Future<void> _openUri(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t.cannotOpen)));
    }
  }
}

Uri _mapUri(String place) => Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': place});

/// NEXT: the next place to go today, the brand hero card, with Map and Call.
class _NextBanner extends StatelessWidget {
  const _NextBanner({required this.next, required this.text, required this.onOpen});

  final ({DriverTrip trip, StopGroup group})? next;
  final TripText text;
  final Future<void> Function(Uri) onOpen;

  @override
  Widget build(BuildContext context) {
    final n = next;
    if (n == null) {
      return PCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          const PIcon(Icons.task_alt_rounded, tone: Tone.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text.allDone, style: Px.t(15, weight: FontWeight.w700))),
        ]),
      );
    }
    final g = n.group;
    final label = g.kind == 'PICKUP'
        ? text.pickUp
        : g.kind == 'DELIVERY'
            ? text.deliver
            : (g.activities.isEmpty ? text.forwarding : g.activities.first.replaceAll('_', ' '));
    final white70 = Colors.white.withValues(alpha: 0.78);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: Px.gradient,
        borderRadius: BorderRadius.circular(Px.radius),
        boxShadow: [BoxShadow(color: Px.brand.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
          child: Text('${text.next} · ${tripClock(g.time)} · $label',
              style: Px.t(12, weight: FontWeight.w700, color: Colors.white, spacing: 0.3)),
        ),
        const SizedBox(height: 10),
        Text(g.place.isEmpty ? text.noPlace : g.place,
            style: Px.t(19, weight: FontWeight.w800, color: Colors.white, height: 1.25, spacing: -0.3)),
        const SizedBox(height: 8),
        if (g.jobs > 0)
          Text(text.jobsList(g.jobs, g.jobNos.join(', ')), style: Px.t(13, weight: FontWeight.w600, color: Colors.white)),
        Text(
            n.trip.tripsThatDay > 1
                ? '${text.tripOf(n.trip.tripOfDay, n.trip.tripsThatDay)} · ${n.trip.rtiNo ?? ''}'
                : (n.trip.rtiNo ?? ''),
            style: Px.t(12, color: white70)),
        if (g.place.isNotEmpty || g.phones.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(children: [
            if (g.place.isNotEmpty)
              Expanded(child: _HeroButton(icon: Icons.map_rounded, label: 'Map', onTap: () => onOpen(_mapUri(g.place)))),
            if (g.place.isNotEmpty && g.phones.isNotEmpty) const SizedBox(width: 10),
            if (g.phones.isNotEmpty)
              Expanded(
                child: _HeroButton(
                    icon: Icons.call_rounded, label: 'Call', onTap: () => onOpen(Uri(scheme: 'tel', path: g.phones.first))),
              ),
          ]),
        ],
      ]),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: Px.brand),
              const SizedBox(width: 6),
              Text(label, style: Px.t(14, weight: FontWeight.w700, color: Px.brand)),
            ]),
          ),
        ),
      );
}

/// The day at a glance: trips, then pick up / deliver / forwarding as KPI tiles.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.counts, required this.text});

  final TripCounts counts;
  final TripText text;

  @override
  Widget build(BuildContext context) {
    final c = counts;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PSection(text.trips(c.trips), padding: const EdgeInsets.fromLTRB(2, 4, 2, 10)),
      PStatRow(children: [
        PStat(
            label: text.pickUp,
            value: '${c.pickupJobs}',
            icon: Icons.north_east_rounded,
            tone: Tone.blue,
            footnote: text.places(c.pickupPlaces)),
        PStat(
            label: text.deliver,
            value: '${c.deliveryJobs}',
            icon: Icons.south_west_rounded,
            tone: Tone.green,
            footnote: text.places(c.deliveryPlaces)),
        if (c.stops > 0)
          PStat(
              label: text.forwarding,
              value: '${c.stops}',
              icon: Icons.verified_user_rounded,
              tone: Tone.orange,
              footnote: text.stops(c.stops)),
      ]),
      const SizedBox(height: 14),
    ]);
  }
}

class _TripCard extends StatefulWidget {
  const _TripCard({required this.trip, required this.text, required this.today, required this.onGotIt, required this.onOpen});

  final DriverTrip trip;
  final TripText text;
  final bool today;
  final VoidCallback onGotIt;
  final Future<void> Function(Uri) onOpen;

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _showTimes = false;

  Future<void> _pdf() async {
    try {
      final url = await sl<RtiApi>().reportUrl(widget.trip.rtiId);
      await widget.onOpen(Uri.parse(url));
    } on ApiFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _status() {
    final t = widget.trip;
    void open(TripJob j) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RTIStatusPage(rtiDetails: [
              {'RtiId': t.rtiId, 'RTINo': t.rtiNo ?? '', 'JobId': j.jobId, 'JobNo': j.jobNo ?? ''},
            ])));
    if (t.jobs.length == 1) {
      open(t.jobs.first);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.symmetric(vertical: 8), children: [
          ListTile(title: Text(widget.text.whichJob, style: Px.title)),
          for (final j in t.jobs)
            ListTile(
              leading: const PIcon(Icons.photo_camera_rounded, size: 38),
              title: Text(j.jobNo ?? '', style: Px.t(15, weight: FontWeight.w700)),
              subtitle: Text(j.customer ?? '', style: Px.small),
              onTap: () {
                Navigator.pop(context);
                open(j);
              },
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final text = widget.text;
    final now = DateTime.now();
    return PCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          PChip(t.tripsThatDay > 1 ? text.tripOf(t.tripOfDay, t.tripsThatDay) : text.trip,
              tone: Tone.brand, icon: Icons.route_rounded),
          Text(t.rtiNo ?? '', style: Px.t(15, weight: FontWeight.w800)),
          if (t.truckName != null) PChip(t.truckName!, tone: Tone.grey, icon: Icons.local_shipping_rounded),
        ]),
        if (tripRoute(t).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(tripRoute(t), style: Px.t(15, weight: FontWeight.w700, height: 1.35)),
          ),
        if ((t.remarks ?? '').trim().isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text(t.remarks!.trim(), style: Px.t(13, color: Px.sub))),
        if (needsGotIt(t)) _ChangesBox(trip: t, text: text, onGotIt: widget.onGotIt),
        const SizedBox(height: 14),
        _TripTotals(trip: t, text: text),
        _Section(
            title: text.pickUpTitle,
            tone: Tone.blue,
            icon: Icons.north_east_rounded,
            groups: groupStops(t, 'PICKUP'),
            text: text,
            now: widget.today ? now : null,
            onOpen: widget.onOpen),
        _Section(
            title: text.forwardingTitle,
            tone: Tone.orange,
            icon: Icons.verified_user_rounded,
            groups: groupStops(t, 'STOP'),
            text: text,
            now: widget.today ? now : null,
            onOpen: widget.onOpen),
        _Section(
            title: text.deliverTitle,
            tone: Tone.green,
            icon: Icons.south_west_rounded,
            groups: groupStops(t, 'DELIVERY'),
            text: text,
            now: widget.today ? now : null,
            onOpen: widget.onOpen),
        const SizedBox(height: 16),
        const PDivider(),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _ActionButton(
                icon: Icons.photo_camera_rounded, label: text.photos, primary: true, onTap: t.jobs.isEmpty ? null : _status),
          ),
          const SizedBox(width: 8),
          Expanded(child: _ActionButton(icon: Icons.picture_as_pdf_rounded, label: text.rtiPdf, onTap: _pdf)),
        ]),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.schedule_rounded,
          label: _showTimes ? text.hideTimes : text.timeOnSite,
          onTap: () => setState(() => _showTimes = !_showTimes),
        ),
        if (_showTimes) RtiStopTimes(key: ValueKey('times-${t.rtiId}'), rtiId: t.rtiId, canTap: true),
      ]),
    );
  }
}

/// A rounded action: navy filled (primary) or white with a hairline.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.primary = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Colors.white : Px.ink;
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: primary ? Px.brand : Px.card,
        shape: StadiumBorder(side: BorderSide(color: primary ? Px.brand : Px.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: primary ? Colors.white : Px.brand),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(14, weight: FontWeight.w700, color: fg)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// What the office changed since the driver's last "Got it" (amber), or a trip not checked yet (blue), with Got it.
class _ChangesBox extends StatelessWidget {
  const _ChangesBox({required this.trip, required this.text, required this.onGotIt});

  final DriverTrip trip;
  final TripText text;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    final changed = trip.changes.isNotEmpty;
    final tone = changed ? Tone.amber : Tone.blue;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tone.fg.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PIcon(changed ? Icons.edit_note_rounded : Icons.fiber_new_rounded, tone: tone, size: 34),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(changed ? text.changedByOffice : text.newTrip, style: Px.t(14, weight: FontWeight.w700, color: tone.fg))),
          if (!changed) ...[const SizedBox(width: 8), _gotItButton()],
        ]),
        for (final c in trip.changes)
          for (final line in c.lines)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 44),
              child: Text('${tripClock(c.at)}  $line', style: Px.t(13, weight: FontWeight.w600)),
            ),
        if (changed) ...[
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: _gotItButton()),
        ],
      ]),
    );
  }

  Widget _gotItButton() => FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Px.brand,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: onGotIt,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: Text(text.gotIt, style: Px.t(14, weight: FontWeight.w700, color: Colors.white)),
      );
}

/// Three soft tiles on a trip: pick up, forwarding, deliver — jobs and places.
class _TripTotals extends StatelessWidget {
  const _TripTotals({required this.trip, required this.text});

  final DriverTrip trip;
  final TripText text;

  @override
  Widget build(BuildContext context) {
    final c = countTrips([trip]);
    Widget box(String label, String value, Tone tone) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, style: Px.t(11, weight: FontWeight.w800, color: tone.fg, spacing: 0.4))),
              const SizedBox(height: 4),
              Text(value, textAlign: TextAlign.center, style: Px.t(13, weight: FontWeight.w700, height: 1.25)),
            ]),
          ),
        );
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      box(text.pickUpTitle, text.jobsAtPlaces(c.pickupJobs, c.pickupPlaces), Tone.blue),
      if (c.stops > 0) box(text.forwarding.toUpperCase(), text.stops(c.stops), Tone.orange),
      box(text.deliverTitle, text.jobsAtPlaces(c.deliveryJobs, c.deliveryPlaces), Tone.green),
    ]);
  }
}

/// One section of the trip: each place once, numbered, in time order, as a timeline; places behind us (today) faded.
class _Section extends StatelessWidget {
  const _Section(
      {required this.title,
      required this.tone,
      required this.icon,
      required this.groups,
      required this.text,
      required this.now,
      required this.onOpen});

  final String title;
  final Tone tone;
  final IconData icon;
  final List<StopGroup> groups;
  final TripText text;
  final DateTime? now;
  final Future<void> Function(Uri) onOpen;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PIcon(icon, tone: tone, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$title (${text.places(groups.length)})',
                style: Px.t(13, weight: FontWeight.w800, color: tone.fg, spacing: 0.4)),
          ),
        ]),
        const SizedBox(height: 6),
        for (var i = 0; i < groups.length; i++)
          _PlaceRow(
            number: i + 1,
            last: i == groups.length - 1,
            group: groups[i],
            tone: tone,
            text: text,
            past: now != null && isPast(groups[i], now!),
            onOpen: onOpen,
          ),
      ]),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow(
      {required this.number,
      required this.last,
      required this.group,
      required this.tone,
      required this.text,
      required this.past,
      required this.onOpen});

  final int number;
  final bool last;
  final StopGroup group;
  final Tone tone;
  final TripText text;
  final bool past;
  final Future<void> Function(Uri) onOpen;

  @override
  Widget build(BuildContext context) {
    final g = group;
    final isStop = g.kind == 'STOP';
    final detail = Px.t(13, color: Px.sub, height: 1.35);
    return Opacity(
      opacity: past ? 0.45 : 1,
      // the timeline: a thin line down the left, the number in a tone circle; the card sets the height
      child: Stack(children: [
        if (!last) Positioned(left: 11, top: 20, bottom: 0, child: Container(width: 2, color: tone.fg.withValues(alpha: 0.18))),
        Positioned(
          left: 0,
          top: 14,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle),
            child: Center(child: Text('$number', style: Px.t(12, weight: FontWeight.w800, color: Colors.white))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Container(
            margin: const EdgeInsets.only(top: 6, bottom: 4),
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            decoration:
                BoxDecoration(color: Px.soft, borderRadius: BorderRadius.circular(14), border: Border.all(color: Px.line)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PChip(tripClock(g.time), tone: tone, icon: Icons.schedule_rounded),
                  const SizedBox(height: 6),
                  Text(g.place.isEmpty ? text.noPlace : g.place, style: Px.t(15, weight: FontWeight.w700, height: 1.3)),
                  if (isStop && g.activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(g.activities.map((a) => a.replaceAll('_', ' ').replaceAll(',', ' + ')).join(', '),
                          style: Px.t(13, weight: FontWeight.w700, color: tone.fg)),
                    ),
                  if (!isStop && g.jobs > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(text.jobsList(g.jobs, g.jobNos.join(', ')), style: Px.t(13, weight: FontWeight.w600)),
                    ),
                  if (g.customers.isNotEmpty) Text(g.customers.join(', '), style: detail),
                  if (g.quantities.isNotEmpty) Text('${text.qty}: ${g.quantities.join(' + ')}', style: detail),
                  if (g.vessels.isNotEmpty) Text('${text.vessel}: ${g.vessels.join(', ')}', style: detail),
                  if (isStop && g.agents.isNotEmpty) Text('${text.agent}: ${g.agents.join(', ')}', style: detail),
                  if (!isStop && g.pics.isNotEmpty) Text('${text.pic}: ${g.pics.join(' / ')}', style: detail),
                ]),
              ),
              Column(children: [
                if (g.place.isNotEmpty)
                  _RoundIcon(icon: Icons.map_rounded, tone: Tone.blue, onTap: () => onOpen(_mapUri(g.place))),
                if (g.phones.isNotEmpty)
                  _RoundIcon(
                      icon: Icons.call_rounded, tone: Tone.green, onTap: () => onOpen(Uri(scheme: 'tel', path: g.phones.first))),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.tone, required this.onTap});

  final IconData icon;
  final Tone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: Material(
          color: tone.bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: tone.fg)),
          ),
        ),
      );
}
