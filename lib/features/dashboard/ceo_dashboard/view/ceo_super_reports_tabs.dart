import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_super_reports_api.dart';
import 'ceo_details_sheet.dart';
import 'ceo_tab_kit.dart';
import 'ceo_widgets.dart';

/// Loads [load] for the current key and shows loading, the message with Retry, or [builder]; pull to refresh
/// asks again. A new key (another period) loads again.
class _Loader<T> extends StatefulWidget {
  const _Loader({super.key, required this.keyOf, required this.load, required this.builder, this.header});

  final String Function(BuildContext context) keyOf;
  final Future<T> Function(BuildContext context) load;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? header;

  @override
  State<_Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<_Loader<T>> {
  String? _key;
  Future<T>? _future;

  void _ensure(BuildContext context) {
    final key = widget.keyOf(context);
    if (key != _key || _future == null) {
      _key = key;
      _future = widget.load(context);
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.load(context));
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(
        buildWhen: (a, b) => a.period != b.period,
        builder: (context, _) {
          _ensure(context);
          final isTablet = MediaQuery.sizeOf(context).width >= 600;
          return RefreshIndicator(
            color: AppTokens.brandGradientStart,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 10, isTablet ? 20 : 12, 28),
              children: [
                if (widget.header != null) widget.header!,
                FutureBuilder<T>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return CeoErrorBox(message: '${snap.error}', onRetry: _refresh);
                    }
                    if (!snap.hasData) return const CeoSpinner();
                    return widget.builder(context, snap.data as T);
                  },
                ),
              ],
            ),
          );
        },
      );
}

String _rtis(int n) => '${ceoCount(n)} ${n == 1 ? 'RTI' : 'RTIs'}';

String _pct(num part, num whole) => whole <= 0 ? '0%' : '${(part * 100 / whole).toStringAsFixed(0)}%';

// ───────────────────────────────────────────────────────────── Forwarding ──

const _fwAccent = PanelAccent(
    start: Color(0xFF818CF8), end: Color(0xFF4F46E5), strong: Color(0xFF3730A3), soft: Color(0xFFE0E7FF));

/// Forwarding K1 / K2 / K3 / K8 of the CEO period (the web Super Admin "Forwarding" report): how many, how
/// many released (an exit reference is set) and how many are not released yet.
class CeoForwardingTab extends StatelessWidget {
  const CeoForwardingTab({super.key, required this.api, required this.companyId});

  final CeoSuperReportsApi api;
  final int companyId;

  static const _icons = {
    'K1': Icons.directions_boat_rounded,
    'K2': Icons.flight_takeoff_rounded,
    'K3': Icons.swap_horiz_rounded,
    'K8': Icons.local_shipping_rounded,
  };

  @override
  Widget build(BuildContext context) => _Loader<CeoForwarding>(
        header: const CeoPeriodBar(),
        keyOf: (c) => c.read<CeoDashboardCubit>().range.toString(),
        load: (c) {
          final (from, to) = c.read<CeoDashboardCubit>().range;
          return api.forwarding(companyId, fromDate: from, toDate: to);
        },
        builder: (context, f) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CeoHero(
            key: const Key('ceo_fw_hero'),
            title: 'Forwarding',
            subtitle: 'K1 · K2 · K3 · K8 in this period',
            icon: Icons.assignment_turned_in_rounded,
            accent: _fwAccent,
            value: ceoCount(f.count),
            sub: 'forwarding documents',
            facts: [
              ('Released', ceoCount(f.released)),
              ('Pending', ceoCount(f.notReleased)),
              ('Done', _pct(f.released, f.count)),
            ],
          ),
          const SizedBox(height: 12),
          CeoGrid(columns: 2, spacing: 10, children: [
            for (final s in f.stages) _stage(s),
          ]),
          const SizedBox(height: 10),
          Text('Released = an exit reference is entered; not released = none yet.',
              textAlign: TextAlign.center, style: AppTypography.badgeText(color: AppTokens.textMuted)),
        ]),
      );

  Widget _stage(CeoForwardingStage s) => Container(
        key: Key('ceo_fw_${s.name}'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTokens.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _fwAccent.soft),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: _fwAccent.soft, borderRadius: BorderRadius.circular(9)),
              child: Icon(_icons[s.name] ?? Icons.description_rounded, size: 17, color: _fwAccent.strong),
            ),
            const SizedBox(width: 8),
            Text(s.name, style: AppTypography.bodyLarge(color: _fwAccent.strong, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(ceoCount(s.count),
                style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: s.releasedShare,
              minHeight: 7,
              color: const Color(0xFF10B981),
              backgroundColor: const Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(height: 8),
          _line('Released', ceoCount(s.released), const Color(0xFF059669)),
          _line('Not released', ceoCount(s.notReleased), const Color(0xFFB45309)),
        ]),
      );

  Widget _line(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: AppTypography.badgeText(color: AppTokens.textMuted))),
          Text(value, style: AppTypography.bodySmall(color: color, fontWeight: FontWeight.w800)),
        ]),
      );
}

// ──────────────────────────────────────────────────────────── Performance ──

const _perfAccent = PanelAccent(
    start: Color(0xFFFBBF24), end: Color(0xFFD97706), strong: Color(0xFF92400E), soft: Color(0xFFFEF3C7));

/// The month's invoice sales per employee, most first (the web Super Admin "Performance" leaderboard).
class CeoPerformanceTab extends StatefulWidget {
  const CeoPerformanceTab({super.key, required this.api, required this.companyId});

  final CeoSuperReportsApi api;
  final int companyId;

  @override
  State<CeoPerformanceTab> createState() => _CeoPerformanceTabState();
}

class _CeoPerformanceTabState extends State<CeoPerformanceTab> {
  bool _lastMonth = false;

  DateTime _month(DateTime today) => _lastMonth ? DateTime(today.year, today.month - 1, 1) : today;

  static const _medals = [Color(0xFFF59E0B), Color(0xFF94A3B8), Color(0xFFB45309)];

  @override
  Widget build(BuildContext context) {
    final today = context.read<CeoDashboardCubit>().today;
    final month = _month(today);
    return _Loader<CeoLeaderboard>(
      key: ValueKey(_lastMonth),
      header: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CeoChips(
          key: const Key('ceo_perf_month'),
          options: const ['This month', 'Last month'],
          selected: _lastMonth ? 1 : 0,
          color: _perfAccent.strong,
          onChanged: (i) => setState(() => _lastMonth = i == 1),
        ),
      ),
      keyOf: (_) => '$_lastMonth',
      load: (_) => widget.api.leaderboard(widget.companyId, baseDate: Fmt.ymd(month)),
      builder: (context, b) {
        final top = b.employees.isEmpty ? 0.0 : b.employees.first.amount;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CeoHero(
            key: const Key('ceo_perf_hero'),
            title: 'Performance',
            subtitle: 'Invoice sales by employee · ${DateFormat('MMMM yyyy').format(month)}',
            icon: Icons.leaderboard_rounded,
            accent: _perfAccent,
            value: Fmt.rm(b.total),
            sub: '${ceoCount(b.employees.length)} employees',
            facts: [
              ('Top', b.employees.isEmpty ? '—' : b.employees.first.name),
              ('Invoices', ceoCount(b.employees.fold<int>(0, (a, e) => a + e.sales))),
            ],
          ),
          const SizedBox(height: 12),
          AccentPanel(
            title: 'Leaderboard',
            subtitle: 'Most sales first',
            icon: Icons.emoji_events_rounded,
            accent: _perfAccent,
            child: b.employees.isEmpty
                ? const CeoEmpty(text: 'No invoices this month')
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (var i = 0; i < b.employees.length; i++)
                      RankRow(
                        key: Key('ceo_perf_$i'),
                        lead: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i < 3 ? _medals[i] : _perfAccent.soft,
                            shape: BoxShape.circle,
                          ),
                          child: Text('${i + 1}',
                              style: AppTypography.badgeText(
                                  color: i < 3 ? Colors.white : _perfAccent.strong, fontWeight: FontWeight.w800)),
                        ),
                        title: b.employees[i].name.isEmpty ? '—' : b.employees[i].name,
                        subtitle: '${ceoCount(b.employees[i].sales)} sales · ${ceoShare(b.employees[i].amount, b.total)}',
                        value: Fmt.rm(b.employees[i].amount),
                        fraction: top <= 0 ? 0 : (b.employees[i].amount / top).clamp(0.0, 1.0),
                        color: _perfAccent.end,
                      ),
                  ]),
          ),
        ]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────── Driver salary ──

const _rtiAccent = PanelAccent(
    start: Color(0xFF2DD4BF), end: Color(0xFF0D9488), strong: Color(0xFF115E59), soft: Color(0xFFCCFBF1));

/// Driver RTIs of the CEO period (the web Super Admin "Driver Salary" report): totals, billed and zero-amount
/// RTIs, and each driver with the parts of their pay; a driver opens the breakdown.
class CeoDriverSalaryTab extends StatelessWidget {
  const CeoDriverSalaryTab({super.key, required this.api, required this.companyId});

  final CeoSuperReportsApi api;
  final int companyId;

  @override
  Widget build(BuildContext context) => _Loader<List<CeoRtiRow>>(
        header: const CeoPeriodBar(),
        keyOf: (c) => c.read<CeoDashboardCubit>().range.toString(),
        load: (c) {
          final (from, to) = c.read<CeoDashboardCubit>().range;
          return api.driverSalary(companyId, fromDate: from, toDate: to);
        },
        builder: (context, rows) {
          final drivers = CeoDriverSalary.group(rows);
          final amount = rows.fold<double>(0, (a, r) => a + r.amount);
          final salary = rows.fold<double>(0, (a, r) => a + r.salary);
          final zero = rows.where((r) => r.amount == 0).length;
          final billed = rows.length - zero;
          final top = drivers.fold<double>(0, (a, d) => d.amount > a ? d.amount : a);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CeoHero(
              key: const Key('ceo_rti_hero'),
              title: 'Driver salary',
              subtitle: 'RTIs in this period',
              icon: Icons.badge_rounded,
              accent: _rtiAccent,
              value: Fmt.rm(amount),
              sub: '${_rtis(rows.length)} · ${ceoCount(drivers.length)} ${drivers.length == 1 ? 'driver' : 'drivers'}',
              facts: [
                ('Salary', ceoCompact(salary)),
                ('Billed', '${ceoCount(billed)} · ${_pct(billed, rows.length)}'),
                ('No amount', '${ceoCount(zero)} · ${_pct(zero, rows.length)}'),
              ],
            ),
            const SizedBox(height: 10),
            CeoGrid(columns: 2, spacing: 10, children: [
              MiniStat(
                  label: 'Avg per billed RTI',
                  value: billed == 0 ? '—' : Fmt.rm(amount / billed),
                  color: _rtiAccent.strong),
              MiniStat(
                  label: 'Avg salary per RTI',
                  value: billed == 0 ? '—' : Fmt.rm(salary / billed),
                  color: _rtiAccent.strong),
            ]),
            const SizedBox(height: 12),
            AccentPanel(
              title: 'By driver',
              subtitle: 'Most RTIs first · tap for the breakdown',
              icon: Icons.person_pin_circle_rounded,
              accent: _rtiAccent,
              child: drivers.isEmpty
                  ? const CeoEmpty(text: 'No RTIs in this period')
                  : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      for (var i = 0; i < drivers.length; i++)
                        RankRow(
                          key: Key('ceo_rti_driver_$i'),
                          lead: CeoRankBadge(text: '${i + 1}', accent: _rtiAccent),
                          title: drivers[i].driverName,
                          subtitle: '${_rtis(drivers[i].rtis)} · salary ${Fmt.rm(drivers[i].salary)}',
                          value: Fmt.rm(drivers[i].amount),
                          trailingSub: drivers[i].zeroRtis == 0
                              ? null
                              : Text('${drivers[i].zeroRtis} no amount',
                                  maxLines: 1,
                                  style: AppTypography.badgeText(
                                      color: const Color(0xFFB45309), fontWeight: FontWeight.w700)),
                          fraction: top <= 0 ? 0 : (drivers[i].amount / top).clamp(0.0, 1.0),
                          color: _rtiAccent.end,
                          onTap: () => _showDriver(context, drivers[i]),
                        ),
                    ]),
            ),
          ]);
        },
      );

  static void _showDriver(BuildContext context, CeoDriverSalary d) => showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: AppTokens.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Palette.grey500, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Text(d.driverName, style: AppTypography.heading2(color: _rtiAccent.strong, fontWeight: FontWeight.w800)),
            Text('${_rtis(d.rtis)} · total ${Fmt.rm(d.amount)}',
                style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 12),
            for (final (label, value) in [
              ('Salary', d.salary),
              ('Pickup', d.pickup),
              ('Drop', d.drop),
              ('Sleeping', d.sleeping),
              ('Empty pickup', d.emptyPickup),
              ('Empty delivery', d.emptyDelivery),
              ('Manpower', d.manpower),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  Expanded(child: Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
                  Text(Fmt.rm(value),
                      style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                ]),
              ),
            const Divider(),
            Row(children: [
              Expanded(
                  child: Text('Total amount',
                      style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w800))),
              Text(Fmt.rm(d.amount),
                  style: AppTypography.bodyMedium(color: _rtiAccent.strong, fontWeight: FontWeight.w800)),
            ]),
            if (d.zeroRtis > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${_rtis(d.zeroRtis)} with no amount yet',
                    style: AppTypography.badgeText(color: const Color(0xFFB45309), fontWeight: FontWeight.w700)),
              ),
          ]),
        ),
      );
}
