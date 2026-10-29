import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/ui/premium.dart';

import '../../../../../core/di/injection.dart';
import '../bloc/driverlicense_bloc.dart';
import '../bloc/driverlicense_event.dart';
import '../bloc/driverlicense_state.dart';

const double kTabletBreak = 600;

// All 11 field keys shown in each driver card (label + Java field of /api/master-reports/drivers/rows)
const List<(String, String)> kDriverFields = [
  ('License', 'licenseExp'),
  ('GDL', 'gdlExp'),
  ('Kuantan Port', 'kuantanPort'),
  ('Northport', 'northportPort'),
  ('PKFZ Port', 'pkfzPort'),
  ('KLIA Port', 'kliaPort'),
  ('PGU Port', 'pguPort'),
  ('Tanjung Port', 'tanjungPort'),
  ('Penang Port', 'penangPort'),
  ('PTP Port', 'ptpPort'),
  ('Westport', 'westportPort'),
];

/// A licence or port pass date from the Java row (ISO, or dd/MM/yyyy), or null.
DateTime? licenseDate(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  final iso = DateTime.tryParse(s.replaceAll('/', '-'));
  if (iso != null) return iso;
  try {
    return DateFormat('dd/MM/yyyy').parseStrict(s);
  } catch (_) {
    return null;
  }
}

/// The driver's Truck License tab (premium look, owner 2026-10-29): how many licences and port passes to renew, then
/// each date with Expired / days left / Valid. Read only.
class DriverLicenseExpiryWidget extends StatelessWidget {
  const DriverLicenseExpiryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverLicenseExpiryBloc>()..add(DriverLicenseExpiryStarted()),
      child: const _DriverLicenseExpiryView(),
    );
  }
}

class _DriverLicenseExpiryView extends StatelessWidget {
  const _DriverLicenseExpiryView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Px.page,
      child: BlocBuilder<DriverLicenseExpiryBloc, DriverLicenseExpiryState>(
        builder: (context, state) {
          if (state is DriverLicenseExpiryLoaded) return _Body(state: state);
          if (state is DriverLicenseExpiryError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PCard(color: Px.redSoft, child: Text(state.message, style: Px.t(14, weight: FontWeight.w600, color: Px.red))),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: Px.brand));
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final DriverLicenseExpiryLoaded state;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    var expired = 0, soon = 0, valid = 0;
    (String, DateTime)? next;
    for (final item in state.driverExpiryList) {
      for (final f in kDriverFields) {
        final d = licenseDate(item[f.$2]);
        switch (expiryOf(d, today)) {
          case Expiry.expired:
            expired++;
          case Expiry.soon:
            soon++;
          case Expiry.valid:
            valid++;
          case Expiry.none:
            break;
        }
        if (d != null && !d.isBefore(DateTime(today.year, today.month, today.day)) && (next == null || d.isBefore(next.$2))) {
          next = (f.$1, d);
        }
      }
    }
    return LayoutBuilder(builder: (context, c) {
      final side = c.maxWidth > kTabletBreak ? (c.maxWidth - 640) / 2 : 14.0;
      return ListView(
        padding: EdgeInsets.fromLTRB(side, 12, side, 28),
        children: [
          if (state.driverExpiryList.isEmpty)
            const PCard(child: PEmpty(icon: Icons.badge_rounded, title: 'No licence records', subtitle: 'The office has not added your dates yet.'))
          else ...[
            PHero(
              label: 'To renew (next 30 days)',
              value: '${expired + soon}',
              footnote: next == null
                  ? 'Nothing coming up'
                  : 'Next: ${next.$1} on ${DateFormat('dd MMM yyyy').format(next.$2)}',
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 10),
            PStatRow(children: [
              PStat(label: 'Expired', value: '$expired', icon: Icons.error_rounded, tone: expired > 0 ? Tone.red : Tone.green),
              PStat(label: 'Soon', value: '$soon', icon: Icons.schedule_rounded, tone: soon > 0 ? Tone.amber : Tone.green),
              PStat(label: 'Valid', value: '$valid', icon: Icons.verified_rounded, tone: Tone.green),
            ]),
            for (final item in state.driverExpiryList) _DriverCard(item: item, today: today),
          ],
        ],
      );
    });
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.item, required this.today});

  final dynamic item; // Map<String, dynamic>
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final name = (item['driverName'] ?? '').toString();
    final initials = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    return PCard(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(gradient: Px.gradient, shape: BoxShape.circle),
            child: Center(child: Text(initials.isEmpty ? '?' : initials, style: Px.t(15, weight: FontWeight.w800, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.isEmpty ? '—' : name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Px.t(16, weight: FontWeight.w800)),
              Text('Licence and port passes', style: Px.small),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        for (var i = 0; i < kDriverFields.length; i++) ...[
          if (i > 0) const PDivider(),
          _Row(label: kDriverFields[i].$1, date: licenseDate(item[kDriverFields[i].$2]), today: today),
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.date, required this.today});

  final String label;
  final DateTime? date;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final e = expiryOf(date, today);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(flex: 5, child: Text(label, style: Px.t(14, color: Px.sub))),
        Expanded(
          flex: 5,
          child: Text(date == null ? '—' : DateFormat('dd MMM yyyy').format(date!),
              textAlign: TextAlign.right,
              style: Px.t(14, weight: FontWeight.w700, color: e == Expiry.expired ? Px.red : Px.ink)),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: Align(alignment: Alignment.centerRight, child: PChip(e.label(date, today), tone: e.tone, dot: e != Expiry.none)),
        ),
      ]),
    );
  }
}
