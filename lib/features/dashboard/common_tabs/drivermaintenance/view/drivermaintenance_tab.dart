import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/ui/premium.dart';

import '../../../../../core/di/injection.dart';
import '../bloc/drivermaintenance_bloc.dart';
import '../bloc/drivermaintenance_event.dart';
import '../bloc/drivermaintenance_state.dart';

const double kTabletBreak = 600;

/// The driver's Maintenance tab (premium look, owner 2026-10-29): how many papers to renew, then each truck and trailer
/// with every date and a clear status — Expired (red), Due by the office's date (amber), OK (green). The rule is the old
/// one: a date on or before the office's "expiry till" date (expDate, expApadBonam, expServiceAlignGreece) needs renewing.
class TruckMaintenanceDashboardWidget extends StatelessWidget {
  final bool showHeading;
  const TruckMaintenanceDashboardWidget({super.key, this.showHeading = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TruckMaintDashBloc>()..add(TruckMaintDashStarted()),
      child: TruckMaintDashView(showHeading: showHeading),
    );
  }
}

class TruckMaintDashView extends StatelessWidget {
  final bool showHeading;
  const TruckMaintDashView({super.key, this.showHeading = true});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Px.page,
      child: BlocBuilder<TruckMaintDashBloc, TruckMaintDashState>(
        builder: (context, state) {
          if (state is TruckMaintDashLoaded) return _Body(state: state, showHeading: showHeading);
          if (state is TruckMaintDashError) {
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

/// One date line: what it is, the date, which "renew by" date applies (null = a "last done" date, never due).
class MaintItem {
  const MaintItem(this.label, this.date, this.renewBy);

  final String label;
  final String date;
  final String? renewBy;
}

enum MaintStatus { expired, due, ok, none, done }

/// Expired before today; due when on or before [renewBy] (the old rule); a "last done" date is only shown. Pure (tested).
MaintStatus maintStatus(MaintItem item, DateTime today) {
  final d = _parse(item.date, 'yyyy/MM/dd');
  if (d == null) return MaintStatus.none;
  if (item.renewBy == null) return MaintStatus.done;
  if (d.isBefore(DateTime(today.year, today.month, today.day))) return MaintStatus.expired;
  final by = _parse(item.renewBy!, 'yyyy-MM-dd');
  if (by != null && !d.isAfter(by)) return MaintStatus.due;
  return MaintStatus.ok;
}

DateTime? _parse(String v, String pattern) {
  if (v.isEmpty || v == 'null') return null;
  try {
    return DateFormat(pattern).parseStrict(v);
  } catch (_) {
    return DateTime.tryParse(v);
  }
}

String _show(String v) {
  final d = _parse(v, 'yyyy/MM/dd');
  return d == null ? '' : DateFormat('dd MMM yyyy').format(d);
}

/// The three groups of one truck card.
List<(String, IconData, List<MaintItem>)> maintGroups(TruckDetailsModel t, TruckMaintDashLoaded s) => [
      ('Truck', Icons.local_shipping_rounded, [
        MaintItem('Rotex MY', t.RotexMyExp, s.expDate),
        MaintItem('Rotex SG', t.RotexSGExp, s.expDate),
        MaintItem('Puspakom', t.PuspacomExp, s.expDate),
        MaintItem('Insurance', t.InsuratnceExp, s.expDate),
        MaintItem('Bonam', t.BonamExp, s.expApadBonam),
        MaintItem('APAD', t.ApadExp, s.expApadBonam),
      ]),
      ('Trailer', Icons.rv_hookup_rounded, [
        MaintItem('Rotex MY', t.RotexMyExp1, s.expDate),
        MaintItem('Rotex SG', t.RotexSGExp1, s.expDate),
        MaintItem('Puspakom', t.PuspacomExp1, s.expDate),
      ]),
      ('Service', Icons.build_rounded, [
        MaintItem('Service due', t.ServiceExp, s.expServiceAlignGreece),
        MaintItem('Last service', t.ServiceLast, null),
        MaintItem('Alignment due', t.AlignmentExp, s.expServiceAlignGreece),
        MaintItem('Last alignment', t.AlignmentLast, null),
        MaintItem('Grease due', t.GreeceExp, s.expServiceAlignGreece),
        MaintItem('Last grease', t.GreeceLast, null),
        MaintItem('Gear oil due', t.GearOilExp, s.expServiceAlignGreece),
        MaintItem('Last gear oil', t.GearOilLast, null),
        MaintItem('PTP sticker', t.PTPStickerExp, s.expServiceAlignGreece),
      ]),
    ];

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.showHeading});

  final TruckMaintDashLoaded state;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    var expired = 0;
    var due = 0;
    for (final t in state.truckDetails) {
      for (final g in maintGroups(t, state)) {
        for (final i in g.$3) {
          final st = maintStatus(i, today);
          if (st == MaintStatus.expired) expired++;
          if (st == MaintStatus.due) due++;
        }
      }
    }
    final till = _parse(state.expDate, 'yyyy-MM-dd');
    return LayoutBuilder(builder: (context, c) {
      final side = c.maxWidth > kTabletBreak ? (c.maxWidth - 640) / 2 : 14.0;
      return ListView(
        padding: EdgeInsets.fromLTRB(side, 12, side, 28),
        children: [
          if (state.truckDetails.isEmpty)
            const PCard(child: PEmpty(icon: Icons.local_shipping_rounded, title: 'No truck data', subtitle: 'The office has not linked a truck to you yet.'))
          else ...[
            PHero(
              label: 'Papers to renew',
              value: '${expired + due}',
              footnote: till == null ? null : 'Due by ${DateFormat('dd MMM yyyy').format(till)}',
              icon: Icons.build_circle_rounded,
            ),
            const SizedBox(height: 10),
            PStatRow(children: [
              PStat(label: 'Expired', value: '$expired', icon: Icons.error_rounded, tone: expired > 0 ? Tone.red : Tone.green),
              PStat(label: 'Due soon', value: '$due', icon: Icons.schedule_rounded, tone: due > 0 ? Tone.amber : Tone.green),
            ]),
            for (final t in state.truckDetails) _TruckCard(truck: t, state: state, today: today),
          ],
        ],
      );
    });
  }
}

class _TruckCard extends StatelessWidget {
  const _TruckCard({required this.truck, required this.state, required this.today});

  final TruckDetailsModel truck;
  final TruckMaintDashLoaded state;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final groups = maintGroups(truck, state);
    return PCard(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const PIcon(Icons.local_shipping_rounded, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(truck.TruckNumber.isEmpty ? '—' : truck.TruckNumber, style: Px.t(18, weight: FontWeight.w800, spacing: -0.3)),
              Text(truck.TruckNumber1.isEmpty ? 'No trailer' : 'Trailer ${truck.TruckNumber1}', style: Px.small),
            ]),
          ),
          if (truck.TruckType.isNotEmpty) Flexible(child: PChip(truck.TruckType, tone: Tone.grey)),
        ]),
        for (final g in groups)
          if (g.$1 != 'Trailer' || truck.TruckNumber1.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(children: [
              Icon(g.$2, size: 16, color: Px.muted),
              const SizedBox(width: 6),
              Text(g.$1.toUpperCase(), style: Px.caps),
            ]),
            const SizedBox(height: 4),
            for (var i = 0; i < g.$3.length; i++) ...[
              if (i > 0) const PDivider(),
              _ItemRow(item: g.$3[i], status: maintStatus(g.$3[i], today)),
            ],
          ],
      ]),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.status});

  final MaintItem item;
  final MaintStatus status;

  @override
  Widget build(BuildContext context) {
    final chip = switch (status) {
      MaintStatus.expired => const PChip('Expired', tone: Tone.red, dot: true),
      MaintStatus.due => const PChip('Due', tone: Tone.amber, dot: true),
      MaintStatus.ok => const PChip('OK', tone: Tone.green, dot: true),
      MaintStatus.done => const PChip('Done', tone: Tone.grey),
      MaintStatus.none => const PChip('No date', tone: Tone.grey),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(flex: 5, child: Text(item.label, style: Px.t(14, color: Px.sub))),
        Expanded(
          flex: 5,
          child: Text(_show(item.date).isEmpty ? '—' : _show(item.date),
              textAlign: TextAlign.right,
              style: Px.t(14, weight: FontWeight.w700, color: status == MaintStatus.expired ? Px.red : Px.ink)),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 78, child: Align(alignment: Alignment.centerRight, child: chip)),
      ]),
    );
  }
}
