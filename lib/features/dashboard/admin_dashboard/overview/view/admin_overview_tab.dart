import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/status_tone.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/view/vesselplanningweb_tab.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/planning/plans/view/plans_page.dart';
import 'package:maleva/features/truck_location/presentation/truck_location_routes.dart';

import '../bloc/admin_overview_cubit.dart';
import '../data/admin_overview_repository.dart';
import 'overview_widgets.dart';

/// The admin dashboard tabs the Overview's buttons switch to, by their tab-bar label.
abstract final class OverviewTabLinks {
  static const salesOrders = 'SO';
  static const jobOrders = 'JobOrders';
  static const mailboxMonitor = 'Mailbox Monitor';
  static const irReport = 'IR Report';
}

/// The Super Admin's first tab on the admin dashboard: the day's numbers of SO, JO, Mailbox Monitor,
/// IR, truck and vessel planning and truck location, with a button to open each
/// (change `super-admin-overview-tab`).
class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key, required this.onOpenTab, this.repository, this.menu});

  /// Switches the dashboard to the tab with this label ([OverviewTabLinks]).
  final void Function(String tabLabel) onOpenTab;

  /// For tests; the app builds it from the service locator.
  final AdminOverviewRepository? repository;

  /// The user's menu entries; defaults to the signed-in menu. A screen button shows only when its
  /// entry is there.
  final List<MenuMasterModel>? menu;

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => AdminOverviewCubit(widget.repository ?? AdminOverviewRepository.fromServiceLocator())..load(),
      child: _OverviewView(
        onOpenTab: widget.onOpenTab,
        menu: widget.menu ?? [...AppGlobals.parentclass, ...AppGlobals.objMenuMaster],
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.onOpenTab, required this.menu});

  final void Function(String tabLabel) onOpenTab;
  final List<MenuMasterModel> menu;

  MenuMasterModel? _entry(String formText) {
    for (final m in menu) {
      if (m.FormText == formText) return m;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTokens.surfacePage,
      child: LayoutBuilder(builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        return BlocBuilder<AdminOverviewCubit, AdminOverviewState>(builder: (context, s) {
          final cubit = context.read<AdminOverviewCubit>();
          return RefreshIndicator(
            color: AppTokens.brandGradientStart,
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 4, isTablet ? 20 : 12, 24),
              children: [
                _Header(state: s, isTablet: isTablet, onRefresh: cubit.load, onRetry: cubit.retry),
                const SizedBox(height: 12),
                _QuickButtons(isTablet: isTablet, buttons: _buttons(context)),
                const SizedBox(height: 12),
                _Sections(isTablet: isTablet, children: _sections(context, s, cubit)),
              ],
            ),
          );
        });
      }),
    );
  }

  List<QuickButton> _buttons(BuildContext context) {
    final vessel = _entry('Vessel Planning');
    final planning = _entry('Planning');
    final trucks = _entry('Truck Location');
    return [
      QuickButton(label: 'SO', icon: Icons.receipt_long_outlined, onTap: () => onOpenTab(OverviewTabLinks.salesOrders)),
      QuickButton(label: 'JO', icon: Icons.build_outlined, onTap: () => onOpenTab(OverviewTabLinks.jobOrders)),
      QuickButton(label: 'Mailbox', icon: Icons.mail_outline, onTap: () => onOpenTab(OverviewTabLinks.mailboxMonitor)),
      QuickButton(
          label: 'IR Report', icon: Icons.report_problem_outlined, onTap: () => onOpenTab(OverviewTabLinks.irReport)),
      if (vessel != null)
        QuickButton(
            label: 'Vessel Planning', icon: Icons.directions_boat_outlined, onTap: () => _openVessel(context, vessel)),
      if (planning != null)
        QuickButton(label: 'Truck Planning', icon: Icons.local_shipping_outlined, onTap: () => _openPlanning(context)),
      if (trucks != null)
        QuickButton(label: 'Truck Location', icon: Icons.location_on_outlined, onTap: () => _openTrucks(context)),
    ];
  }

  // The screens open as the side menu opens them.
  void _openVessel(BuildContext context, MenuMasterModel e) => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => VesselPlanningWebTab(
            pageView: e.PageView == 1,
            pageAdd: e.PageAdd == 1,
            pageEdit: e.PageEdit == 1,
            pageDelete: e.PageDelete == 1,
          ),
        ),
      );

  void _openPlanning(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PlansPage()));

  void _openTrucks(BuildContext context) => Navigator.push(context, TruckLocationRoutes.board());

  List<Widget> _sections(BuildContext context, AdminOverviewState s, AdminOverviewCubit cubit) {
    final vessel = _entry('Vessel Planning');
    final planning = _entry('Planning');
    final trucks = _entry('Truck Location');
    return [
      SectionCard(
        title: 'Mailbox Monitor',
        icon: Icons.mail_outline,
        onOpen: () => onOpenTab(OverviewTabLinks.mailboxMonitor),
        child: AreaBody(
          area: s.mail,
          onRetry: () => cubit.retry(OverviewArea.mail),
          builder: (m) {
            final rows =
                attentionFirst(m.mailboxes).where((r) => (r.unread ?? 0) > 0 || r.status != 'OK').take(3).toList();
            if (rows.isEmpty) return const _Quiet('No unread mail');
            return Column(children: [
              for (final r in rows)
                SectionRow(
                  text: '${r.displayName.isEmpty ? r.address : r.displayName} · ${r.unread ?? 0} unread',
                  trailing: StatusPill(lookOf(r).label, tone: lookOf(r).tone),
                ),
            ]);
          },
        ),
      ),
      SectionCard(
        title: 'Incident reports',
        icon: Icons.report_problem_outlined,
        onOpen: () => onOpenTab(OverviewTabLinks.irReport),
        child: AreaBody(
          area: s.incidents,
          onRetry: () => cubit.retry(OverviewArea.incidents),
          builder: (ir) {
            if (ir.latest.isEmpty) return const _Quiet('No open incident in the last 30 days');
            return Column(children: [
              for (final r in ir.latest)
                SectionRow(
                  text:
                      '${DateFormat('dd MMM').format(r.irDate)} · ${_irSubject(r.truckNo, r.vesselName, r.description)}',
                  trailing: StatusPill(r.statusName ?? 'Open', tone: StatusTone.warning),
                ),
            ]);
          },
        ),
      ),
      SectionCard(
        title: 'Truck planning · today',
        icon: Icons.local_shipping_outlined,
        tinted: true,
        onOpen: planning == null ? null : () => _openPlanning(context),
        child: AreaBody(
          area: s.truckPlanning,
          onRetry: () => cubit.retry(OverviewArea.truckPlanning),
          builder: (n) =>
              CountLine(count: n, label: n == 1 ? "job on today's planning list" : "jobs on today's planning list"),
        ),
      ),
      SectionCard(
        title: 'Vessel planning · next 7 days',
        icon: Icons.directions_boat_outlined,
        tinted: true,
        onOpen: vessel == null ? null : () => _openVessel(context, vessel),
        child: AreaBody(
          area: s.vesselPlanning,
          onRetry: () => cubit.retry(OverviewArea.vesselPlanning),
          builder: (n) => CountLine(count: n, label: n == 1 ? 'job by vessel date' : 'jobs by vessel date'),
        ),
      ),
      SectionCard(
        title: 'Truck location · this week',
        icon: Icons.location_on_outlined,
        onOpen: trucks == null ? null : () => _openTrucks(context),
        child: AreaBody(
          area: s.truckLocation,
          onRetry: () => cubit.retry(OverviewArea.truckLocation),
          builder: (t) => Wrap(spacing: 24, runSpacing: 6, children: [
            CountLine(count: t.filled, label: "today's location filled", color: AppTokens.statusSuccess),
            CountLine(count: t.notFilled, label: 'not filled', color: AppTokens.statusWarning),
            CountLine(count: t.workshop, label: 'in workshop', color: Palette.rose),
          ]),
        ),
      ),
    ];
  }

  static String _irSubject(String? truck, String? vessel, String description) {
    for (final v in [truck, vessel, description]) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return 'Incident';
  }
}

/// The blue header: title, date, Refresh, and the four numbers.
class _Header extends StatelessWidget {
  const _Header({required this.state, required this.isTablet, required this.onRefresh, required this.onRetry});

  final AdminOverviewState state;
  final bool isTablet;
  final Future<void> Function() onRefresh;
  final Future<void> Function(OverviewArea) onRetry;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final updated = state.updatedAt == null ? 'loading…' : 'updated ${DateFormat('HH:mm').format(state.updatedAt!)}';
    final tiles = [
      KpiTile(
        label: 'Sale orders today',
        body: AreaBody(
          area: state.sales,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.sales),
          builder: (s) => KpiValue(value: '${s.today}', sub: 'Month ${s.month} · ${Fmt.rm(s.monthAmount)}'),
        ),
      ),
      KpiTile(
        label: 'Open job orders',
        body: AreaBody(
          area: state.jobOrders,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.jobOrders),
          builder: (j) => KpiValue(
            value: '${j.open}',
            sub: j.byStatus.entries.map((e) => '${e.key} ${e.value}').join(' · '),
          ),
        ),
      ),
      KpiTile(
        label: 'Unread mail',
        body: AreaBody(
          area: state.mail,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.mail),
          builder: (m) => KpiValue(
            value: '${m.summary.totalUnread}',
            alert: m.summary.overdue > 0 ? '${m.summary.overdue} overdue' : null,
            sub: '${m.summary.withUnread} of ${m.summary.mailboxes} mailboxes',
          ),
        ),
      ),
      KpiTile(
        label: 'Open incidents · 30 days',
        body: AreaBody(
          area: state.incidents,
          onDark: true,
          onRetry: () => onRetry(OverviewArea.incidents),
          builder: (ir) => KpiValue(value: '${ir.open}', sub: Fmt.rm(ir.totalAmount)),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(overviewRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Overview', style: AppTypography.heading1(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${DateFormat('EEE, d MMM yyyy').format(now)} · $updated',
                  style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.8))),
            ]),
          ),
          Material(
            color: AppTokens.textOnDark.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onRefresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.refresh, size: 16, color: AppTokens.textOnDark),
                  const SizedBox(width: 6),
                  Text('Refresh',
                      style: AppTypography.bodySmall(color: AppTokens.textOnDark, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _Grid(columns: isTablet ? 4 : 2, spacing: 8, children: tiles),
      ]),
    );
  }
}

class _QuickButtons extends StatelessWidget {
  const _QuickButtons({required this.isTablet, required this.buttons});

  final bool isTablet;
  final List<QuickButton> buttons;

  @override
  Widget build(BuildContext context) => _Grid(columns: isTablet ? buttons.length : 4, spacing: 8, children: buttons);
}

/// Phone: one column. Tablet: two columns, the last card full width when the count is odd.
class _Sections extends StatelessWidget {
  const _Sections({required this.isTablet, required this.children});

  final bool isTablet;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isTablet) {
      return Column(children: [
        for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
      ]);
    }
    return _Grid(columns: 2, spacing: 10, stretchLastOdd: true, children: children);
  }
}

/// Rows of [columns] equal cells; a short last row keeps the cell width.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.spacing, required this.children, this.stretchLastOdd = false});

  final int columns;
  final double spacing;
  final List<Widget> children;
  final bool stretchLastOdd;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = children.sublist(i, (i + columns).clamp(0, children.length));
      final fill = stretchLastOdd && cells.length == 1;
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + columns < children.length ? spacing : 0),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var c = 0; c < (fill ? 1 : columns); c++) ...[
              if (c > 0) SizedBox(width: spacing),
              Expanded(child: c < cells.length ? cells[c] : const SizedBox.shrink()),
            ],
          ]),
        ),
      ));
    }
    return Column(children: rows);
  }
}

class _Quiet extends StatelessWidget {
  const _Quiet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppTokens.statusSuccess),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ]),
      );
}
